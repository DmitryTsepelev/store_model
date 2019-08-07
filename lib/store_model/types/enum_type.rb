# frozen_string_literal: true

require "active_model"

module StoreModel
  module Types
    # Implements ActiveModel::Type::Value type for handling Rails-like enums
    class EnumType < ActiveModel::Type::Value
      # Initializes type for mapping
      #
      # @param mapping [Hash] mapping for enum values
      #
      # @return [StoreModel::Types::EnumType]
      def initialize(mapping)
        @mapping = mapping
      end

      # Returns type
      #
      # @return [Symbol]
      def type
        :integer
      end

      # Casts +value+ from DB or user to StoreModel::Model instance
      #
      # @param value [Object] a value to cast
      #
      # @return StoreModel::Model
      def cast_value(value)
        return if value.blank?

        case value
        when String, Symbol then cast_symbol_value(value.to_sym)
        when Integer then cast_integer_value(value)
        else
          raise StoreModel::Types::CastError,
                "failed casting #{value.inspect}, only String, Symbol or " \
                "Integer instances are allowed"
        end
      end

      private

      def cast_symbol_value(value)
        raise_invalid_value!(value) unless @mapping.key?(value.to_sym)
        @mapping[value.to_sym]
      end

      def cast_integer_value(value)
        raise_invalid_value!(value) unless @mapping.value?(value)
        value
      end

      def raise_invalid_value!(value)
        raise ArgumentError, "invalid value '#{value}' is assigned"
      end
    end
  end
end
