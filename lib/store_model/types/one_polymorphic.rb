# frozen_string_literal: true

require "active_model"

module StoreModel
  module Types
    # Implements ActiveModel::Type::Value type for handling an instance of StoreModel::Model
    class OnePolymorphic < OneBase
      include PolymorphicHelper

      # Initializes type for model class
      #
      # @param model_wrapper [Proc] class to handle
      #
      # @return [StoreModel::Types::OnePolymorphic ]
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
      def cast_value(value) # rubocop:disable Metrics/MethodLength
        return nil if value.nil?

        if value.is_a?(String)
          decode_and_initialize(value)
        elsif value.respond_to?(:to_h) # Hash itself included
          extract_model_klass(value).new(value.to_h)
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
        return super unless value.is_a?(Hash) || implements_model?(value.class)

        if value.is_a?(StoreModel::Model)
          ActiveSupport::JSON.encode(
            value,
            serialize_unknown_attributes: value.serialize_unknown_attributes?,
            serialize_enums_using_as_json: value.serialize_enums_using_as_json?
          )
        else
          ActiveSupport::JSON.encode(value)
        end
      end

      protected

      # Check if block returns an appropriate class and raise cast error if not
      #
      # @param value [Object] raw data
      #
      # @return [Class] which implements StoreModel::Model
      def extract_model_klass(value)
        model_klass = @model_wrapper.call(value)

        raise_extract_wrapper_error(model_klass) unless implements_model?(model_klass)

        model_klass
      end

      def raise_cast_error(value)
        raise StoreModel::Types::CastError,
              "failed casting #{value.inspect}, only String, " \
              "Hash or instances which implement StoreModel::Model are allowed"
      end

      def model_instance(value)
        extract_model_klass(value).new(value)
      end
    end
  end
end
