# frozen_string_literal: true

module StoreModel
  # Contains methods for working with nested StoreModel::Model attributes.
  module NestedAttributes
    def self.included(base) # :nodoc:
      base.extend ClassMethods
    end

    module ClassMethods # :nodoc:
      # Enables handling of nested StoreModel::Model attributes
      #
      # @param associations [Array] list of associations and options to define attributes, for example:
      #   accepts_nested_attributes_for [:suppliers, allow_destroy: true]
      #
      # Alternatively, use the standard Rails syntax:
      #
      # @param associations [Array] list of associations and attributes to define getters and setters.
      #
      # @param options [Hash] options not supported by StoreModel will still be passed to ActiveRecord.
      #
      # Supported options:
      # [:allow_destroy]
      #   If true, destroys any members from the attributes hash with a
      #   <tt>_destroy</tt> key and a value that evaluates to +true+
      #   (e.g. 1, '1', true, or 'true'). This option is off by default.
      def accepts_nested_attributes_for(*associations)
        global_options = associations.extract_options!

        associations.each do |association, options|
          case attribute_types[association.to_s]
          when Types::OneBase
            define_association_setter_for_single(association, options || global_options)
            alias_method "#{association}_attributes=", "#{association}="
            define_attr_accessor_for_destroy(association, options || global_options)
          when Types::ManyBase
            define_association_setter_for_many(association, options || global_options)
            define_attr_accessor_for_destroy(association, options || global_options)
          else
            super(association, options || global_options)
          end
        end
      end

      private

      def define_attr_accessor_for_destroy(association, options)
        return unless options&.dig(:allow_destroy)

        attribute_types[association.to_s].model_klass.class_eval do
          attr_accessor :_destroy
        end
      end

      def define_association_setter_for_many(association, options)
        define_method "#{association}_attributes=" do |attributes|
          assign_nested_attributes_for_collection_association(association, attributes, options)
        end
      end

      def define_association_setter_for_single(association, options)
        return unless options&.dig(:allow_destroy)

        define_method "#{association}=" do |attributes|
          if ActiveRecord::Type::Boolean.new.cast(attributes.stringify_keys.dig("_destroy"))
            super(nil)
          else
            super(attributes)
          end
        end
      end
    end

    private

    def assign_nested_attributes_for_collection_association(association, attributes, options)
      attributes = attributes.values if attributes.is_a?(Hash)

      if options&.dig(:allow_destroy)
        attributes.reject! do |attribute|
          ActiveRecord::Type::Boolean.new.cast(attribute.stringify_keys.dig("_destroy"))
        end
      end

      send("#{association}=", attributes)
    end
  end
end
