# frozen_string_literal: true

ActiveRecord::Schema.define(version: 2019_02_216_153105) do
  create_table :products do |t|
    t.string :name
    t.references :store, null: true
    t.json :configuration, default: {}
  end

  create_table :stores do |t|
    t.json :bicycles, default: []
  end
end
