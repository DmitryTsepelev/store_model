# frozen_string_literal: true

require "coveralls"
Coveralls.wear!

if RUBY_ENGINE == "jruby"
  # Workaround for JRuby CI failure https://github.com/jruby/jruby/issues/6547#issuecomment-774104996
  require "i18n/backend"
  require "i18n/backend/simple"
end

require_relative "dummy/config/environment"

require "active_record"
require "store_model"

ENV["RAILS_ENV"] = "test"

RSpec.configure do |config|
  config.order = :random

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.formatter = :documentation
  config.color = true

  config.after(:each) do
    StoreModel.remove_instance_variable(:@config) if StoreModel.instance_variable_defined?(:@config)
    StoreModel.config.serialize_enums_using_as_json = true
  end
end

ActiveRecord::Base.establish_connection(
  adapter: "sqlite3",
  database: ":memory:"
)

load "#{Rails.root}/db/schema.rb"

def build_custom_product_class(&block)
  klass = Class.new(Product) do
    def self.model_name
      ActiveModel::Name.new(self, nil, "product")
    end
  end

  klass.instance_eval(&block)

  klass
end
