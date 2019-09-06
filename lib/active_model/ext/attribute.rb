# frozen_string_literal: true

require "active_model/attribute"

module ActiveModel
  class Attribute # :nodoc:
    PARENT_TRACKING_ENABLED_TYPES = [
      StoreModel::Types::ArrayType, StoreModel::Types::JsonType
    ].freeze

    private

    attr_reader :context

    def track_parent?
      PARENT_TRACKING_ENABLED_TYPES.include?(type.class)
    end

    class FromDatabase < ActiveModel::Attribute # :nodoc:
      def type_cast(value)
        track_parent? ? type.deserialize(value, parent: context) : type.deserialize(value)
      end
    end

    class FromUser < ActiveModel::Attribute # :nodoc:
      def type_cast(value)
        track_parent? ? type.cast(value, parent: context) : type.cast(value)
      end
    end

    private_constant :FromDatabase, :FromUser
  end
end
