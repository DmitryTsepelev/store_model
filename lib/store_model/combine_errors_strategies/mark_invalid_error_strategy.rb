# frozen_string_literal: true

module StoreModel
  module CombileErrorsStrategies
    class MarkInvalidErrorStrategy
      def call(attribute, base_errors, _store_model_errors)
        base_errors.add(attribute, :invalid)
      end
    end
  end
end
