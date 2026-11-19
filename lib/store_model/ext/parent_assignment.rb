# frozen_string_literal: true

module StoreModel
  # Helper methods for ActiveModel and ActiveRecord parent tracking support
  module ParentAssignment
    private

    def assign_parent_to_store_model_relation(attribute)
      case attribute
      when Array then attribute.each { |item| assign_parent_to_store_model(item) }
      when Hash then attribute.each_value { |item| assign_parent_to_store_model(item) }
      else assign_parent_to_store_model(attribute)
      end
    end

    def assign_parent_to_store_model(model)
      return unless model.is_a?(StoreModel::Model)
      return if model.frozen? || declares_parent_attribute?(model)

      model.parent = self
    end

    # A declared `parent` attribute replaces the accessor, so assigning the owner would overwrite its value.
    def declares_parent_attribute?(model)
      model.class.attribute_types.key?("parent")
    end
  end
end
