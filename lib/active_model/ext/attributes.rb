# frozen_string_literal: true

require "active_model/attributes"

ActiveModel::Attributes.include(Module.new do
  def initialize(*)
    @attributes.instance_variable_set(:@context, self)
    @attributes.each_value do |attribute|
      attribute.instance_variable_set(:@context, self)
    end
    super
  end
end)
