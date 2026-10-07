# frozen_string_literal: true

module StoreModel
  # Keeps input keys without a writer in #unknown_attributes while a StoreModel
  # type builds the model, instead of raising ActiveModel::UnknownAttributeError.
  module UnknownAttributeAssignment
    COLLECTING_KEY = :store_model_collecting_unknown_attributes_for

    def self.collect_for(model_class)
      previous = Thread.current[COLLECTING_KEY]
      Thread.current[COLLECTING_KEY] = model_class
      yield
    ensure
      Thread.current[COLLECTING_KEY] = previous
    end

    def attribute_writer_missing(name, value)
      model_class = Thread.current[COLLECTING_KEY]
      raise ActiveModel::UnknownAttributeError.new(self, name) unless model_class && is_a?(model_class)

      unknown_attributes[name] = value
    end

    if ActiveModel::VERSION::MAJOR < 8

      private

      # Backport of ActiveModel 8.0, which added the attribute_writer_missing hook.
      def _assign_attribute(key, value)
        setter = :"#{key}="
        public_send(setter, value)
      rescue NoMethodError
        raise if respond_to?(setter)

        attribute_writer_missing(key.to_s, value)
      end
    end
  end
end
