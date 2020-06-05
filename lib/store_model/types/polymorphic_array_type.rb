# frozen_string_literal: true

require "active_model"

module StoreModel
  module Types
    # Implements ActiveModel::Type::Value type for handling an array of
    # StoreModel::Model
    class PolymorphicArrayType < ActiveModel::Type::Value
      # Initializes type for model class
      #
      # @param model_wrapper [Proc] class to handle
      #
      # @return [StoreModel::Types::PolymorphicArrayType ]
      def initialize(model_wrapper)
        @model_wrapper = model_wrapper
      end

      # Returns type
      #
      # @return [Symbol]
      def type
        :polymorphic_array
      end

      # Casts +value+ from DB or user to StoreModel::Model instance
      #
      # @param value [Object] a value to cast
      #
      # @return StoreModel::Model
      def cast_value(value)
        case value
        when String then decode_and_initialize(value)
        when Array then ensure_model_class(value)
        when nil then value
        else
          raise_cast_error(value)
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
      def decode_and_initialize(array_value)
        decoded = ActiveSupport::JSON.decode(array_value) rescue []
        decoded.map { |attributes| cast_model_type_value(attributes) }
      end
      # rubocop:enable Style/RescueModifier

      def ensure_model_class(array)
        array.map do |object|
          next object if object.class.ancestors.include?(StoreModel::Model)

          cast_model_type_value(object)
        end
      end

      def cast_model_type_value(value)
        model_klass = @model_wrapper.call(value)

        raise raise_cast_error(value) unless model_klass&.respond_to?(:to_type)

        model_klass.to_type.cast_value(value)
      end

      def raise_cast_error(value)
        raise StoreModel::Types::CastError,
              "failed casting #{value.inspect}, only String, " \
              "Hash or instances which implement StoreModel::Model are allowed"
      end
    end
  end
end
