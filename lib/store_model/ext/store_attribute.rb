# frozen_string_literal: true

module StoreModel
  # store_attribute typed store patch with parent tracking support
  module TypedStoreParentAssignment
    def read(object, attribute, key)
      super.tap { |value| object.send(:assign_parent_to_store_model_relation, value) }
    end

    def write(object, attribute, key, value)
      super
      read(object, attribute, key)
    end
  end
end
