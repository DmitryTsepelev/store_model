# frozen_string_literal: true

class MethodModel
  include StoreModel::Model

  attribute :gear, :string
  attribute :tire, :integer

  def gear
    super || "gear"
  end
end
