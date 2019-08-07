# frozen_string_literal: true

module StoreModel
  # Contains methods for converting StoreModel::Model to ActiveModel::Type::Value.
  module TypeBuilders
    # Converts StoreModel::Model to Types::JsonType
    # @return [Types::JsonType]
    def to_type
      Types::JsonType.new(self)
    end

    # Converts StoreModel::Model to Types::ArrayType
    # @return [Types::ArrayType]
    def to_array_type
      Types::ArrayType.new(self)
    end
  end
end
