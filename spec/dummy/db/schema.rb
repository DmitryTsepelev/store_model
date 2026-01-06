# frozen_string_literal: true

ActiveRecord::Schema.define(version: 2019_02_216_153105) do
  create_table :products do |t|
    t.string :name
    t.references :store, null: true
    t.json :configuration, default: {}
    t.json :product_configuration, default: {}
    t.json :union_test, default: nil
    t.json :validation_hooks_configuration, default: { motion: "Empty" }
  end

  create_table :stores do |t|
    t.json :bicycles, default: []
  end

  create_table :anythings do |t|
    t.json :store, default: {}
    t.string :type
  end
end
