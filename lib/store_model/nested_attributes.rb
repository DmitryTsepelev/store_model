# frozen_string_literal: true

module StoreModel
  module NestedAttributes
    def accepts_nested_attributes_for(*associations)
      associations.each do |association|
        alias_method "#{association}_attributes=", "#{association}="
      end
    end
  end
end
