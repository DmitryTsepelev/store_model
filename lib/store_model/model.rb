# frozen_string_literal: true

require "store_model/types"
require "store_model/enum"
require "store_model/type_builders"
require "store_model/nested_attributes"

module StoreModel
  module Model
    def self.included(base)
      base.include ActiveModel::Model
      base.include ActiveModel::Attributes
      base.include StoreModel::NestedAttributes

      base.extend StoreModel::Enum
      base.extend StoreModel::TypeBuilders
    end

    def as_json(options = {})
      attributes.with_indifferent_access.as_json(options)
    end

    def ==(other)
      return super unless other.is_a?(self.class)

      attributes.all? { |name, value| value == other.send(name) }
    end

    # Allows to call :presence validation on the association itself
    def blank?
      attributes.values.all?(&:blank?)
    end

    def inspect
      attribute_string = attributes.map { |name, value| "#{name}: #{value || 'nil'}" }.join(", ")
      "#<#{self.class.name} #{attribute_string}>"
    end

    def type_for_attribute(attribute)
      self.class.attribute_types[attribute.to_s]
    end
  end
end
