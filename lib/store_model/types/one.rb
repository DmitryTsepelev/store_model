# frozen_string_literal: true

require "active_model"

module StoreModel
  module Types
    # Implements ActiveModel::Type::Value type for handling an instance of StoreModel::Model
    class One < OneBase
      # Initializes type for model class
      #
      # @param model_klass [StoreModel::Model] model class to handle
      #
      # @return [StoreModel::Types::One]
      def initialize(model_klass)
        @model_klass = model_klass
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
        when String then decode_and_initialize(value)
        when Hash then model_instance(value)
        when @model_klass, nil then value
        else raise_cast_error(value)
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
        when @model_klass, Hash
          ActiveSupport::JSON.encode(value)
        else
          super
        end
      end

      # Converts a value from database input to the appropriate ruby type.
      #
      # @param value [String] value to deserialize
      #
      # @return [Object] deserialized value

      # rubocop:disable Style/RescueModifier
      def deserialize(value)
        case value
        when String
          payload = ActiveSupport::JSON.decode(value) rescue {}
          model_instance(deserialize_by_types(payload))
        when Hash
          model_instance(deserialize_by_types(value))
        when nil
          nil
        else raise_cast_error(value)
        end
      end
      # rubocop:enable Style/RescueModifier

      private

      def raise_cast_error(value)
        raise StoreModel::Types::CastError,
              "failed casting #{value.inspect}, only String, " \
              "Hash or #{@model_klass.name} instances are allowed"
      end

      def model_instance(value)
        @model_klass.new(value)
      rescue ActiveModel::UnknownAttributeError => e
        handle_unknown_attribute(value, e)
      end

      def deserialize_by_types(hash)
        @model_klass.attribute_types.each.with_object(hash.dup) do |(key, type), value|
          value[key] = type.deserialize(hash[key]) if hash.key?(key)
        end
      end
    end
  end
end
