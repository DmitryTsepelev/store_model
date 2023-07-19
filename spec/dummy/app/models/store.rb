# frozen_string_literal: true

class Store < ActiveRecord::Base
  include StoreModel::NestedAttributes

  has_many :products, dependent: :destroy
end
