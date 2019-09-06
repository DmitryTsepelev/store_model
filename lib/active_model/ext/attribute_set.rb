# frozen_string_literal: true

require "active_model/attribute_set"

ActiveModel::AttributeSet.prepend(Module.new do
  def initialize(attributes, context: nil)
    @context = context
    super(attributes)
  end

  def map(&block)
    new_attributes = attributes.transform_values(&block)
    new_attributes.each_value do |attribute|
      attribute.instance_variable_set(:@context, context)
    end
    ActiveModel::AttributeSet.new(new_attributes, context: context)
  end

  protected

  attr_reader :context
end)
