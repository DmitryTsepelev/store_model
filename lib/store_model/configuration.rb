# frozen_string_literal: true

module StoreModel
  # StoreModel configuration.
  class Configuration
    # Controls usage of MergeErrorStrategy
    # @return [Boolean]
    attr_accessor :merge_errors

    # Controls usage of MergeArrayErrorStrategy
    # @return [Boolean]
    attr_accessor :merge_array_errors

    # Controls if the result of `as_json` will contain the unknown attributes of the model
    # @return [Boolean]
    attr_accessor :serialize_unknown_attributes

    # Controls if the result of `as_json` will serialize enum fields using `as_json`
    # @return [Boolean]
    attr_accessor :serialize_enums_using_as_json

    # Controls if parent tracking functionality is enabled.
    # Default: true
    # @return [Boolean]
    attr_accessor :enable_parent_assignment

    def initialize
      @serialize_unknown_attributes = true
      @enable_parent_assignment = true
      @serialize_enums_using_as_json = true
    end
  end
end
