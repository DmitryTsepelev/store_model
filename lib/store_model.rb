# frozen_string_literal: true

require "store_model/model"
require "store_model/configuration"
require "active_model/ext/attribute"
require "active_model/ext/attribute_set"
require "active_model/ext/attributes"
require "active_model/validations/store_model_validator"
require "active_record/ext/core"

module StoreModel # :nodoc:
  class << self
    def config
      @config ||= Configuration.new
    end
  end
end
