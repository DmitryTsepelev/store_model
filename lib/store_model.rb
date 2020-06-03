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

    # TODO: add documentation
    def one_of(&block)
      Class.new do
        define_singleton_method(:to_type) { Types::PolymorphicType.new(block) }
        define_singleton_method(:to_array_type) { Types::PolymorphicArrayType.new(block) }
      end
    end
  end
end
