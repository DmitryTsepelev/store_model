# frozen_string_literal: true

module StoreModel
  module CombileErrorsStrategies
    class MarkInvalidErrorStrategy
      def call(attribute, base_errors, _store_model_errors)
        base_errors.add(attribute, I18n.translate("invalid", scope: "errors.messages"))
      end
    end
  end
end
