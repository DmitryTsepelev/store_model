# frozen_string_literal: true

class Configuration
  include StoreModel::Model

  attribute :color, :string
  attribute :model, :string
  attribute :active, :boolean
  attribute :disabled_at, :datetime

  validates :color, presence: true
end
