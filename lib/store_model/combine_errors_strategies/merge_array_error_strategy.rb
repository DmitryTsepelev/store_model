# frozen_string_literal: true

module StoreModel
  module CombineErrorsStrategies
    # +MergeArrayErrorStrategy+ copies errors from the StoreModel::Model to the parent
    # record attribute errors.
    class MergeArrayErrorStrategy
      # Merges errors on +attribute+ from the child model with parent errors.
      #
      # @param attribute [String] name of the validated attribute
      # @param base_errors [ActiveModel::Errors] errors object of the parent record
      # @param store_models [Array] an array or store_models that have been validated
      def call(attribute, base_errors, store_models)
        store_models.each_with_index do |store_model, index|
          store_model.errors.full_messages.each do |full_message|
            base_errors.add(attribute, :invalid, message: "[#{index}] #{full_message}")
          end
        end
      end
    end
  end
end
