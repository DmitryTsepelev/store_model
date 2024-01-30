# frozen_string_literal: true

module StoreModel
  # Allows defining Rails-like enums
  module Enum
    # Defines new enum
    #
    # @param name [String] name of the enum to define
    # @param values [Object]
    # @param kwargs [Object]
    def enum(name, values = nil, **kwargs)
      values ||= kwargs[:in] || kwargs
      options = kwargs.slice(:_prefix, :_suffix, :default, :raise_on_invalid_values)
                      .reverse_merge(raise_on_invalid_values: true)

      ensure_hash(values).tap do |mapping|
        define_attribute(name, mapping, options)
        define_reader(name, mapping)
        define_writer(name, mapping, options[:raise_on_invalid_values])
        define_method("#{name}_value") { attributes[name.to_s] }
        define_map_readers(name, mapping)
        define_predicate_methods(name, mapping, options)
      end
    end

    private

    def define_attribute(name, mapping, options)
      attribute name, cast_type(mapping, options[:raise_on_invalid_values]), default: options[:default]
    end

    def define_reader(name, mapping)
      define_method(name) do
        raw_value = send("#{name}_value")
        (mapping.key(raw_value) || raw_value).to_s
      end
    end

    def define_writer(name, mapping, raise_on_invalid_values)
      type = cast_type(mapping, raise_on_invalid_values)
      define_method("#{name}=") { |value| super type.cast_value(value) }
    end

    def define_predicate_methods(name, mapping, options)
      mapping.each do |label, value|
        label = affixed_label(label, name, options[:_prefix], options[:_suffix])
        define_method("#{label}?") { send(name) == mapping.key(value).to_s }
      end
    end

    def define_map_readers(name, mapping)
      define_method("#{name}_values") { mapping }
      singleton_class.define_method("#{name}_values") { mapping }
      singleton_class.alias_method(ActiveSupport::Inflector.pluralize(name), "#{name}_values")
    end

    def cast_type(mapping, raise_on_invalid_values)
      StoreModel::Types::EnumType.new(mapping, raise_on_invalid_values)
    end

    def ensure_hash(values)
      return values if values.is_a?(Hash)

      values.zip(0...values.size).to_h
    end

    def affixed_label(label, name, prefix = nil, suffix = nil)
      prefix = prefix == true ? "#{name}_" : "#{prefix}_" if prefix
      suffix = suffix == true ? "_#{name}" : "_#{suffix}" if suffix

      "#{prefix}#{label}#{suffix}"
    end
  end
end
