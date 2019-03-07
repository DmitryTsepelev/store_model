# frozen_string_literal: true

require "active_record"
require "store_model/combine_errors_strategies"

module ActiveModel
  module Validations
    class StoreModelValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        if value.nil?
          record.errors.add(attribute, :blank)
        elsif value.invalid?
          strategy.call(attribute, record.errors, value.errors)
        end
      end

      private

      def strategy
        StoreModel::CombineErrorsStrategies.configure(options)
      end
    end
  end
end
