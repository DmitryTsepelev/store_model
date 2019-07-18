# frozen_string_literal: true

class ComplexConfiguration < Configuration
  attribute :suppliers, Supplier.to_array_type
end
