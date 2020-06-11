# frozen_string_literal: true

require "active_model"

module StoreModel
  module Types
    # Implements ActiveModel::Type::Value type for handling an array of
    # StoreModel::Model
    class Many < ManyBase
      # Initializes type for model class
      #
      # @param model_klass [StoreModel::Model] model class to handle
      #
      # @return [StoreModel::Types::Many]
      def initialize(model_klass)
        @model_klass = model_klass
      end

      # Returns type
      #
      # @return [Symbol]
      def type
        :array
      end

      protected

      def ensure_model_class(array)
        array.map do |object|
          object.is_a?(@model_klass) ? object : cast_model_type_value(object)
        end
      end

      def cast_model_type_value(value)
        model_klass_type.cast_value(value)
      end

      def model_klass_type
        @model_klass_type ||= @model_klass.to_type
      end

      def raise_cast_error(value)
        raise StoreModel::Types::CastError,
              "failed casting #{value.inspect}, only String or Array instances are allowed"
      end
    end
  end
end
