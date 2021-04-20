# frozen_string_literal: true

class Configuration
  include StoreModel::Model

  attribute :color, :string
  attribute :model, :string
  attribute :active, :boolean
  attribute :disabled_at, :datetime

  alias_attribute :enabled, :active

  validates :color, presence: true
end
