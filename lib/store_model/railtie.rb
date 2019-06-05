# frozen_string_literal: true

module StoreModel
  class Railtie < Rails::Railtie
    config.to_prepare do |_app|
      ActiveSupport.on_load(:active_record) do
        require "store_model/ext/active_record"
      end
    end
  end
end
