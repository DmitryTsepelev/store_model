# frozen_string_literal: true

require "store_model/ext/parent_assignment"

module StoreModel
  # ActiveRecord::Base patch with parent tracking support
  module Base
    include ParentAssignment

    def _read_attribute(*)
      super.tap do |value|
        assign_parent_to_store_model_relation(value)
      end
    end

    def _write_attribute(*)
      super.tap do |value|
        assign_parent_to_store_model_relation(value)
      end
    end
  end
end
