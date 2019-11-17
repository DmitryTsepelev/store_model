# frozen_string_literal: true

module StoreModel
  module CombineErrorsStrategies
    # +MergeErrorStrategy+ copies errors from the StoreModel::Model to the parent
    # record (for Rails < 6.1) or marks the attribute invalid (for Rails >= 6.1).
    class MergeErrorStrategy
      # Merges errors on +attribute+ from the child model with parent errors.
      #
      # @param attribute [String] name of the validated attribute
      # @param base_errors [ActiveModel::Errors] errors object of the parent record
      # @param store_model_errors [ActiveModel::Errors] errors object of the StoreModel::Model
      # attribute
      def call(attribute, base_errors, store_model_errors)
        if Rails::VERSION::MAJOR < 6 || Rails::VERSION::MAJOR == 6 && Rails::VERSION::MINOR.zero?
          base_errors.copy!(store_model_errors)
        else
          store_model_errors.errors.each do |error|
            base_errors.add(attribute, :invalid, message: error.full_message)
          end
        end
      end
    end
  end
end
