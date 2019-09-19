# frozen_string_literal: true

module StoreModel
  # Helper methods for ActiveModel and ActiveRecord parent tracking support
  module ParentAssignment
    private

    def assign_parent_to_store_model_relation(attribute)
      assign_parent_to_singular_store_model(attribute)
      return unless attribute.is_a?(Array)

      attribute.each(&method(:assign_parent_to_singular_store_model))
    end

    def assign_parent_to_singular_store_model(item)
      item.parent = self if item.is_a?(StoreModel::Model)
    end
  end
end
