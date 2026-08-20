# frozen_string_literal: true

module StoreModel
  # Helper methods for ActiveModel and ActiveRecord parent tracking support
  module ParentAssignment
    private

    def assign_parent_to_store_model_relation(attribute)
      case attribute
      when StoreModel::Model
        attribute.parent = self unless attribute.frozen?
      when Array
        attribute.each(&method(:assign_parent_to_store_model_relation))
      when Hash
        attribute.each_value(&method(:assign_parent_to_store_model_relation))
      end
    end
  end
end
