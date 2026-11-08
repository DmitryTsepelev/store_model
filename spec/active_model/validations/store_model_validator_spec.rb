# frozen_string_literal: true

require "spec_helper"

RSpec.describe ActiveModel::Validations::StoreModelValidator do
  shared_examples "check store model is invalid" do
    it "returns correct error messages" do
      expect(subject.errors.messages).to eq(configuration: ["is invalid"])
      expect(subject.errors.full_messages).to eq(["Configuration is invalid"])

      expect(subject.configuration.errors.messages).to eq(color: ["can't be blank"])
      expect(subject.configuration.errors.full_messages).to eq(["Color can't be blank"])

      details = subject.errors.details[:configuration].first
      expect(details[:errors]).to be_a ActiveModel::Errors
      expect(details[:errors].messages).to eq(color: ["can't be blank"])
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

      context "with contextual validations" do
        let(:attributes) { { configuration: Configuration.new(color: "red") } }

        it "propagates context" do
          expect(subject).to be_valid
          expect(subject).to be_invalid(:custom_context)
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

        it "propagates context" do
          expect(subject).to be_valid
          expect(subject).to be_invalid(:custom_context)
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

  context "with a hash type" do
    context "with store_model validator" do
      let(:custom_product_class) do
        build_custom_product_class do
          attribute :configurations, Configuration.to_hash_type
          validates :configurations, store_model: true
        end
      end

      context "when hash is empty" do
        let(:attributes) { { configurations: {} } }

        it { is_expected.to be_valid }
      end

      context "when all hash values are valid" do
        let(:attributes) do
          {
            configurations: {
              "primary" => Configuration.new(color: "red"),
              "secondary" => Configuration.new(color: "blue")
            }
          }
        end

        it { is_expected.to be_valid }

        it "returns correct error messages" do
          expect(subject.errors.messages).to eq({})
          expect(subject.errors.full_messages).to eq([])
        end
      end

      context "when some hash values are invalid" do
        let(:attributes) do
          {
            configurations: {
              "primary" => Configuration.new(color: "red"),
              "secondary" => Configuration.new
            }
          }
        end

        it { is_expected.to be_invalid }

        it "returns correct error messages" do
          expect(subject.errors.messages).to eq(configurations: ["is invalid"])
          expect(subject.errors.full_messages).to eq(["Configurations is invalid"])

          expect(subject.configurations["secondary"].errors.messages).to eq(color: ["can't be blank"])
          expect(subject.configurations["secondary"].errors.full_messages).to eq(["Color can't be blank"])
        end
      end

      context "when multiple hash values are invalid" do
        let(:attributes) do
          {
            configurations: {
              "primary" => Configuration.new,
              "secondary" => Configuration.new,
              "tertiary" => Configuration.new
            }
          }
        end

        it { is_expected.to be_invalid }

        it "returns correct error messages" do
          expect(subject.errors.messages).to eq(configurations: ["is invalid"])
          expect(subject.errors.full_messages).to eq(["Configurations is invalid"])

          expect(subject.configurations["primary"].errors.messages).to eq(color: ["can't be blank"])
          expect(subject.configurations["secondary"].errors.messages).to eq(color: ["can't be blank"])
          expect(subject.configurations["tertiary"].errors.messages).to eq(color: ["can't be blank"])
        end
      end

      context "when hash is nil" do
        let(:attributes) { { configurations: nil } }

        it { is_expected.to be_invalid }

        it "is invalid because configurations is blank" do
          expect(subject.errors.messages).to eq(configurations: ["can't be blank"])
          expect(subject.errors.full_messages).to eq(["Configurations can't be blank"])
        end
      end

      context "with merge_hash_errors: true" do
        let(:custom_product_class) do
          build_custom_product_class do
            attribute :configurations, Configuration.to_hash_type
            validates :configurations, store_model: { merge_hash_errors: true }
          end
        end

        context "when some hash values are invalid" do
          let(:attributes) do
            {
              configurations: {
                "primary" => Configuration.new(color: "red"),
                "secondary" => Configuration.new
              }
            }
          end

          it { is_expected.to be_invalid }

          it "returns correct error messages" do
            expect(subject.errors.messages).to eq(
              configurations: [
                "[secondary] Color can't be blank"
              ]
            )
            expect(subject.errors.full_messages).to eq(
              [
                "Configurations [secondary] Color can't be blank"
              ]
            )
          end
        end

        context "when multiple hash values are invalid" do
          let(:attributes) do
            {
              configurations: {
                "primary" => Configuration.new,
                "secondary" => Configuration.new,
                "tertiary" => Configuration.new
              }
            }
          end

          it { is_expected.to be_invalid }

          it "returns correct error messages" do
            expect(subject.errors.messages).to eq(
              configurations: [
                "[primary] Color can't be blank",
                "[secondary] Color can't be blank",
                "[tertiary] Color can't be blank"
              ]
            )
            expect(subject.errors.full_messages).to eq(
              [
                "Configurations [primary] Color can't be blank",
                "Configurations [secondary] Color can't be blank",
                "Configurations [tertiary] Color can't be blank"
              ]
            )
          end
        end
      end

      context "with a custom strategy and a hash with indifferent access" do
        let(:custom_product_class) do
          build_custom_product_class do
            attribute :configurations, Configuration.to_hash_type
            validates :configurations, store_model: {
              merge_hash_errors: lambda { |attr, errors, store_models|
                errors.add(attr, "primary #{store_models[:primary].errors.full_messages.to_sentence}")
              }
            }
          end
        end

        let(:attributes) do
          { configurations: ActiveSupport::HashWithIndifferentAccess.new("primary" => Configuration.new) }
        end

        it "passes the invalid values with indifferent access" do
          expect(subject.errors.messages).to eq(configurations: ["primary Color can't be blank"])
        end
      end
    end

    context "with allow_nil: true" do
      let(:custom_product_class) do
        build_custom_product_class do
          attribute :configurations, Configuration.to_hash_type
          validates :configurations, allow_nil: true, store_model: true
        end
      end

      context "when hash is empty" do
        let(:attributes) { { configurations: {} } }

        it { is_expected.to be_valid }
      end

      context "when hash is nil" do
        let(:attributes) { { configurations: nil } }

        it { is_expected.to be_valid }
      end
    end
  end

  context "with a polymorphic hash type" do
    context "with store_model validator" do
      let(:custom_product_class) do
        build_custom_product_class do
          attribute :configurations, StoreModel.one_of { |_json| Configuration }.to_hash_type
          validates :configurations, store_model: true
        end
      end

      context "when hash is empty" do
        let(:attributes) { { configurations: {} } }

        it { is_expected.to be_valid }
      end

      context "when all hash values are valid" do
        let(:attributes) do
          {
            configurations: {
              "primary" => Configuration.new(color: "red"),
              "secondary" => Configuration.new(color: "blue")
            }
          }
        end

        it { is_expected.to be_valid }
      end

      context "when some hash values are invalid" do
        let(:attributes) do
          {
            configurations: {
              "primary" => Configuration.new(color: "red"),
              "secondary" => Configuration.new
            }
          }
        end

        it { is_expected.to be_invalid }

        it "returns correct error messages" do
          expect(subject.errors.messages).to eq(configurations: ["is invalid"])
          expect(subject.errors.full_messages).to eq(["Configurations is invalid"])
        end
      end

      context "when hash is nil" do
        let(:attributes) { { configurations: nil } }

        it { is_expected.to be_invalid }

        it "is invalid because configurations is blank" do
          expect(subject.errors.messages).to eq(configurations: ["can't be blank"])
          expect(subject.errors.full_messages).to eq(["Configurations can't be blank"])
        end
      end

      context "with merge_hash_errors: true" do
        let(:custom_product_class) do
          build_custom_product_class do
            attribute :configurations, StoreModel.one_of { |_json| Configuration }.to_hash_type
            validates :configurations, store_model: { merge_hash_errors: true }
          end
        end

        context "when some hash values are invalid" do
          let(:attributes) do
            {
              configurations: {
                "primary" => Configuration.new(color: "red"),
                "secondary" => Configuration.new
              }
            }
          end

          it { is_expected.to be_invalid }

          it "returns correct error messages" do
            expect(subject.errors.messages).to eq(
              configurations: [
                "[secondary] Color can't be blank"
              ]
            )
            expect(subject.errors.full_messages).to eq(
              [
                "Configurations [secondary] Color can't be blank"
              ]
            )
          end
        end
      end
    end

    context "with allow_nil: true" do
      let(:custom_product_class) do
        build_custom_product_class do
          attribute :configurations, StoreModel.one_of { |_json| Configuration }.to_hash_type
          validates :configurations, allow_nil: true, store_model: true
        end
      end

      context "when hash is empty" do
        let(:attributes) { { configurations: {} } }

        it { is_expected.to be_valid }
      end

      context "when hash is nil" do
        let(:attributes) { { configurations: nil } }

        it { is_expected.to be_valid }
      end
    end
  end

  context "when a collection contains nil elements" do
    shared_examples "nil element is invalid" do |attribute_name, messages|
      it { is_expected.to be_invalid }

      it "reports the nil element through the configured strategy" do
        expect(subject.errors.messages).to eq(attribute_name => messages)
      end
    end

    shared_examples "nil element is passed to the strategy as NilElement" do |attribute_name, error_messages|
      it "stores models that respond to #errors in the error details" do
        store_models = subject.errors.details[attribute_name].first[:errors]
        store_models = store_models.values if store_models.is_a?(Hash)
        expect(store_models).to all(respond_to(:errors))
        expect(store_models.flat_map { |m| m.errors.to_a }).to eq(error_messages)
      end
    end

    let(:polymorphic_wrapper) { StoreModel.one_of { |json| json["gears"] ? Bicycle : Configuration } }

    context "with an array type" do
      let(:custom_product_class) do
        build_custom_product_class do
          attribute :configurations, Configuration.to_array_type
          validates :configurations, store_model: true
        end
      end

      context "when the only element is nil" do
        let(:attributes) { { configurations: [nil] } }

        include_examples "nil element is invalid", :configurations, ["is invalid"]
        include_examples "nil element is passed to the strategy as NilElement", :configurations, ["is invalid"]
      end

      context "when nil sits next to valid elements" do
        let(:attributes) { { configurations: [Configuration.new(color: "red"), nil] } }

        include_examples "nil element is invalid", :configurations, ["is invalid"]
      end

      context "when nil sits next to an invalid element" do
        let(:attributes) { { configurations: [nil, Configuration.new] } }

        include_examples "nil element is invalid", :configurations, ["is invalid"]
        include_examples "nil element is passed to the strategy as NilElement",
                         :configurations, ["is invalid", "Color can't be blank"]

        it "keeps nil in the attribute value" do
          expect(subject.configurations.first).to be_nil
        end

        it "still validates the other elements" do
          expect(subject.configurations.second.errors.messages).to eq(color: ["can't be blank"])
        end
      end

      context "when the value is loaded from a JSON string" do
        let(:attributes) { { configurations: "[null]" } }

        include_examples "nil element is invalid", :configurations, ["is invalid"]
      end

      context "with merge_array_errors: true" do
        let(:custom_product_class) do
          build_custom_product_class do
            attribute :configurations, Configuration.to_array_type
            validates :configurations, store_model: { merge_array_errors: true }
          end
        end

        context "when the only element is nil" do
          let(:attributes) { { configurations: [nil] } }

          include_examples "nil element is invalid", :configurations, ["[0] is invalid"]
        end

        context "when nil sits next to an invalid element" do
          let(:attributes) { { configurations: [nil, Configuration.new] } }

          include_examples "nil element is invalid", :configurations, ["[0] is invalid", "[1] Color can't be blank"]
        end

        context "when nil sits between invalid elements" do
          let(:attributes) { { configurations: [Configuration.new, nil, Configuration.new] } }

          include_examples "nil element is invalid", :configurations,
                           ["[0] Color can't be blank", "[1] is invalid", "[2] Color can't be blank"]
        end

        context "when another validation already added :invalid to the attribute" do
          let(:custom_product_class) do
            build_custom_product_class do
              attribute :configurations, Configuration.to_array_type
              validate { errors.add(:configurations, :invalid, message: "too many") }
              validates :configurations, store_model: { merge_array_errors: true }
            end
          end

          let(:attributes) { { configurations: [nil] } }

          include_examples "nil element is invalid", :configurations, ["too many", "[0] is invalid"]
        end
      end

      context "with a custom lambda strategy" do
        let(:custom_product_class) do
          build_custom_product_class do
            attribute :configurations, Configuration.to_array_type
            validates :configurations, store_model: {
              merge_array_errors: lambda { |attr, errors, models|
                models.each_with_index do |m, i|
                  m.errors.full_messages.each { |msg| errors.add(attr, "[#{i}] #{msg}") }
                end
              }
            }
          end
        end

        let(:attributes) { { configurations: [nil, Configuration.new] } }

        include_examples "nil element is invalid", :configurations, ["[0] is invalid", "[1] Color can't be blank"]
      end

      context "with a custom strategy class" do
        let(:custom_product_class) do
          build_custom_product_class do
            attribute :configurations, Configuration.to_array_type
            validates :configurations, store_model: { merge_array_errors: :fhtagn_error_strategy }
          end
        end

        context "when the only element is nil" do
          let(:attributes) { { configurations: [nil] } }

          include_examples "nil element is invalid", :configurations, ["cthulhu fhtagn"]
        end

        context "when nil sits next to an invalid element" do
          let(:attributes) { { configurations: [nil, Configuration.new] } }

          include_examples "nil element is invalid", :configurations, ["cthulhu fhtagn"]
        end
      end
    end

    context "with a polymorphic array type" do
      let(:custom_product_class) do
        wrapper = polymorphic_wrapper
        build_custom_product_class do
          attribute :configurations, wrapper.to_array_type
          validates :configurations, store_model: { merge_array_errors: true }
        end
      end

      context "when nil sits next to an invalid element" do
        let(:attributes) { { configurations: [nil, Configuration.new] } }

        include_examples "nil element is invalid", :configurations, ["[0] is invalid", "[1] Color can't be blank"]
      end

      context "when the value is loaded from a JSON string" do
        let(:attributes) { { configurations: "[null]" } }

        include_examples "nil element is invalid", :configurations, ["[0] is invalid"]
      end
    end

    context "with a hash type" do
      let(:custom_product_class) do
        build_custom_product_class do
          attribute :configurations, Configuration.to_hash_type
          validates :configurations, store_model: true
        end
      end

      context "when the only value is nil" do
        let(:attributes) { { configurations: { "primary" => nil } } }

        include_examples "nil element is invalid", :configurations, ["is invalid"]
        include_examples "nil element is passed to the strategy as NilElement", :configurations, ["is invalid"]
      end

      context "when nil sits next to a valid value" do
        let(:attributes) { { configurations: { "primary" => nil, "secondary" => Configuration.new(color: "red") } } }

        include_examples "nil element is invalid", :configurations, ["is invalid"]
      end

      context "when nil sits next to an invalid value" do
        let(:attributes) { { configurations: { "primary" => nil, "secondary" => Configuration.new } } }

        include_examples "nil element is invalid", :configurations, ["is invalid"]

        it "still validates the other values" do
          expect(subject.configurations["secondary"].errors.messages).to eq(color: ["can't be blank"])
        end
      end

      context "when the value is loaded from a JSON string" do
        let(:attributes) { { configurations: '{"primary":null}' } }

        include_examples "nil element is invalid", :configurations, ["is invalid"]
      end

      context "with merge_hash_errors: true" do
        let(:custom_product_class) do
          build_custom_product_class do
            attribute :configurations, Configuration.to_hash_type
            validates :configurations, store_model: { merge_hash_errors: true }
          end
        end

        context "when the only value is nil" do
          let(:attributes) { { configurations: { "primary" => nil } } }

          include_examples "nil element is invalid", :configurations, ["[primary] is invalid"]
        end

        context "when nil sits next to an invalid value" do
          let(:attributes) { { configurations: { "primary" => nil, "secondary" => Configuration.new } } }

          include_examples "nil element is invalid", :configurations,
                           ["[primary] is invalid", "[secondary] Color can't be blank"]
        end
      end
    end

    context "with a polymorphic hash type" do
      let(:custom_product_class) do
        wrapper = polymorphic_wrapper
        build_custom_product_class do
          attribute :configurations, wrapper.to_hash_type
          validates :configurations, store_model: { merge_hash_errors: true }
        end
      end

      context "when nil sits next to an invalid value" do
        let(:attributes) { { configurations: { "primary" => nil, "secondary" => Configuration.new } } }

        include_examples "nil element is invalid", :configurations,
                         ["[primary] is invalid", "[secondary] Color can't be blank"]
      end

      context "when the value is loaded from a JSON string" do
        let(:attributes) { { configurations: '{"primary":null}' } }

        include_examples "nil element is invalid", :configurations, ["[primary] is invalid"]
      end
    end
  end
end
