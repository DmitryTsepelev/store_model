# frozen_string_literal: true

require "active_model"

module StoreModel
  module Types
    # Implements ActiveModel::Type::Value type for handling an instance of StoreModel::Model
    class BaseSingleType < ActiveModel::Type::Value
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
        raise NotImplementedError
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

      def raise_cast_error(value)
        raise NotImplementedError
      end

      def handle_unknown_attribute(value, exception)
        attribute = exception.attribute.to_sym
        value_symbolized = value.symbolize_keys

        cast_value(value_symbolized.except(attribute)).tap do |configuration|
          configuration.unknown_attributes[attribute.to_s] = value_symbolized[attribute]
        end
      end

      def model_instance(value)
        raise NotImplementedError
      end

      private

      # rubocop:disable Style/RescueModifier
      def decode_and_initialize(value)
        decoded = ActiveSupport::JSON.decode(value) rescue nil
        model_instance(decoded) unless decoded.nil?
      rescue ActiveModel::UnknownAttributeError => e
        handle_unknown_attribute(decoded, e)
      end
      # rubocop:enable Style/RescueModifier
    end
  end
end
