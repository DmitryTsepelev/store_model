# frozen_string_literal: true

class MethodModel
  include StoreModel::Model

  attribute :gear, :string
  attribute :tire, :integer

  alias_attribute :foo, :gear

  def gear
    super || "gear"
  end
end
