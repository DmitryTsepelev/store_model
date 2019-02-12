# frozen_string_literal: true

class Configuration
  include StoreModel::Model

  attribute :color, :string
  attribute :disabled_at, :datetime

  validates :color, presence: true
end
