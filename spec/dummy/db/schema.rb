# frozen_string_literal: true

ActiveRecord::Schema.define(version: 2019_02_216_153105) do
  drop_table :products if table_exists? :products

  create_table :products do |t|
    t.string :name
    t.json :configuration, default: {}
  end
end
