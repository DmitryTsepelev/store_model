# frozen_string_literal: true

require "active_model"

module StoreModel
  module Types
    class ArrayType < ActiveModel::Type::Value
      def initialize(model_klass)
        @model_klass = model_klass
      end

      def type
        :array
      end

      def cast_value(value)
        case value
        when String then decode_and_initialize(value)
        when Array then ensure_model_class(value)
        else
          raise StoreModel::Types::CastError,
                "failed casting #{value.inspect}, only String or Array instances are allowed"
        end
      end

      def serialize(value)
        case value
        when Array
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
      def decode_and_initialize(array_value)
        decoded = ActiveSupport::JSON.decode(array_value) rescue []
        decoded.map { |attributes| @model_klass.new(attributes) }
      end
      # rubocop:enable Style/RescueModifier

      def ensure_model_class(array)
        array.map do |object|
          object.is_a?(@model_klass) ? object : @model_klass.new(object)
        end
      end
    end
  end
end
