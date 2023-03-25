# frozen_string_literal: true

class Configuration
  include StoreModel::Model

  class Encrypted < ActiveModel::Type::Value
    def cast_value(value)
      "=#{value}=" if value
    end
  end

  attribute :color, :string
  attribute :model, :string
  attribute :active, :boolean
  attribute :disabled_at, :datetime
  attribute :encrypted_serial, Encrypted.new

  alias_attribute :enabled, :active

  validates :color, presence: true
  validates :model, presence: true, on: :custom_context
end
