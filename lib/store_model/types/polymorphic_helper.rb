# frozen_string_literal: true

module PolymorphicHelper
  def raise_extract_wrapper_error(invalid_klass)
    raise StoreModel::Types::ExpandWrapperError,
          "#{invalid_klass.inspect} is an invalid model klass"
  end

  def implements_model?(klass)
    klass&.ancestors&.include?(StoreModel::Model)
  end
end
