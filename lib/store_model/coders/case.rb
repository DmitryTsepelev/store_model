module StoreModel
  module Coders
    class Case
      class << self
        def [](type)
          type.to_s.classify.constantize
        end

        def dump(attributes)
          attributes.transform_keys(&method(:transform_key))
        end

        def load(hash)
          hash.transform_keys(&:underscore)
        end
      end

      class Camel < self
        class << self
          def transform_key(key)
            key.camelize(:lower)
          end
        end
      end
    end
  end
end
