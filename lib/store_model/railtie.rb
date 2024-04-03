# frozen_string_literal: true

require "store_model/ext/active_model/attributes"
require "store_model/ext/active_record/base"

module StoreModel # :nodoc:
  class Railtie < Rails::Railtie # :nodoc:
    config.to_prepare do |_app|
      # Disable parent tracking functionality
      # which patches ActiveRecord and ActiveModel
      # functionality. 
      #
      # ActiveSupport.on_load(:active_record) do
      #   ActiveModel::Attributes.prepend(Attributes)
      #   prepend(Base)
      # end
    end
  end
end
