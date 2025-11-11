# frozen_string_literal: true

module StoreModel
  module CombineErrorsStrategies
    # +MarkInvalidErrorStrategy+ marks attribute invalid in the parent record.
    class MarkInvalidErrorStrategy
      # Invalidates +attribute+ in the parent record.
      #
      # @param attribute [String] name of the validated attribute
      # @param base_errors [ActiveModel::Errors] errors object of the parent record
      # @param _store_model_errors [ActiveModel::Errors] errors object of the
      # StoreModel::Model attribute
      def call(attribute, base_errors, store_model_errors)
        base_errors.add(attribute, :invalid, errors: store_model_errors)
      end
    end
  end
end
