# frozen_string_literal: true

module StoreModel
  module CombineErrorsStrategies
    class MergeErrorStrategy
      def call(_attribute, base_errors, store_model_errors)
        if Rails::VERSION::MAJOR < 6 || Rails::VERSION::MAJOR == 6 && Rails::VERSION::MINOR.zero?
          base_errors.copy!(store_model_errors)
        else
          store_model_errors.errors.each do |error|
            base_errors.add(:configuration, :invalid, message: error.full_message)
          end
        end
      end
    end
  end
end
