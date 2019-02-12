# frozen_string_literal: true

class FhtagnErrorStrategy
  def call(attribute, base_errors, _store_model_errors)
    base_errors.add(attribute, "cthulhu fhtagn")
  end
end
