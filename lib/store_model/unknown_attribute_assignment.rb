# frozen_string_literal: true

module StoreModel
  # Keeps input keys without a writer in #unknown_attributes while a StoreModel
  # type builds the model, instead of raising ActiveModel::UnknownAttributeError.
  module UnknownAttributeAssignment
    PENDING_KEY = :store_model_collect_unknown_attributes
    BUILDING_KEY = :store_model_building_with_unknown_attributes

    # Only the next StoreModel instance built inside the block collects unknown
    # keys, so models built by its writers or a custom initializer stay strict.
    def self.collect
      previous = Thread.current[PENDING_KEY]
      Thread.current[PENDING_KEY] = true
      yield
    ensure
      Thread.current[PENDING_KEY] = previous
    end

    # `new` takes the pending flag before any custom `initialize` runs and can
    # build other models.
    def self.building
      previous = Thread.current[BUILDING_KEY]
      Thread.current[BUILDING_KEY] = Thread.current[PENDING_KEY]
      Thread.current[PENDING_KEY] = nil
      yield
    ensure
      Thread.current[BUILDING_KEY] = previous
    end

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods # :nodoc:
      def new(...)
        UnknownAttributeAssignment.building { super }
      end
    end

    # Falls back to the pending flag for factories that call Class#new directly.
    def initialize(attributes = {})
      @collecting_unknown_attributes = Thread.current[BUILDING_KEY] || Thread.current[PENDING_KEY]
      Thread.current[BUILDING_KEY] = Thread.current[PENDING_KEY] = nil
      super
    ensure
      @collecting_unknown_attributes = nil
    end

    private

    # Checking for the writer up front avoids raising NoMethodError per unknown key,
    # which goes through ActiveModel's method_missing and casts every attribute.
    # Declared attributes can still be served by method_missing, for example after
    # attribute_method_suffix undefines the generated writers.
    def _assign_attribute(key, value)
      return super unless @collecting_unknown_attributes

      setter = :"#{key}="
      if respond_to_without_attributes?(setter) || has_attribute?(key)
        public_send(setter, value)
      else
        unknown_attributes[key.to_s] = value
      end
    end
  end
end
