# frozen_string_literal: true

require "active_model"

module StoreModel
  module Types
    # Implements ActiveModel::Type::Value type for handling an array of
    # StoreModel::Model
    class BaseArrayType < ActiveModel::Type::Value
      # Returns type
      #
      # @return [Symbol]
      def type
        raise NotImplementedError
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

      protected

      def ensure_model_class(array)
        raise NotImplementedError
      end

      def cast_model_type_value(value)
        raise NotImplementedError
      end

      def raise_cast_error(value)
        raise NotImplementedError
      end

      private

      # rubocop:disable Style/RescueModifier
      def decode_and_initialize(array_value)
        decoded = ActiveSupport::JSON.decode(array_value) rescue []
        decoded.map { |attributes| cast_model_type_value(attributes) }
      end
      # rubocop:enable Style/RescueModifier
    end
  end
end
