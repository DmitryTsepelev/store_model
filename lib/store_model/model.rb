# frozen_string_literal: true

require "store_model/types"
require "store_model/enum"
require "store_model/type_builders"
require "store_model/nested_attributes"

module StoreModel
  # When included into class configures it to handle JSON column
  module Model
    def self.included(base) # :nodoc:
      base.include ActiveModel::Model
      base.include ActiveModel::Attributes
      base.include StoreModel::NestedAttributes

      base.extend StoreModel::Enum
      base.extend StoreModel::TypeBuilders
    end

    # Returns a hash representing the model. Some configuration can be
    # passed through +options+.
    #
    # @param options [Hash]
    #
    # @return [Hash]
    def as_json(options = {})
      attributes.with_indifferent_access.as_json(options)
    end

    # Compares two StoreModel::Model instances
    #
    # @param other [StoreModel::Model]
    #
    # @return [Boolean]
    def ==(other)
      return super unless other.is_a?(self.class)

      attributes.all? { |name, value| value == other.attributes[name] }
    end

    # Allows to call :presence validation on the association itself.
    #
    # @return [Boolean]
    def blank?
      attributes.values.all?(&:blank?)
    end

    # String representation of the object.
    #
    # @return [String]
    def inspect
      attribute_string = attributes.map { |name, value| "#{name}: #{value || 'nil'}" }.join(", ")
      "#<#{self.class.name} #{attribute_string}>"
    end

    delegate :attribute_types, to: :class

    # Returns the type of the attribute with the given name
    #
    # @param attr_name [String] name of the attribute
    #
    # @return [ActiveModel::Type::Value]
    def type_for_attribute(attr_name)
      attr_name = attr_name.to_s
      attribute_types[attr_name]
    end

    # Checks if the attribute with a given name is defined
    #
    # @param attr_name [String] name of the attribute
    #
    # @return [Boolean]
    # rubocop:disable Naming/PredicateName
    def has_attribute?(attr_name)
      attribute_types.key?(attr_name.to_s)
    end
    # rubocop:enable Naming/PredicateName

    # Contains a hash of attributes which are not defined but exist in the
    # underlying JSON data
    #
    # @return [Hash]
    def unknown_attributes
      @unknown_attributes ||= {}
    end
  end
end
