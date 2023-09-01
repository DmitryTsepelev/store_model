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
      #
      # [:reject_if]
      #   Allows you to specify a Proc or a Symbol pointing to a method that
      #   checks whether a record should be built for a certain attribute hash.
      #   The hash is passed to the supplied Proc or the method and it should
      #   return either true or false. Passing <tt>:all_blank</tt> instead of a Proc
      #   will create a proc that will reject a record where all the attributes
      #   are blank excluding any value for <tt>_destroy</tt>.
      #
      #   See https://api.rubyonrails.org/classes/ActiveRecord/NestedAttributes/ClassMethods.html#method-i-accepts_nested_attributes_for
      def accepts_nested_attributes_for(*attributes)
        options = attributes.extract_options!

        attributes.each do |attribute|
          case nested_attribute_type(attribute)
          when Types::OneBase, Types::ManyBase
            options.reverse_merge!(allow_destroy: false, update_only: false)
            options.assert_valid_keys(:allow_destroy, :reject_if, :limit, :update_only)

            define_store_model_attr_accessors(attribute, options)
          else
            super(*attribute, options)
          end
        end
      end

      private

      # If attribute defined in ActiveRecord model but you dont yet have database created
      # you cannot access attribute types.
      # To handle this case, we can use ActiveRecord::Attributes 'attributes_to_define_after_schema_loads'
      # which stores information about custom defined attributes.
      # See ActiveRecord::Attributes#atribute
      # If #accepts_nested_attributes_for is used inside active model instance
      # schema is not required to determine attribute type so we can still use attribute_types
      # If schema loaded the attribute_types already populated and we can safely use it
      # See ActiveRecord::ModelSchema#load_schema!
      def nested_attribute_type(attribute)
        if self < ActiveRecord::Base && !schema_loaded?
          attributes_to_define_after_schema_loads[attribute.to_s]&.first
        else
          attribute_types[attribute.to_s]
        end
      end

      def define_store_model_attr_accessors(attribute, options)
        case nested_attribute_type(attribute)
        when Types::OneBase
          define_association_setter_for_single(attribute, options)
          alias_method "#{attribute}_attributes=", "#{attribute}="
        when Types::ManyBase
          define_association_setter_for_many(attribute, options)
        end

        define_attr_accessor_for_destroy(attribute, options)
      end

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

    # Base
    def assign_nested_attributes_for_collection_association(association, attributes, options=nil)
      return super(association, attributes) unless options

      attributes = attributes.values if attributes.is_a?(Hash)

      if options&.dig(:allow_destroy)
        attributes.reject! do |attribute|
          ActiveRecord::Type::Boolean.new.cast(attribute.stringify_keys.dig("_destroy"))
        end
      end

      attributes.reject! { |attribute| call_reject_if(attribute, options[:reject_if]) } if options&.dig(:reject_if)

      send("#{association}=", attributes)
    end

    def call_reject_if(attributes, callback)
      callback = ActiveRecord::NestedAttributes::ClassMethods::REJECT_ALL_BLANK_PROC if callback == :all_blank

      case callback
      when Symbol
        method(callback).arity.zero? ? send(callback) : send(callback, attributes)
      when Proc
        callback.call(attributes)
      end
    end
  end
end
