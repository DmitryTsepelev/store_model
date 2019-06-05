# frozen_string_literal: true

ActiveRecord::Base.prepend(Module.new do
  def _write_attribute(attr_name, value)
    type = @attributes[attr_name].type

    if type.is_a?(StoreModel::Types::JsonType) && value
      stored_value = send(attr_name)&.as_json || {}
      super(attr_name, stored_value.merge(value.as_json))
    else
      super(attr_name, value)
    end
  end
end)
