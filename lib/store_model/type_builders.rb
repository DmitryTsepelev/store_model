# frozen_string_literal: true

module StoreModel
  # Contains methods for converting StoreModel::Model to ActiveModel::Type::Value.
  module TypeBuilders
    # Converts StoreModel::Model to Types::JsonType
    # @return [Types::JsonType]
    def to_type
      coder = @type_options[:coder]
      coder ||= @type_options[:case] && Coders::Case[@type_options[:case]]
      coder ||= Coders::Null

      Types::JsonType.new(self, coder)
    end

    # Converts StoreModel::Model to Types::ArrayType
    # @return [Types::ArrayType]
    def to_array_type
      Types::ArrayType.new(self)
    end

    def type_options(options = {})
      @type_options ||= StoreModel.config.type_options
      @type_options.merge!(options)
      @type_options
    end
  end
end
