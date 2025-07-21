# frozen_string_literal: true

require "active_model"

module StoreModel
  module Types
    # Implements type for handling a hash of StoreModel::Model
    class HashBase < Base
      # Casts +value+ from DB or user to Hash of StoreModel::Model instances
      #
      # @param value [Object] a value to cast
      #
      # @return Hash
      def cast_value(value)
        case value
        when String then decode_and_initialize(value)
        when ::Hash then ensure_model_class(value)
        when nil then value
        else
          raise_cast_error(value)
        end
      end

      # Casts a value from the ruby type to a type that the database knows how
      # to understand.
      #
      # @param value [Object] value to serialize
      #
      # @return [String] serialized value
      def serialize(value)
        return super unless value.is_a?(::Hash)
        if value.empty? || value.values.any? { |v| !v.is_a?(StoreModel::Model) }
          return ActiveSupport::JSON.encode(value)
        end

        ActiveSupport::JSON.encode(
          value,
          serialize_unknown_attributes: value.values.first.serialize_unknown_attributes?,
          serialize_enums_using_as_json: value.values.first.serialize_enums_using_as_json?
        )
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

      def ensure_model_class(_hash)
        raise NotImplementedError
      end

      def cast_model_type_value(_value)
        raise NotImplementedError
      end

      private

      # rubocop:disable Style/RescueModifier
      def decode_and_initialize(hash_value)
        decoded = ActiveSupport::JSON.decode(hash_value) rescue {}
        return {} unless decoded.is_a?(::Hash)

        decoded.transform_values do |attributes|
          next nil if attributes.nil?

          cast_model_type_value(attributes)
        end
      end
      # rubocop:enable Style/RescueModifier
    end
  end
end
