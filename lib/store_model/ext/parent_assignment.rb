# frozen_string_literal: true

module StoreModel
  # Helper methods for ActiveModel and ActiveRecord parent tracking support
  module ParentAssignment
    private

    def assign_parent_to_store_model_relation(attribute)
      case attribute
      when StoreModel::Model
        attribute.parent = self unless attribute.frozen? || declares_parent_attribute?(attribute)
      when Array
        attribute.each(&method(:assign_parent_to_store_model_relation))
      when Hash
        attribute.each_value(&method(:assign_parent_to_store_model_relation))
      end
    end

    # A declared `parent` attribute replaces the accessor, so assigning the owner would overwrite its value.
    def declares_parent_attribute?(model)
      model.class.attribute_types.key?("parent")
    end
  end
end
