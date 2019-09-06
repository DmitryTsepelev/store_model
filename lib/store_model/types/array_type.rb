# frozen_string_literal: true

require "active_model"

module StoreModel
  module Types
    # Implements ActiveModel::Type::Value type for handling an array of
    # StoreModel::Model
    class ArrayType < ActiveModel::Type::Value
      # Initializes type for model class
      #
      # @param model_klass [StoreModel::Model] model class to handle
      #
      # @return [StoreModel::Types::ArrayType]
      def initialize(model_klass)
        @model_klass = model_klass
      end

      # Returns type
      #
      # @return [Symbol]
      def type
        :array
      end

      def deserialize(value, parent: nil)
        cast(value, parent: parent)
      end

      def cast(value, parent: nil)
        cast_value(value, parent: parent) unless value.nil?
      end

      # Casts +value+ from DB or user to StoreModel::Model instance
      #
      # @param value [Object] a value to cast
      #
      # @return StoreModel::Model
      def cast_value(value, parent: nil)
        case value
        when String then decode_and_initialize(value, parent: parent)
        when Array then ensure_model_class(value, parent: parent)
        when nil then value
        else
          raise StoreModel::Types::CastError,
                "failed casting #{value.inspect}, only String or Array instances are allowed"
        end
      end

      # Casts a value from the ruby type to a type that the database knows how
      # to understand.
      #
      # @param value [Object] value to serialize
      #
      # @return [String] serialized value
      def serialize(value)
        case value
        when Array
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

      # rubocop:disable Style/RescueModifier
      def decode_and_initialize(array_value, parent: nil)
        decoded = ActiveSupport::JSON.decode(array_value) rescue []
        decoded.map { |attributes| cast_model_type_value(attributes) }
      end
      # rubocop:enable Style/RescueModifier

      def ensure_model_class(array, parent: nil)
        array.map do |object|
          object.is_a?(@model_klass) ? object : cast_model_type_value(object)
        end
      end

      def cast_model_type_value(value)
        model_klass_type.cast_value(value)
      end

      def model_klass_type
        @model_klass_type ||= @model_klass.to_type
      end
    end
  end
end
