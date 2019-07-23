# frozen_string_literal: true

class Supplier
  include StoreModel::Model

  attribute :title, :string

  validates :title, presence: true
end
