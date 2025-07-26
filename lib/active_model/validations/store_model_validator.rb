# frozen_string_literal: true

require "active_record"
require "store_model/combine_errors_strategies"

module ActiveModel
  module Validations
    # +StoreModelValidator+ is a subclass of ActiveModel::EachValidator for
    # checking StoreModel::Model attributes.
    class StoreModelValidator < ActiveModel::EachValidator
      # Validates _json_ attribute using the configured strategy or
      # invalidates _array_ attribute when at least one element is invalid.
      #
      # @param record [ApplicationRecord] object to validate
      # @param attribute [String] name of the validated attribute
      # @param value [Object] value of the validated attribute
      # rubocop:disable Metrics/MethodLength
      def validate_each(record, attribute, value)
        if value.nil?
          record.errors.add(attribute, :blank)
          return
        end

        case record.type_for_attribute(attribute).type
        when :json, :polymorphic
          call_json_strategy(record, attribute, value)
        when :array, :polymorphic_array
          call_array_strategy(record, attribute, value)
        when :hash, :polymorphic_hash
          call_hash_strategy(record, attribute, value)
        end
      end
      # rubocop:enable Metrics/MethodLength

      private

      def call_json_strategy(record, attribute, value)
        strategy.call(attribute, record.errors, value.errors) if value.invalid?(record.validation_context)
      end

      def call_array_strategy(record, attribute, value)
        any_invalid = value.select { |v| v.invalid?(record.validation_context) }.present?
        array_strategy.call(attribute, record.errors, value) if any_invalid
      end

      def call_hash_strategy(record, attribute, value)
        invalid_values = value.select { |_k, v| v.invalid?(record.validation_context) }
        hash_strategy.call(attribute, record.errors, invalid_values) if invalid_values.present?
      end

      def strategy
        @strategy ||= StoreModel::CombineErrorsStrategies.configure(options)
      end

      def array_strategy
        @array_strategy ||= StoreModel::CombineErrorsStrategies.configure_array(options)
      end

      def hash_strategy
        @hash_strategy ||= StoreModel::CombineErrorsStrategies.configure_hash(options)
      end
    end
  end
end
