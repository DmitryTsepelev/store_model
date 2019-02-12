# frozen_string_literal: true

require "active_record"
require "store_model/combine_errors_strategies"

module ActiveModel
  module Validations
    class StoreModelValidator < ActiveModel::Validator
      def validate(record)
        options[:attributes].each do |attribute|
          attribute_value = record.send(attribute)
          combine_errors(record, attribute) unless attribute_value.validate
        end
      end

      private

      def combine_errors(record, attribute)
        base_errors = record.errors
        store_model_errors = record.send(attribute).errors

        base_errors.delete(attribute)

        strategy = StoreModel::CombileErrorsStrategies.configure(options)
        strategy.call(attribute, base_errors, store_model_errors)
      end
    end
  end
end
