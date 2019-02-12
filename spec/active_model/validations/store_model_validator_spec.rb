# frozen_string_literal: true

require "spec_helper"

RSpec.describe ActiveModel::Validations::StoreModelValidator do
  let(:custom_product_class) do
    build_custom_product_class do
      attribute :configuration, Configuration.to_type
      validates :configuration, store_model: true
    end
  end

  subject do
    product = custom_product_class.new
    product.valid?
    product
  end

  it { is_expected.not_to be_valid }

  it "returns errors inside nested object" do
    expect(subject.errors.messages).to eq(configuration: ["is invalid"])
    expect(subject.errors.full_messages).to eq(["Configuration is invalid"])

    expect(subject.configuration.errors.messages).to eq(color: ["can't be blank"])
    expect(subject.configuration.errors.full_messages).to eq(["Color can't be blank"])
  end
end
