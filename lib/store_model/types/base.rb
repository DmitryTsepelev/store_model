# frozen_string_literal: true

require "active_model"

module StoreModel
  module Types
    # Base type for StoreModel::Model
    class Base < ActiveModel::Type::Value
      attr_reader :model_klass

      # Returns type
      #
      # @return [Symbol]
      def type
        raise NotImplementedError
      end

      protected

      def raise_cast_error(_value)
        raise NotImplementedError
      end
    end
  end
end
