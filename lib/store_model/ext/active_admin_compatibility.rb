# frozen_string_literal: true

module StoreModel
  # ActiveAdmin compatibility patches
  #
  # This module contains patches that make StoreModel compatible with ActiveAdmin's
  # form builders, particularly the has_many helper which expects certain ActiveRecord-like
  # methods to be present.
  #
  # To enable these patches, set:
  #   StoreModel.config.active_admin_compatibility = true
  module ActiveAdminCompatibility
    # Reflection class for StoreModel associations.
    # This provides compatibility with form builders like ActiveAdmin's has_many
    # that expect ActiveRecord-style reflection objects.
    class Reflection
      attr_reader :name, :klass

      # @param name [Symbol] association name
      # @param klass [Class] the StoreModel class
      def initialize(name, klass)
        @name = name
        @klass = klass
      end
    end

    # Patch for StoreModel::Model to add new_record? method
    module NewRecordPatch
      # Always returns true for StoreModel instances when ActiveAdmin compatibility is enabled.
      # This is needed for compatibility with form builders like ActiveAdmin's has_many.
      # For ActiveRecord models, delegates to the original implementation.
      #
      # @return [Boolean]
      def new_record?
        super
      rescue NoMethodError
        true
      end
    end

    # Patch for StoreModel::NestedAttributes::ClassMethods to add reflection methods
    module ReflectionMethods
      # Returns reflection for the given association name.
      # This provides compatibility with form builders like ActiveAdmin's has_many.
      # First checks if the attribute is a StoreModel collection type, and if so,
      # returns a reflection for it. Otherwise, delegates to the original implementation
      # for ActiveRecord associations.
      #
      # @param name [Symbol, String] association name
      # @return [StoreModel::ActiveAdminCompatibility::Reflection, nil]
      def reflect_on_association(name)
        # First check if this is a StoreModel attribute
        # Use attribute_types directly to get the type for the given attribute
        type = attribute_types[name.to_s]

        if type.is_a?(StoreModel::Types::ManyBase) && type.respond_to?(:model_klass) && type.model_klass
          # Return reflection for StoreModel collection attributes
          return StoreModel::ActiveAdminCompatibility::Reflection.new(name.to_sym, type.model_klass)
        end

        # Not a StoreModel attribute, try to call the original method for ActiveRecord associations
        super
      rescue NoMethodError
        # No super method exists (pure StoreModel class), return nil
        nil
      end
    end
  end
end
