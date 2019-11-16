# frozen_string_literal: true

require "spec_helper"

RSpec.describe ActiveModel::Validations::StoreModelValidator do
  shared_examples "check store model is invalid" do
    it "returns correct error messages" do
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

  context "with a singular type" do
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

  context "with an array type" do
    context "with store_model validator" do
      let(:custom_product_class) do
        build_custom_product_class do
          attribute :configuration, Configuration.to_array_type
          validates :configuration, store_model: true
        end
      end

      context "when array is empty" do
        it { is_expected.to be_valid }
      end

      context "when array member is invalid" do
        let(:attributes) { { configuration: [Configuration.new, Configuration.new] } }

        it { is_expected.to be_invalid }

        it "returns correct error messages" do
          expect(subject.errors.messages).to eq(configuration: ["is invalid"])
          expect(subject.errors.full_messages).to eq(["Configuration is invalid"])

          expect(subject.configuration.first.errors.messages).to eq(color: ["can't be blank"])
          expect(subject.configuration.first.errors.full_messages).to eq(["Color can't be blank"])

          expect(subject.configuration.second.errors.messages).to eq(color: ["can't be blank"])
          expect(subject.configuration.second.errors.full_messages).to eq(["Color can't be blank"])
        end
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
          attribute :configuration, Configuration.to_array_type
          validates :configuration, allow_nil: true, store_model: true
        end
      end

      context "when array is empty" do
        it { is_expected.to be_valid }
      end

      context "when store_model value is nil" do
        let(:attributes) { { configuration: nil } }

        it { is_expected.to be_valid }
      end
    end
  end
end
