# frozen_string_literal: true

require "active_model"

module StoreModel
  module Types
    # Implements ActiveModel::Type::Value type for handling an array of
    # StoreModel::Model
    class ArrayType < BaseArrayType
      # Returns type
      #
      # @return [Symbol]
      def type
        :array
      end
    end
  end
end
