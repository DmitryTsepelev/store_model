# frozen_string_literal: true

module StoreModel
  # ActiveRecord::Base patch with context tracking support
  module Base
    def _read_attribute(*)
      super.tap do |attribute|
        assign_parent_to(attribute)
      end
    end

    def _write_attribute(*)
      super.tap do |attribute|
        assign_parent_to(attribute)
      end
    end

    private

    def assign_parent_to(attribute)
      attribute.parent = self if attribute.is_a?(StoreModel::Model)
      return unless attribute.is_a?(Array)

      attribute.each do |item|
        item.parent = self if item.is_a?(StoreModel::Model)
      end
    end
  end
end
