# frozen_string_literal: true

require "store_model/ext/active_record/base"

module StoreModel # :nodoc:
  class Railtie < Rails::Railtie # :nodoc:
    config.to_prepare do |_app|
      ActiveSupport.on_load(:active_record) do
        prepend(Base)
      end
    end
  end
end
