# frozen_string_literal: true

module StoreModel
  # Keeps input keys without a writer in #unknown_attributes while a StoreModel
  # type builds the model, instead of raising ActiveModel::UnknownAttributeError.
  module UnknownAttributeAssignment
    COLLECTING_KEY = :store_model_collect_unknown_attributes

    # Only the next StoreModel instance initialized inside the block collects
    # unknown keys, so models built by its writers stay strict.
    def self.collect
      previous = Thread.current[COLLECTING_KEY]
      Thread.current[COLLECTING_KEY] = true
      yield
    ensure
      Thread.current[COLLECTING_KEY] = previous
    end

    def initialize(attributes = {})
      @collecting_unknown_attributes = Thread.current[COLLECTING_KEY]
      Thread.current[COLLECTING_KEY] = nil
      super
    ensure
      @collecting_unknown_attributes = nil
    end

    private

    # Checking for the writer up front avoids raising NoMethodError per unknown key,
    # which goes through ActiveModel's method_missing and casts every attribute.
    def _assign_attribute(key, value)
      return super unless @collecting_unknown_attributes

      setter = :"#{key}="
      if respond_to_without_attributes?(setter)
        public_send(setter, value)
      else
        unknown_attributes[key.to_s] = value
      end
    end
  end
end
