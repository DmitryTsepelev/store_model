# frozen_string_literal: true

module StoreModel
  # store_attribute typed store patch with parent tracking support
  module TypedStoreParentAssignment
    def write(object, attribute, key, value)
      super
      object.send(:assign_parent_to_store_model_relation, read(object, attribute, key))
    end
  end
end
