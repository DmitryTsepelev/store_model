# frozen_string_literal: true

require "active_model"

module StoreModel
  module Types
    class JsonType < ActiveModel::Type::Value
      def initialize(model_klass)
        @model_klass = model_klass
      end

      def type
        :json
      end

      def cast_value(value)
        case value
        when String then decode_and_initialize(value)
        when Hash then @model_klass.new(value)
        when @model_klass, nil then value
        else raise_cast_error(value)
        end
      rescue ActiveModel::UnknownAttributeError => e
        handle_unknown_attribute(value, e)
      end

      def serialize(value)
        case value
        when Hash, @model_klass
          ActiveSupport::JSON.encode(value)
        else
          super
        end
      end

      def changed_in_place?(raw_old_value, new_value)
        cast_value(raw_old_value) != new_value
      end

      private

      # rubocop:disable Style/RescueModifier
      def decode_and_initialize(value)
        decoded = ActiveSupport::JSON.decode(value) rescue nil
        @model_klass.new(decoded) unless decoded.nil?
      rescue ActiveModel::UnknownAttributeError => e
        handle_unknown_attribute(decoded, e)
      end
      # rubocop:enable Style/RescueModifier

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
