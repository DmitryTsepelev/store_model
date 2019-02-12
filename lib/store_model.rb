# frozen_string_literal: true

require "store_model/model"
require "store_model/configuration"
require "active_model/validations/store_model_validator"

module StoreModel
  class << self
    def config
      @config ||= Configuration.new
    end
  end
end
