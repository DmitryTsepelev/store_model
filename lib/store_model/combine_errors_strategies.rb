# frozen_string_literal: true

require "store_model/combine_errors_strategies/mark_invalid_error_strategy"
require "store_model/combine_errors_strategies/merge_error_strategy"
require "store_model/combine_errors_strategies/merge_array_error_strategy"

module StoreModel
  # Module with built-in strategies for combining errors.
  module CombineErrorsStrategies
    module_function

    # Finds a strategy based on +options+ and global config.
    #
    # @param options [Hash]
    #
    # @return [Object] strategy
    def configure(options)
      configured_strategy = options[:merge_errors] || StoreModel.config.merge_errors

      get_configured_strategy(
        configured_strategy,
        StoreModel::CombineErrorsStrategies::MergeErrorStrategy
      )
    end

    # Finds a array strategy based on +options+ and global config.
    #
    # @param options [Hash]
    #
    # @return [Object] strategy
    def configure_array(options)
      configured_strategy = options[:merge_array_errors] || StoreModel.config.merge_array_errors

      get_configured_strategy(
        configured_strategy,
        StoreModel::CombineErrorsStrategies::MergeArrayErrorStrategy
      )
    end

    def get_configured_strategy(configured_strategy, true_strategy_class)
      if configured_strategy.respond_to?(:call)
        configured_strategy
      elsif configured_strategy == true
        true_strategy_class.new
      elsif configured_strategy.nil?
        StoreModel::CombineErrorsStrategies::MarkInvalidErrorStrategy.new
      else
        const_get(configured_strategy.to_s.camelize).new
      end
    end
  end
end
