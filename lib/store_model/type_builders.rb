# frozen_string_literal: true

module StoreModel
  # Contains methods for converting StoreModel::Model to ActiveModel::Type::Value.
  module TypeBuilders
    # Converts StoreModel::Model to Types::One
    # @return [Types::One]
    def to_type
      Types::One.new(self)
    end

    # Converts StoreModel::Model to Types::Many
    # @return [Types::Many]
    def to_array_type
      Types::Many.new(self)
    end

    # Converts StoreModel::Model to Types::Hash
    # @return [Types::Hash]
    def to_hash_type
      Types::Hash.new(self)
    end
  end
end
