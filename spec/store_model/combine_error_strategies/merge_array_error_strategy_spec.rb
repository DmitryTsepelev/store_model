# frozen_string_literal: true

require "spec_helper"

RSpec.describe StoreModel::CombineErrorsStrategies::MergeArrayErrorStrategy do
  let(:custom_product_class) do
    build_custom_product_class do
      attribute :configurations, Configuration.to_array_type
      validates :configurations, store_model: true
    end
  end

  let(:record) do
    product = custom_product_class.new(
      configurations:
        [
          Configuration.new(color: "red"),
          Configuration.new
        ]
    )
    product.configurations.each(&:validate)
    product
  end

  it "adds message that associated object is invalid" do
    described_class.new.call(:configurations, record.errors, record.configurations)

    expect(record.errors.messages).to eq(configurations: ["[1] Color can't be blank"])
    expect(record.errors.full_messages).to eq(["Configurations [1] Color can't be blank"])

    expect(record.configurations.second.errors.messages).to eq(color: ["can't be blank"])
    expect(record.configurations.second.errors.full_messages).to eq(["Color can't be blank"])
  end
end
