# frozen_string_literal: true

require "active_model"

module StoreModel
  module Types
    # Implements ActiveModel::Type::Value type for handling an instance of StoreModel::Model
    class OneBase < ActiveModel::Type::Value
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
      def cast_value(_value)
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

      def raise_cast_error(_value)
        raise NotImplementedError
      end

      def model_instance(_value)
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

      def handle_unknown_attribute(value, exception)
        attribute = exception.attribute.to_sym
        value_symbolized = value.symbolize_keys

        filtered_value = value_symbolized.except(attribute)

        if value_symbolized.key?(:attributes)
          filtered_value[:attributes] = filtered_value[:attributes].except(attribute)
        end

        cast_value(filtered_value).tap do |configuration|
          configuration.unknown_attributes[attribute.to_s] = value_symbolized[attribute]

          if value_symbolized.key?(:attributes)
            configuration.unknown_attributes[attribute.to_s] = value_symbolized[:attributes][attribute]
          end
        end
      end
    end
  end
end
