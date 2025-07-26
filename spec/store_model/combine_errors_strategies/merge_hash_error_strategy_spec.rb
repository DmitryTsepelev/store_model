# frozen_string_literal: true

require "spec_helper"

RSpec.describe StoreModel::CombineErrorsStrategies::MergeHashErrorStrategy do
  let(:custom_product_class) do
    build_custom_product_class do
      attribute :configurations, Configuration.to_hash_type
      validates :configurations, store_model: { merge_hash_errors: true }
    end
  end

  let(:attributes) do
    {
      configurations: {
        "primary" => Configuration.new,
        "secondary" => Configuration.new(color: "red"),
        "tertiary" => Configuration.new
      }
    }
  end

  subject do
    product = custom_product_class.new(attributes)
    product.valid?
    product
  end

  it "adds message that associated object is invalid" do
    expect(subject.errors.messages).to eq(
      configurations: [
        "[primary] Color can't be blank",
        "[tertiary] Color can't be blank"
      ]
    )
    expect(subject.errors.full_messages).to eq(
      [
        "Configurations [primary] Color can't be blank",
        "Configurations [tertiary] Color can't be blank"
      ]
    )
  end
end
