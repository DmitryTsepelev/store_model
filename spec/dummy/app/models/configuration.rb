# frozen_string_literal: true

class Configuration
  include StoreModel::Model

  class Encrypted < ActiveModel::Type::Value
    ALPHABET = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    ENCODING = "MOhqm0PnycUZeLdK8YvDCgNfb7FJtiHT52BrxoAkas9RWlXpEujSGI64VzQ31w"

    def serialize(value)
      value&.tr(ALPHABET, ENCODING) if value
    end

    def deserialize(value)
      value&.tr(ENCODING, ALPHABET) if value
    end
  end

  attribute :color, :string
  attribute :model, :string
  attribute :active, :boolean, default: true
  attribute :disabled_at, :datetime
  attribute :encrypted_serial, Encrypted.new

  alias_attribute :enabled, :active

  validates :color, presence: true
  validates :model, presence: true, on: :custom_context

  enum :type, in: { left: 1, right: 2 }
end
