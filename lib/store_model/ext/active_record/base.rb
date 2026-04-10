# frozen_string_literal: true

require "store_model/ext/parent_assignment"

module StoreModel
  # ActiveRecord::Base patch with parent tracking support
  module Base
    include ParentAssignment

    def _read_attribute(*)
      value = super
      assign_parent_to_store_model_relation(value) if store_model_attribute?(value)
      value
    end

    def _write_attribute(*)
      value = super
      assign_parent_to_store_model_relation(value) if store_model_attribute?(value)
      value
    end

    private

    def store_model_attribute?(value)
      case value
      when StoreModel::Model then true
      when Array then value.first.is_a?(StoreModel::Model)
      when Hash then value.each_value.any? { |v| v.is_a?(StoreModel::Model) }
      else false
      end
    end
  end
end
