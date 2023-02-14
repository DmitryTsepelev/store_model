# frozen_string_literal: true

require "active_model"

module StoreModel
  module Types
    # Implements ActiveModel::Type::Value type for handling an instance of StoreModel::Model
    class One < OneBase
      # Initializes type for model class
      #
      # @param model_klass [StoreModel::Model] model class to handle
      #
      # @return [StoreModel::Types::One]
      def initialize(model_klass, storage)
        @model_klass = model_klass
        super(storage)
      end

      # Returns type
      #
      # @return [Symbol]
      def type
        @storage
      end

      # Casts +value+ from DB or user to StoreModel::Model instance
      #
      # @param value [Object] a value to cast
      #
      # @return StoreModel::Model
      def cast_value(value)
        case value
        when String then decode_and_initialize(value)
        when Hash then model_instance(value)
        when @model_klass, nil then value
        else raise_cast_error(value)
        end
      rescue ActiveModel::UnknownAttributeError => e
        handle_unknown_attribute(value, e)
      end

      # Casts a value from the ruby type to a type that the database knows how
      # to understand.
      #
      # @param value [Object] value to serialize
      #
      # @return [String] serialized value
      def serialize(value)
        case value
        when Hash, @model_klass
          case @storage
          when STORAGE_JSON
            ActiveSupport::JSON.encode(value, serialize_unknown_attributes: true)
          when STORAGE_HSTORE
            # TODO: what to do with serialize_unknown_attributes ?
            ActiveRecord::ConnectionAdapters::PostgreSQL::OID::Hstore.new.serialize(value.attributes)
          end
        else
          super
        end
      end

      private

      def raise_cast_error(value)
        raise StoreModel::Types::CastError,
              "failed casting #{value.inspect}, only String, " \
              "Hash or #{@model_klass.name} instances are allowed"
      end

      def model_instance(value)
        @model_klass.new(value)
      end
    end
  end
end
