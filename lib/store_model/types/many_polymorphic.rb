# frozen_string_literal: true

require "active_model"

module StoreModel
  module Types
    # Implements ActiveModel::Type::Value type for handling an array of
    # StoreModel::Model
    class ManyPolymorphic < ManyBase
      include PolymorphicHelper

      # Initializes type for model class
      #
      # @param model_wrapper [Proc] class to handle
      #
      # @return [StoreModel::Types::PolymorphicArrayType ]
      def initialize(model_wrapper)
        @model_wrapper = model_wrapper
        super()
      end

      # Returns type
      #
      # @return [Symbol]
      def type
        :polymorphic_array
      end

      private

      def ensure_model_class(array)
        array.map do |object|
          next object if implements_model?(object.class)

          cast_model_type_value(object)
        end
      end

      def cast_model_type_value(value)
        model_klass = @model_wrapper.call(value)

        raise_extract_wrapper_error(model_klass) unless implements_model?(model_klass)

        model_klass.to_type.cast_value(value)
      end

      def raise_cast_error(value)
        raise StoreModel::Types::CastError,
              "failed casting #{value.inspect}, only String, " \
              "Hash or instances which implement StoreModel::Model are allowed"
      end
    end
  end
end
