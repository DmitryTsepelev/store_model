# frozen_string_literal: true

module StoreModel
  module TypeBuilders
    def to_type
      Types::JsonType.new(self)
    end

    def to_array_type
      Types::ArrayType.new(self)
    end
  end
end
