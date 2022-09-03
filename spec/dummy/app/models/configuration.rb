# frozen_string_literal: true

class Configuration
  include StoreModel::Model

  attribute :color, :string
  attribute :model, :string
  attribute :active, :boolean
  attribute :method_attribute
  attribute :disabled_at, :datetime

  alias_attribute :enabled, :active

  validates :color, presence: true

  def method_attribute
    super || "bar"
  end
end
