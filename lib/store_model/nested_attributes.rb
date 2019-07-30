# frozen_string_literal: true

module StoreModel
  module NestedAttributes
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def accepts_nested_attributes_for(*associations)
        associations.each do |association|
          case attribute_types[association.to_s]
          when Types::JsonType
            alias_method "#{association}_attributes=", "#{association}="
          when Types::ArrayType
            define_method "#{association}_attributes=" do |attributes|
              assign_nested_attributes_for_collection_association(association, attributes)
            end
          end
        end
      end
    end

    private

    def assign_nested_attributes_for_collection_association(association, attributes)
      attributes = attributes.values if attributes.is_a?(Hash)
      send "#{association}=", attributes
    end
  end
end
