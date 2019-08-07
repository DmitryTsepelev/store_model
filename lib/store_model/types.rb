# frozen_string_literal: true

require "store_model/types/json_type"
require "store_model/types/array_type"
require "store_model/types/enum_type"

module StoreModel
  # Contains all custom types.
  module Types
    class CastError < StandardError; end
  end
end
