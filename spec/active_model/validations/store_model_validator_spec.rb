# frozen_string_literal: true

require "spec_helper"

RSpec.describe ActiveModel::Validations::StoreModelValidator do
  shared_examples "check store model is invalid" do
    it "is invalid because configuration is invalid" do
      expect(subject.errors.messages).to eq(configuration: ["is invalid"])
      expect(subject.errors.full_messages).to eq(["Configuration is invalid"])

      expect(subject.configuration.errors.messages).to eq(color: ["can't be blank"])
      expect(subject.configuration.errors.full_messages).to eq(["Color can't be blank"])
    end
  end

  let(:attributes) { {} }

  subject do
    product = custom_product_class.new(attributes)
    product.valid?
    product
  end

  context "with store_model validator" do
    let(:custom_product_class) do
      build_custom_product_class do
        attribute :configuration, Configuration.to_type
        validates :configuration, store_model: true
      end
    end

    context "when store_model value is not nil" do
      it { is_expected.to be_invalid }

      include_examples "check store model is invalid"
    end

    context "when store_model value is nil" do
      let(:attributes) { { configuration: nil } }

      it { is_expected.to be_invalid }

      it "is invalid because configuration is blank" do
        expect(subject.errors.messages).to eq(configuration: ["can't be blank"])
        expect(subject.errors.full_messages).to eq(["Configuration can't be blank"])
      end
    end
  end

  context "with allow_nil: true" do
    let(:custom_product_class) do
      build_custom_product_class do
        attribute :configuration, Configuration.to_type
        validates :configuration, allow_nil: true, store_model: true
      end
    end

    context "when store_model value is not nil" do
      it { is_expected.to be_invalid }

      include_examples "check store model is invalid"
    end

    context "when store_model value is nil" do
      let(:attributes) { { configuration: nil } }

      it { is_expected.to be_valid }
    end
  end
end
