# frozen_string_literal: true

require "store_model/ext/active_model/attributes"
require "store_model/ext/active_record/base"
require "store_model/ext/active_admin_compatibility"
require "store_model/ext/store_attribute"

module StoreModel # :nodoc:
  class Railtie < Rails::Railtie # :nodoc:
    config.to_prepare do |_app|
      ActiveSupport.on_load(:active_record) do
        if StoreModel.config.enable_parent_assignment
          ActiveModel::Attributes.prepend(Attributes)
          prepend(Base)
          ActiveRecord::Type::TypedStore.prepend(TypedStoreParentAssignment) if defined?(ActiveRecord::Type::TypedStore)
        end

        if StoreModel.config.active_admin_compatibility
          StoreModel::Model.prepend(ActiveAdminCompatibility::NewRecordPatch)
          StoreModel::NestedAttributes::ClassMethods.prepend(ActiveAdminCompatibility::ReflectionMethods)
        end
      end
    end
  end
end
