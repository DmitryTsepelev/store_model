# frozen_string_literal: true

require "active_model"

module StoreModel
  module Types
    # Implements ActiveModel::Type::Value type for handling an instance of StoreModel::Model
    class PolymorphicType < ActiveModel::Type::Value
      # Initializes type for model class
      #
      # @param model_wrapper [Proc] class to handle
      #
      # @return [StoreModel::Types::PolymorphicType ]
      def initialize(model_wrapper)
        @model_wrapper = model_wrapper
      end

      # Returns type
      #
      # @return [Symbol]
      def type
        :polymorphic
      end

      # Casts +value+ from DB or user to StoreModel::Model instance
      #
      # @param value [Object] a value to cast
      #
      # @return StoreModel::Model
      def cast_value(value)
        case value
        when String then decode_and_initialize(value)
        when Hash
          model_klass = extract_model_klass(value)
          model_klass.new(value)
        when nil then value
        else
          raise_cast_error(value) unless value.class.ancestors.include?(StoreModel::Model)

          value
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
        when Hash
          ActiveSupport::JSON.encode(value)
        else
          return ActiveSupport::JSON.encode(value) if value.class.ancestors.include?(StoreModel::Model)

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
      def decode_and_initialize(value)
        decoded = ActiveSupport::JSON.decode(value) rescue nil
        model_klass = extract_model_klass(value)
        model_klass.new(decoded) unless decoded.nil?
      rescue ActiveModel::UnknownAttributeError => e
        handle_unknown_attribute(decoded, e)
      end
      # rubocop:enable Style/RescueModifier

      # Check if block returns an appropriate class and raise cast error if not
      #
      # @param value [Object] raw data
      #
      # @return [Class] which implements StoreModel::Model
      def extract_model_klass(value)
        model_klass = @model_wrapper.call(value)

        raise raise_cast_error(value) unless model_klass&.ancestors&.include?(StoreModel::Model)

        model_klass
      end

      def raise_cast_error(value)
        raise StoreModel::Types::CastError,
              "failed casting #{value.inspect}, only String, " \
              "Hash or instances which implement StoreModel::Model are allowed"
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
