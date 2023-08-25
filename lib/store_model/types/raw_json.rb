# frozen_string_literal: true

module StoreModel
  module Types
    # Implements #encode_json and #as_json methods.
    # By wrapping serialized objects in this type, it prevents duplicate
    # JSON serialization passes on nested object. It is named as Encoder
    # as it will not work to inflate typed attributes and is intended
    # to be used internally.
    class RawJSONEncoder < String
      def encode_json(_encoder)
        self
      end

      def as_json(_options = nil)
        JSON.parse(self)
      end
    end
  end
end
