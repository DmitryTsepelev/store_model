# frozen_string_literal: true

require "store_model/ext/parent_assignment"

module StoreModel
  # ActiveModel::Attributes patch with parent tracking support
  module Attributes
    include ParentAssignment

    private

    def attribute(*)
      super.tap do |value|
        assign_parent_to_store_model_relation(value)
      end
    end

    if Rails::VERSION::MAJOR >= 7
      def _write_attribute(*)
        super.tap do |value|
          assign_parent_to_store_model_relation(value)
        end
      end
    else
      def write_attribute(*)
        super.tap do |value|
          assign_parent_to_store_model_relation(value)
        end
      end
    end
  end
end
