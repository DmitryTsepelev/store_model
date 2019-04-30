# frozen_string_literal: true

require "store_model/types/json_type"
require "store_model/types/array_type"

module StoreModel
  module Model
    def self.included(base)
      base.include ActiveModel::Model
      base.include ActiveModel::Attributes

      base.extend(Module.new do
        def to_type
          Types::JsonType.new(self)
        end

        def to_array_type
          Types::ArrayType.new(self)
        end
      end)
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
  end
end
