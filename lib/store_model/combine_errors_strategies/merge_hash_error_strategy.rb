# frozen_string_literal: true

module StoreModel
  module CombineErrorsStrategies
    # +MergeHashErrorStrategy+ copies errors from the StoreModel::Model to the parent
    # record attribute errors with hash key prefixes.
    class MergeHashErrorStrategy
      # Merges errors on +attribute+ from the child model with parent errors.
      #
      # @param attribute [String] name of the validated attribute
      # @param base_errors [ActiveModel::Errors] errors object of the parent record
      # @param store_models [Hash] a hash of store_models that have been validated
      def call(attribute, base_errors, store_models)
        store_models.each do |key, store_model|
          store_model.errors.full_messages.each do |full_message|
            base_errors.add(attribute, :invalid, message: "[#{key}] #{full_message}")
          end
        end
      end
    end
  end
end
