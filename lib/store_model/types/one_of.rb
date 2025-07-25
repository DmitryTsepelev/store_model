# frozen_string_literal: true

require "active_model"

module StoreModel
  module Types
    # Implements ActiveModel::Type::Value type for handling an array of
    # StoreModel::Model
    class OneOf
      def initialize(&block)
        @block = block
      end

      def to_type
        Types::OnePolymorphic.new(@block)
      end

      def to_array_type
        Types::ManyPolymorphic.new(@block)
      end

      def to_hash_type
        Types::HashPolymorphic.new(@block)
      end
    end
  end
end
