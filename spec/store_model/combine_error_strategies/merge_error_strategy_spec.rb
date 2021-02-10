# frozen_string_literal: true

require "spec_helper"

RSpec.describe StoreModel::CombineErrorsStrategies::MergeErrorStrategy do
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

    if Rails::VERSION::MAJOR < 6 || Rails::VERSION::MAJOR == 6 && Rails::VERSION::MINOR.zero?
      expect(record.errors.messages).to eq(color: ["can't be blank"])
      expect(record.errors.full_messages).to eq(["Color can't be blank"])
    else
      expect(record.errors.messages).to eq(configuration: ["Color can't be blank"])
      expect(record.errors.full_messages).to eq(["Configuration Color can't be blank"])
    end

    expect(record.configuration.errors.messages).to eq(color: ["can't be blank"])
    expect(record.configuration.errors.full_messages).to eq(["Color can't be blank"])
  end

  context "when parent model has validation" do
    let(:custom_product_class) do
      build_custom_product_class do
        attribute :configuration, Configuration.to_type
        validates :name, presence: true
        validates :configuration, store_model: true
      end
    end

    let(:record) do
      product = custom_product_class.new(name: "")
      product.validate
      product
    end

    it "keeps parent validation messages" do
      described_class.new.call(:configuration, record.errors, record.configuration.errors)

      if Rails::VERSION::MAJOR < 6 || Rails::VERSION::MAJOR == 6 && Rails::VERSION::MINOR.zero?
        expect(record.errors.messages).to eq(name: ["can't be blank"], color: ["can't be blank"])
        expect(record.errors.full_messages).to eq(["Name can't be blank", "Color can't be blank"])
      else
        expect(record.errors.messages).to eq(
          name: ["can't be blank"], configuration: ["Color can't be blank"]
        )
        expect(record.errors.full_messages).to eq(
          ["Name can't be blank", "Configuration Color can't be blank"]
        )
      end

      expect(record.configuration.errors.messages).to eq(color: ["can't be blank"])
      expect(record.configuration.errors.full_messages).to eq(["Color can't be blank"])
    end
  end
end
