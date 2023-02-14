# frozen_string_literal: true

require "active_model"

module StoreModel
  module Types
    # Implements ActiveModel::Type::Value type for handling an instance of StoreModel::Model
    class OneBase < ActiveModel::Type::Value
      attr_reader :model_klass

      STORAGE_JSON = :json
      STORAGE_HSTORE = :hstore
      STORAGES = [STORAGE_JSON, STORAGE_HSTORE].freeze

      def initialize(storage = STORAGE_JSON)
        unless STORAGES.include?(storage)
          raise ArgumentError, "#{storage} is not supported, supported storages are #{STORAGES.join(', ')}"
        end

        @storage = storage
      end

      # Returns type
      #
      # @return [Symbol]
      def type
        raise NotImplementedError
      end

      # Casts +value+ from DB or user to StoreModel::Model instance
      #
      # @param value [Object] a value to cast
      #
      # @return StoreModel::Model
      def cast_value(_value)
        raise NotImplementedError
      end

      # Determines whether the mutable value has been modified since it was read
      #
      # @param raw_old_value [Object] old value
      # @param new_value [Object] new value
      #
      # @return [Boolean]
      def changed_in_place?(raw_old_value, new_value)
        cast_value(raw_old_value) != new_value
      end

      protected

      def raise_cast_error(_value)
        raise NotImplementedError
      end

      def model_instance(_value)
        raise NotImplementedError
      end

      private

      # rubocop:disable Style/RescueModifier
      def decode_and_initialize(value)
        decoded =
          case @storage
          when STORAGE_JSON
            ActiveSupport::JSON.decode(value) rescue nil
          when STORAGE_HSTORE
            # TODO: remove long namespace?
            ActiveRecord::ConnectionAdapters::PostgreSQL::OID::Hstore.new.deserialize(value) rescue nil
          end
        model_instance(decoded) unless decoded.nil?
      rescue ActiveModel::UnknownAttributeError => e
        handle_unknown_attribute(decoded, e)
      end
      # rubocop:enable Style/RescueModifier

      def handle_unknown_attribute(value, exception)
        attribute = exception.attribute.to_sym
        value_symbolized = value.symbolize_keys
        value_symbolized = value_symbolized[:attributes] if value_symbolized.key?(:attributes)

        cast_value(value_symbolized.except(attribute)).tap do |configuration|
          puts "#{attribute.to_s} = #{value_symbolized[attribute]}"
          configuration.unknown_attributes[attribute.to_s] = value_symbolized[attribute]
        end
      end
    end
  end
end
