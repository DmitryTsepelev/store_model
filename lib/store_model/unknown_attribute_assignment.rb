# frozen_string_literal: true

module StoreModel
  # Keeps input keys without a writer in #unknown_attributes during type casts
  # and nested updates, instead of raising ActiveModel::UnknownAttributeError.
  module UnknownAttributeAssignment
    PENDING_KEY = :store_model_collect_unknown_attributes
    BUILDING_KEY = :store_model_building_with_unknown_attributes

    def self.framework_writers
      @framework_writers ||= (Class.new { include StoreModel::Model }.public_instance_methods.grep(/=\z/) -
        [:attributes=]).freeze
    end

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
      collecting = Thread.current[BUILDING_KEY] || Thread.current[PENDING_KEY]
      Thread.current[BUILDING_KEY] = Thread.current[PENDING_KEY] = nil
      if collecting
        collect_unknown_attributes { super }
      else
        super
      end
    end

    # Unknown keys join #unknown_attributes once every declared attribute is assigned,
    # so writers see the unknown attributes the model had before the assignment.
    def collect_unknown_attributes # :nodoc:
      previous_collecting = @collecting_unknown_attributes
      previous_pending = @pending_unknown_attributes
      @collecting_unknown_attributes = true
      @pending_unknown_attributes = {}
      yield
      unknown_attributes.merge!(@pending_unknown_attributes)
    ensure
      @collecting_unknown_attributes = previous_collecting
      @pending_unknown_attributes = previous_pending
    end

    private

    def _assign_attribute(key, value)
      return super unless @collecting_unknown_attributes

      setter = :"#{key}="
      if has_attribute?(key) || (!UnknownAttributeAssignment.framework_writers.include?(setter) &&
                                (setter != :attributes= || value.respond_to?(:each_pair)) &&
                                respond_to_without_attributes?(setter))
        public_send(setter, value)
      else
        @pending_unknown_attributes[key.to_s] = value
      end
    end
  end
end
