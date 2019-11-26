module StoreModel
  module Coders
    module Null
      class << self
        def dump(attributes)
          attributes
        end

        def load(hash)
          hash
        end
      end
    end
  end
end
