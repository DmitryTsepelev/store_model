# frozen_string_literal: true

require "active_model"

module StoreModel
  class JsonModelType < ActiveModel::Type::Value
    def initialize(model_klass)
      @model_klass = model_klass
    end

    def type
      :json
    end

    # rubocop:disable Style/RescueModifier
    def cast_value(value)
      case value
      when String
        decoded = ActiveSupport::JSON.decode(value) rescue nil
        @model_klass.new(decoded) unless decoded.nil?
      when Hash
        @model_klass.new(value)
      when @model_klass
        value
      end
    end
    # rubocop:enable Style/RescueModifier

    def serialize(value)
      case value
      when Hash, @model_klass
        ActiveSupport::JSON.encode(value)
      else
        super
      end
    end

    def changed_in_place?(raw_old_value, new_value)
      cast_value(raw_old_value) != new_value
    end
  end
end
