# frozen_string_literal: true

require "store_model/combine_errors_strategies/mark_invalid_error_strategy"
require "store_model/combine_errors_strategies/merge_error_strategy"

module StoreModel
  module CombineErrorsStrategies
    module_function

    # Finds a strategy based on options and global config
    def configure(options)
      configured_strategy = options[:merge_errors] || StoreModel.config.merge_errors

      if configured_strategy.respond_to?(:call)
        configured_strategy
      elsif configured_strategy == true
        StoreModel::CombineErrorsStrategies::MergeErrorStrategy.new
      elsif configured_strategy.nil?
        StoreModel::CombineErrorsStrategies::MarkInvalidErrorStrategy.new
      else
        const_get(configured_strategy.to_s.camelize).new
      end
    end
  end
end
