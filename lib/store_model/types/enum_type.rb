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
      def initialize(mapping, raise_on_invalid_values)
        @mapping = mapping
        @raise_on_invalid_values = raise_on_invalid_values
        super()
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
        when String, Symbol then cast_symbol_value(value)
        when Integer then cast_integer_value(value)
        else
          raise StoreModel::Types::CastError,
                "failed casting #{value.inspect}, only String, Symbol or " \
                "Integer instances are allowed"
        end
      end

      private

      def cast_symbol_value(value)
        raise_invalid_value!(value) if @raise_on_invalid_values && !@mapping.key?(value.to_sym)
        @mapping[value.to_sym] || value
      end

      def cast_integer_value(value)
        raise_invalid_value!(value) if @raise_on_invalid_values && !@mapping.value?(value)
        value
      end

      def raise_invalid_value!(value)
        raise ArgumentError, "invalid value '#{value}' is assigned"
      end
    end
  end
end
