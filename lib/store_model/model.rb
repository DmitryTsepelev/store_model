# frozen_string_literal: true

require "store_model/types"
require "store_model/enum"
require "store_model/type_builders"
require "store_model/nested_attributes"

module StoreModel
  # When included into class configures it to handle JSON column
  module Model # rubocop:disable Metrics/ModuleLength
    def self.included(base) # :nodoc:
      base.include ActiveModel::Model
      base.include ActiveModel::Attributes
      base.include ActiveRecord::AttributeMethods::BeforeTypeCast
      base.include ActiveModel::AttributeMethods
      base.include StoreModel::NestedAttributes

      base.extend StoreModel::Enum
      base.extend StoreModel::TypeBuilders

      base.attribute_method_suffix "?"

      base.extend(ClassMethods)
    end

    # Class methods for StoreModel::Model
    module ClassMethods
      def from_value(value)
        to_type.cast_value(value)
      end

      def from_values(values)
        to_array_type.cast_value(values)
      end

      # Defines a discriminator attribute with a value
      # @param discriminator [Symbol, String] attribute name (default: :type)
      # @param type [Symbol, String] attribute type (default: :string)
      # @param value [String] the discriminator value
      def discriminator_attribute(discriminator = "type", type: :string, value:)
        attribute discriminator, type, default: value
      end
    end

    attr_accessor :parent
    attr_writer :serialize_unknown_attributes, :serialize_enums_using_as_json

    delegate :each_value, to: :attributes

    # Returns a hash representing the model. Some configuration can be
    # passed through +options+.
    #
    # @param options [Hash]
    #
    # @return [Hash]
    def as_json(options = {}) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      serialize_unknown_attributes = if options.key?(:serialize_unknown_attributes)
                                       options[:serialize_unknown_attributes]
                                     else
                                       StoreModel.config.serialize_unknown_attributes
                                     end

      serialize_enums_using_as_json = if options.key?(:serialize_enums_using_as_json)
                                        options[:serialize_enums_using_as_json]
                                      else
                                        StoreModel.config.serialize_enums_using_as_json
                                      end

      result = @attributes.keys.each_with_object({}) do |key, values|
        attr = @attributes.fetch(key)
        assign_serialization_options(attr, serialize_unknown_attributes, serialize_enums_using_as_json)
        values[key] = serialized_attribute(attr)
      end.with_indifferent_access

      result.merge!(unknown_attributes) if serialize_unknown_attributes
      result.as_json(options).tap do |json|
        serialize_enums!(json) if serialize_enums_using_as_json
      end
    end

    # Returns an Object, similar to Hash#fetch, raises
    # a KeyError if attr_name doesn't exist.
    # @param attr_name [String, Symbol]
    #
    # @return Object
    def fetch(attr_name)
      stringified_key = attr_name.to_s
      if attribute_names.include?(stringified_key) || attribute_aliases.key?(stringified_key)
        public_send(stringified_key)
      else
        message = attr_name.is_a?(Symbol) ? "key not found: :#{attr_name}" : "key not found: #{attr_name}"
        raise KeyError, message
      end
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
    alias eql? ==

    # Accessing attribute using brackets
    #
    # @param attr_name [String, Symbol]
    #
    # @return [Object]
    def [](attr_name)
      @attributes.fetch_value(attr_name.to_s)
    end

    # Setting attribute using brackets
    #
    # @param name [String, Symbol]
    # @param value [Object]
    #
    # @return [Object]
    def []=(attr_name, value)
      @attributes.write_from_user(attr_name.to_s, value)
    end

    # Returns hash for a StoreModel::Model instance based on attributes hash
    #
    # @return [Integer]
    def hash
      attributes.hash
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
      attribute_string = attributes.map { |name, value| "#{name}: #{value.inspect}" }
                                   .join(", ")
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
    # @example
    #    class Person
    #      include StoreModel::Model
    #      attribute :name, :string
    #      alias_attribute :new_name, :name
    #    end
    #
    #    Person.has_attribute?('name')     # => true
    #    Person.has_attribute?('new_name') # => true
    #    Person.has_attribute?(:age)       # => true
    #    Person.has_attribute?(:nothing)   # => false
    #
    # @param attr_name [String] name of the attribute
    #
    # @return [Boolean]
    # rubocop:disable Naming/PredicateName
    def has_attribute?(attr_name)
      attr_name = attr_name.to_s
      attr_name = self.class.attribute_aliases[attr_name] || attr_name
      attribute_types.key?(attr_name)
    end

    # Legacy implementation of #has_attribute?
    #
    # @param attr_name [String] name of the attribute
    #
    # @return [Boolean]
    def _has_attribute?(attr_name)
      attribute_types.key?(attr_name)
    end

    # rubocop:enable Naming/PredicateName

    # Contains a hash of attributes which are not defined but exist in the
    # underlying JSON data
    #
    # @return [Hash]
    def unknown_attributes
      @unknown_attributes ||= {}
    end

    # Returns the value of the `@serialize_unknown_attributes` instance
    # variable. In the current specification, unknown attributes must be
    # persisted in the database regardless of the globally configured
    # `serialize_unknown_attributes` option. Therefore, it returns the
    # default value `true` if the instance variable is `nil`.
    #
    # This method is used to ensure that the `serialize_unknown_attributes`
    # option is correctly applied to nested StoreModel::Model objects when
    # the `as_json` method is called.
    #
    # @return [Boolean]
    def serialize_unknown_attributes?
      @serialize_unknown_attributes.nil? ? true : @serialize_unknown_attributes
    end

    # Returns the value of the `@serialize_enums_using_as_json` instance
    # variable. The default value is the value of the globally configured
    # `serialize_enums_using_as_json` option.
    #
    # This method is used to determine whether enums should be serialized
    # when the `as_json` method is called in nested StoreModel::Model
    # objects.
    #
    # @return [Boolean]
    def serialize_enums_using_as_json?
      if @serialize_enums_using_as_json.nil?
        StoreModel.config.serialize_enums_using_as_json || false
      else
        @serialize_enums_using_as_json
      end
    end

    private

    def attribute?(attribute)
      case value = attributes[attribute]
      when 0 then false
      else value.present?
      end
    end

    def serialize_enums!(json)
      enum_mappings =
        self.class
            .attribute_types
            .select { |_, type| type.is_a?(StoreModel::Types::EnumType) }

      enum_mappings.each_key do |name|
        next unless json.key?(name)

        json[name] = public_send(name).as_json unless json[name].nil?
      end
    end

    def serialized_attribute(attr)
      if attr.value.is_a? StoreModel::Model
        Types::RawJSONEncoder.new(attr.value_for_database)
      elsif attr.value.is_a? Array
        serialize_array_attribute(attr.value)
      else
        attr.value_for_database
      end
    end

    def serialize_array_attribute(array)
      return array.as_json unless array.any? && array.all? { |value| value.is_a?(StoreModel::Model) }

      array.as_json(
        serialize_unknown_attributes: array.first.serialize_unknown_attributes?,
        serialize_enums_using_as_json: array.first.serialize_enums_using_as_json?
      )
    end

    def assign_serialization_options(attr, serialize_unknown_attributes, serialize_enums_using_as_json)
      return unless Array(attr.value).all? { |value| value.is_a?(StoreModel::Model) }

      Array(attr.value).each do |value|
        value.serialize_unknown_attributes = serialize_unknown_attributes
        value.serialize_enums_using_as_json = serialize_enums_using_as_json
      end
    end
  end
end
