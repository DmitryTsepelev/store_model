# frozen_string_literal: true

require "active_model"

module StoreModel
  module Types
    # Implements type for handling an instance of StoreModel::Model
    class OneBase < Base
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
        attributes = unwrap_attributes(value.to_h)
        key = unknown_attribute_key(attributes, exception.attribute)

        cast_value(attributes.except(key)).tap do |configuration|
          configuration.unknown_attributes[exception.attribute.to_s] = attributes[key]
        end
      end

      def unwrap_attributes(value)
        value.fetch(:attributes) { value.fetch("attributes", value) }
      end

      def unknown_attribute_key(attributes, attribute)
        attributes.key?(attribute.to_s) ? attribute.to_s : attribute.to_sym
      end
    end
  end
end
