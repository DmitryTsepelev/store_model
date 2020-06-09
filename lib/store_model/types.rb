# frozen_string_literal: true

require "store_model/types/base_single_type"
require "store_model/types/base_array_type"
require "store_model/types/json_type"
require "store_model/types/array_type"
require "store_model/types/enum_type"
require "store_model/types/polymorphic_helper"
require "store_model/types/polymorphic_type"
require "store_model/types/polymorphic_array_type"
require "store_model/types/one_of"

module StoreModel
  # Contains all custom types.
  module Types
    class CastError < StandardError; end
    class ExpandWrapperError < StandardError; end
  end
end
