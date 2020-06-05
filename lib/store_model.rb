# frozen_string_literal: true

require "store_model/model"
require "store_model/configuration"
require "store_model/railtie"
require "active_model/validations/store_model_validator"

module StoreModel # :nodoc:
  class << self
    def config
      @config ||= Configuration.new
    end

    # @return instance [Types::OneOf]
    def one_of(&block)
      Types::OneOf.new(&block)
    end
  end
end
