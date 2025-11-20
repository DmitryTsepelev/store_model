# frozen_string_literal: true

class Bicycle
  include StoreModel::Model

  attribute :gears, :integer

  attribute :sku, :string

  if ActiveModel::VERSION::MAJOR >= 8 && ActiveModel::VERSION::MINOR >= 1
    normalizes :sku, with: ->(v) { v.to_s.upcase.strip }
  end
end
