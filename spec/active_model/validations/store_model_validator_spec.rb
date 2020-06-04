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
          attribute :configurations, Configuration.to_array_type
          validates :configurations, store_model: true
        end
      end

      context "when array is empty" do
        let(:attributes) { { configurations: [] } }

        it { is_expected.to be_valid }
      end

      context "when all array members are valid" do
        let(:attributes) do
          {
            configurations: [
              Configuration.new(color: "red"),
              Configuration.new(color: "blue")
            ]
          }
        end

        it { is_expected.to be_valid }

        it "returns correct error messages" do
          expect(subject.errors.messages).to be_empty
          expect(subject.errors.full_messages).to be_empty

          expect(subject.configurations.first.errors.messages).to be_empty
          expect(subject.configurations.first.errors.full_messages).to be_empty

          expect(subject.configurations.second.errors.messages).to be_empty
          expect(subject.configurations.second.errors.full_messages).to be_empty
        end
      end

      context "when some array members are invalid" do
        let(:attributes) do
          {
            configurations:
              [
                Configuration.new(color: "red"),
                Configuration.new
              ]
          }
        end

        it { is_expected.to be_invalid }

        it "returns correct error messages" do
          expect(subject.errors.messages).to eq(configurations: ["is invalid"])
          expect(subject.errors.full_messages).to eq(["Configurations is invalid"])

          expect(subject.configurations.second.errors.messages).to eq(color: ["can't be blank"])
          expect(subject.configurations.second.errors.full_messages).to eq(["Color can't be blank"])
        end
      end

      context "when more than one array member is invalid" do
        let(:attributes) { { configurations: [Configuration.new, Configuration.new] } }

        it { is_expected.to be_invalid }

        it "returns correct error messages" do
          expect(subject.errors.messages).to eq(configurations: ["is invalid"])
          expect(subject.errors.full_messages).to eq(["Configurations is invalid"])

          expect(subject.configurations.first.errors.messages).to eq(color: ["can't be blank"])
          expect(subject.configurations.first.errors.full_messages).to eq(["Color can't be blank"])

          expect(subject.configurations.second.errors.messages).to eq(color: ["can't be blank"])
          expect(subject.configurations.second.errors.full_messages).to eq(["Color can't be blank"])
        end
      end

      context "with merge_array_errors: true" do
        let(:custom_product_class) do
          build_custom_product_class do
            attribute :configurations, Configuration.to_array_type
            validates :configurations, store_model: { merge_array_errors: true }
          end
        end

        context "when more than one array member is invalid" do
          let(:attributes) do
            {
              configurations: [
                Configuration.new(color: "red"),
                Configuration.new
              ]
            }
          end

          it { is_expected.to be_invalid }

          it "returns correct error messages" do
            expect(subject.errors.messages).to eq(
              configurations: [
                "[1] Color can't be blank"
              ]
            )
            expect(subject.errors.full_messages).to eq(
              [
                "Configurations [1] Color can't be blank"
              ]
            )
          end
        end

        context "when more than one array member is invalid" do
          let(:attributes) { { configurations: [Configuration.new, Configuration.new] } }

          it { is_expected.to be_invalid }

          it "returns correct error messages" do
            expect(subject.errors.messages).to eq(
              configurations: [
                "[0] Color can't be blank",
                "[1] Color can't be blank"
              ]
            )
            expect(subject.errors.full_messages).to eq(
              [
                "Configurations [0] Color can't be blank",
                "Configurations [1] Color can't be blank"
              ]
            )
          end
        end
      end

      context "when array is nil" do
        let(:attributes) { { configurations: nil } }

        it { is_expected.to be_invalid }

        it "is invalid because configuration is blank" do
          expect(subject.errors.messages).to eq(configurations: ["can't be blank"])
          expect(subject.errors.full_messages).to eq(["Configurations can't be blank"])
        end
      end
    end

    context "with allow_nil: true" do
      let(:custom_product_class) do
        build_custom_product_class do
          attribute :configurations, Configuration.to_array_type
          validates :configurations, allow_nil: true, store_model: true
        end
      end

      context "when array is empty" do
        let(:attributes) { { configurations: [] } }

        it { is_expected.to be_valid }
      end

      context "when array is nil" do
        let(:attributes) { { configurations: nil } }

        it { is_expected.to be_valid }
      end
    end
  end

  context "with polymorphic type" do
    context "with store_model validator" do
      let(:custom_product_class) do
        build_custom_product_class do
          attribute :configuration, StoreModel.one_of { |_json| Configuration }.to_type
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
          attribute :configuration, StoreModel.one_of { |_json| Configuration }.to_type
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

  context "with an polymorphic array type" do
    context "with store_model validator" do
      let(:custom_product_class) do
        build_custom_product_class do
          attribute :configurations, StoreModel.one_of { |_json| Configuration }.to_array_type
          validates :configurations, store_model: true
        end
      end

      context "when array is empty" do
        let(:attributes) { { configurations: [] } }

        it { is_expected.to be_valid }
      end

      context "when all array members are valid" do
        let(:attributes) do
          {
            configurations: [
              Configuration.new(color: "red"),
              Configuration.new(color: "blue")
            ]
          }
        end

        it { is_expected.to be_valid }

        it "returns correct error messages" do
          expect(subject.errors.messages).to be_empty
          expect(subject.errors.full_messages).to be_empty

          expect(subject.configurations.first.errors.messages).to be_empty
          expect(subject.configurations.first.errors.full_messages).to be_empty

          expect(subject.configurations.second.errors.messages).to be_empty
          expect(subject.configurations.second.errors.full_messages).to be_empty
        end
      end

      context "when some array members are invalid" do
        let(:attributes) do
          {
            configurations:
              [
                Configuration.new(color: "red"),
                Configuration.new
              ]
          }
        end

        it { is_expected.to be_invalid }

        it "returns correct error messages" do
          expect(subject.errors.messages).to eq(configurations: ["is invalid"])
          expect(subject.errors.full_messages).to eq(["Configurations is invalid"])

          expect(subject.configurations.second.errors.messages).to eq(color: ["can't be blank"])
          expect(subject.configurations.second.errors.full_messages).to eq(["Color can't be blank"])
        end
      end

      context "when more than one array member is invalid" do
        let(:attributes) { { configurations: [Configuration.new, Configuration.new] } }

        it { is_expected.to be_invalid }

        it "returns correct error messages" do
          expect(subject.errors.messages).to eq(configurations: ["is invalid"])
          expect(subject.errors.full_messages).to eq(["Configurations is invalid"])

          expect(subject.configurations.first.errors.messages).to eq(color: ["can't be blank"])
          expect(subject.configurations.first.errors.full_messages).to eq(["Color can't be blank"])

          expect(subject.configurations.second.errors.messages).to eq(color: ["can't be blank"])
          expect(subject.configurations.second.errors.full_messages).to eq(["Color can't be blank"])
        end
      end

      context "with merge_array_errors: true" do
        let(:custom_product_class) do
          build_custom_product_class do
            attribute :configurations, StoreModel.one_of { Configuration }.to_array_type
            validates :configurations, store_model: { merge_array_errors: true }
          end
        end

        context "when more than one array member is invalid" do
          let(:attributes) do
            {
              configurations: [
                Configuration.new(color: "red"),
                Configuration.new
              ]
            }
          end

          it { is_expected.to be_invalid }

          it "returns correct error messages" do
            expect(subject.errors.messages).to eq(
              configurations: [
                "[1] Color can't be blank"
              ]
            )
            expect(subject.errors.full_messages).to eq(
              [
                "Configurations [1] Color can't be blank"
              ]
            )
          end
        end

        context "when more than one array member is invalid" do
          let(:attributes) { { configurations: [Configuration.new, Configuration.new] } }

          it { is_expected.to be_invalid }

          it "returns correct error messages" do
            expect(subject.errors.messages).to eq(
              configurations: [
                "[0] Color can't be blank",
                "[1] Color can't be blank"
              ]
            )
            expect(subject.errors.full_messages).to eq(
              [
                "Configurations [0] Color can't be blank",
                "Configurations [1] Color can't be blank"
              ]
            )
          end
        end
      end

      context "when array is nil" do
        let(:attributes) { { configurations: nil } }

        it { is_expected.to be_invalid }

        it "is invalid because configuration is blank" do
          expect(subject.errors.messages).to eq(configurations: ["can't be blank"])
          expect(subject.errors.full_messages).to eq(["Configurations can't be blank"])
        end
      end
    end

    context "with allow_nil: true" do
      let(:custom_product_class) do
        build_custom_product_class do
          attribute :configurations, StoreModel.one_of { Configuration }.to_array_type
          validates :configurations, allow_nil: true, store_model: true
        end
      end

      context "when array is empty" do
        let(:attributes) { { configurations: [] } }

        it { is_expected.to be_valid }
      end

      context "when array is nil" do
        let(:attributes) { { configurations: nil } }

        it { is_expected.to be_valid }
      end
    end
  end
end
