# frozen_string_literal: true

require "active_model"

module StoreModel
  module Types
    # Implements ActiveModel::Type::Value type for handling an instance of StoreModel::Model
    class JsonType < ActiveModel::Type::Value
      # Initializes type for model class
      #
      # @param model_klass [StoreModel::Model] model class to handle
      #
      # @return [StoreModel::Types::JsonType]
      def initialize(model_klass, coder)
        @model_klass = model_klass
        @coder = coder
      end

      # Returns type
      #
      # @return [Symbol]
      def type
        :json
      end

      # Casts +value+ from DB or user to StoreModel::Model instance
      #
      # @param value [Object] a value to cast
      #
      # @return StoreModel::Model
      def cast_value(value)
        case value
        when String
          cast_value((ActiveSupport::JSON.decode(value) rescue nil))
        when Hash
          @model_klass.new(@coder.load(value))
        when @model_klass, nil
          value
        else
          raise_cast_error(value)
        end
      rescue ActiveModel::UnknownAttributeError => e
        handle_unknown_attribute(value, e)
      end

      # Casts a value from the ruby type to a type that the database knows how
      # to understand.
      #
      # @param value [Object] value to serialize
      #
      # @return [String] serialized value
      def serialize(value)
        case value
        when @model_klass
          serialize(@coder.dump(value.attributes))
        when Hash
          ActiveSupport::JSON.encode(value)
        else
          super
        end
      end

      # Determines whether the mutable value has been modified since it was read
      #
      # @param raw_old_value [Object] old value
      # @param new_value [Object] new value
      #
      # @return [Boolean]
      def changed_in_place?(raw_old_value, new_value)
        cast_value(raw_old_value) != new_value
      end

      private

      def raise_cast_error(value)
        raise StoreModel::Types::CastError,
              "failed casting #{value.inspect}, only String, " \
              "Hash or #{@model_klass.name} instances are allowed"
      end

      def handle_unknown_attribute(value, exception)
        attribute = exception.attribute.to_sym
        value_symbolized = value.symbolize_keys

        cast_value(value_symbolized.except(attribute)).tap do |configuration|
          configuration.unknown_attributes[attribute.to_s] = value_symbolized[attribute]
        end
      end
    end
  end
end
