# frozen_string_literal: true

ActiveRecord::Schema.define(version: 2019_02_216_153105) do
  create_table :products, id: :serial do |t|
    t.string :name
    t.json :configuration, default: {}
  end
end
