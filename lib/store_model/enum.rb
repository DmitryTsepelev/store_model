# frozen_string_literal: true

module StoreModel
  module Enum
    def enum(name, values = nil, **kwargs)
      values ||= kwargs[:in] || kwargs

      ensure_hash(values).tap do |mapping|
        define_attribute(name, mapping, kwargs[:default])
        define_reader(name, mapping)
        define_method("#{name}_value") { attributes[name.to_s] }
        define_method("#{name}_values") { mapping }
        define_predicate_methods(name, mapping)
      end
    end

    private

    def define_attribute(name, mapping, default)
      attribute name, StoreModel::Types::EnumType.new(mapping), default: default
    end

    def define_reader(name, mapping)
      define_method(name) { mapping.key(send("#{name}_value")).to_s }
    end

    def define_predicate_methods(name, mapping)
      mapping.each do |label, value|
        define_method("#{label}?") { send(name) == mapping.key(value).to_s }
      end
    end

    def ensure_hash(values)
      return values if values.is_a?(Hash)

      values.zip(0...values.size).to_h
    end
  end
end
