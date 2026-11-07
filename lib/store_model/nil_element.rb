# frozen_string_literal: true

require "active_model"

module StoreModel
  # +NilElement+ stands in for a nil element of an array or hash attribute during
  # validation, so error strategies always receive objects that respond to +errors+.
  # It is always invalid and carries a single +:invalid+ error on +:base+.
  class NilElement
    include ActiveModel::Validations

    validate { errors.add(:base, :invalid) }
  end
end
