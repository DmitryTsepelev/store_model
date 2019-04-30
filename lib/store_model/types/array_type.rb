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

      # rubocop:disable Style/RescueModifier
      def cast_value(array_value)
        case array_value
        when String
          decoded = ActiveSupport::JSON.decode(array_value) rescue []
          decoded.map { |attributes| @model_klass.new(attributes) }
        when Array
          array_value.map do |object|
            object.is_a?(@model_klass) ? object : @model_klass.new(object)
          end
        end
      end
      # rubocop:enable Style/RescueModifier

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
    end
  end
end
