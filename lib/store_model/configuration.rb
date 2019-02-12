# frozen_string_literal: true

module StoreModel
  # StoreModel configuration:
  #
  # - `merge_errors` - set up to `true` to merge errors or specify your
  #                    own strategy
  #
  class Configuration
    attr_accessor :merge_errors
  end
end
