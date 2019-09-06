# frozen_string_literal: true

require "active_record"

ActiveRecord::Core.prepend(Module.new do
  def init_internals
    @attributes.instance_variable_set(:@context, self)
    @attributes.each_value do |attribute|
      attribute.instance_variable_set(:@context, self)
    end
    super
  end
end)
