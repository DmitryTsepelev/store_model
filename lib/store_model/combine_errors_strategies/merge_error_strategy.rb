# frozen_string_literal: true

module StoreModel
  module CombineErrorsStrategies
    class MergeErrorStrategy
      def call(_attribute, base_errors, store_model_errors)
        base_errors.copy!(store_model_errors)
      end
    end
  end
end
