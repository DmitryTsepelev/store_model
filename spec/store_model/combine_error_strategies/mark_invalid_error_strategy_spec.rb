# frozen_string_literal: true

require "spec_helper"

RSpec.describe StoreModel::CombineErrorsStrategies::MarkInvalidErrorStrategy do
  let(:custom_product_class) do
    build_custom_product_class do
      attribute :configuration, Configuration.to_type
      validates :configuration, store_model: true
    end
  end

  let(:record) do
    product = custom_product_class.new
    product.configuration.validate
    product
  end

  it "adds message that associated object is invalid" do
    described_class.new.call(:configuration, record.errors, record.configuration.errors)

    expect(record.errors.messages).to eq(configuration: ["is invalid"])
    expect(record.errors.full_messages).to eq(["Configuration is invalid"])

    expect(record.configuration.errors.messages).to eq(color: ["can't be blank"])
    expect(record.configuration.errors.full_messages).to eq(["Color can't be blank"])

    details = record.errors.details[:configuration].first
    expect(details[:errors]).to be_a ActiveModel::Errors
    expect(details[:errors].messages).to eq(color: ["can't be blank"])
  end
end
