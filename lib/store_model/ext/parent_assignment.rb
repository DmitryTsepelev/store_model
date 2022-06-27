# frozen_string_literal: true

module StoreModel
  # Helper methods for ActiveModel and ActiveRecord parent tracking support
  module ParentAssignment
    private

    def assign_parent_to_store_model_relation(attribute)
      assign_parent_to_singular_store_model(attribute)
      return unless attribute.is_a?(Array)

      # Do not use &method here or it will break if the model has a method attribute
      # See https://github.com/DmitryTsepelev/store_model/issues/121
      attribute.each { |a| assign_parent_to_singular_store_model(a) }
    end

    def assign_parent_to_singular_store_model(item)
      item.parent = self if item.is_a?(StoreModel::Model)
    end
  end
end
