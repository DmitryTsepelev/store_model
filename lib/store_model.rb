# frozen_string_literal: true

require "store_model/model"
require "store_model/configuration"
require "store_model/railtie" if defined?(::Rails::Railtie)
require "active_model/validations/store_model_validator"

module StoreModel # :nodoc:
  class << self
    def config
      @config ||= Configuration.new
    end

    # @return instance [Types::OneOf]
    def one_of(&block)
      Types::OneOf.new(&block)
    end

    # Creates a union type for polymorphic attributes
    # @param klasses [Array<Class>] array of classes that can be used
    # @param discriminator [String, Symbol] the attribute key to check for type (default: 'type')
    # @return instance [Types::OneOf]
    def union(klasses, discriminator: "type")
      discriminators_and_classes = klasses.map do |cls|
        [cls._default_attributes[discriminator]&.value, cls]
      end

      missing_discriminator_classes = discriminators_and_classes.select do |(discriminator_value, _cls)|
        discriminator_value.blank?
      end.map(&:last)

      if missing_discriminator_classes.any?
        raise "discriminator_attribute not set for #{discriminator} on #{missing_discriminator_classes.join(', ')}"
      end

      discriminator_counts = discriminators_and_classes.group_by(&:first)
      duplicates = discriminator_counts.select { |_discriminator_value, pairs| pairs.length > 1 }

      if duplicates.any?
        duplicate_messages = duplicates.map do |discriminator_value, pairs|
          classes = pairs.map(&:last).map(&:name).join(", ")
          "#{discriminator_value.inspect} => [#{classes}]"
        end
        raise "Duplicate discriminator values found: #{duplicate_messages.join('; ')}"
      end

      class_map = Hash[discriminators_and_classes]

      Types::OneOf.new do |attributes|
        next nil unless attributes

        discriminator_value = attributes.with_indifferent_access[discriminator]

        if discriminator_value.blank?
          raise ArgumentError, "Missing discriminator attribute #{discriminator} for union"
        end

        cls = class_map[discriminator_value]
        raise ArgumentError, "Unknown discriminator value for union: #{discriminator_value}" if cls.blank?

        cls
      end
    end
  end
end
