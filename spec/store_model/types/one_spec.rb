# frozen_string_literal: true

require "spec_helper"

RSpec.describe StoreModel::Types::One do
  let(:type) { described_class.new(Configuration) }

  let(:attributes) do
    {
      color: "red",
      model: nil,
      active: false,
      disabled_at: Time.new(2019, 2, 22, 12, 30).utc,
      encrypted_serial: nil,
      type: "left"
    }
  end

  describe "#type" do
    subject { type.type }

    it { is_expected.to eq(:json) }
  end

  describe "#changed_in_place?" do
    it "marks object as changed" do
      expect(type.changed_in_place?({}, Configuration.new(attributes))).to be_truthy
    end
  end

  describe "#cast_value" do
    subject { type.cast_value(value) }

    shared_examples "for known attributes" do
      it { is_expected.to be_a(Configuration) }
      it("assigns attributes") { is_expected.to have_attributes(attributes) }
    end

    context "when Hash is passed" do
      let(:value) { attributes }
      include_examples "for known attributes"
    end

    context "when String is passed" do
      let(:value) { ActiveSupport::JSON.encode(attributes) }
      include_examples "for known attributes"
    end

    context "when Configuration instance is passed" do
      let(:value) { Configuration.new(attributes) }
      include_examples "for known attributes"
    end

    context "when nil is passed" do
      let(:value) { nil }

      it { is_expected.to be_nil }
    end

    context "when instance of illegal class is passed" do
      let(:value) { 1 }

      it "raises exception" do
        expect { type.cast_value(value) }.to raise_error(
          StoreModel::Types::CastError,
          "failed casting 1, only String, Hash or Configuration instances are allowed"
        )
      end
    end

    context "when some keys are not defined as attributes" do
      shared_examples "for unknown attributes" do
        it { is_expected.to be_a(Configuration) }

        it("assigns attributes") { is_expected.to have_attributes(color: "red") }

        it "assigns unknown_attributes" do
          expect(subject.unknown_attributes).to eq(
            "unknown_attribute" => "something", "one_more" => "anything"
          )
        end
      end

      let(:attributes) { { color: "red", unknown_attribute: "something", one_more: "anything" } }

      context "when Hash is passed" do
        let(:value) { attributes }
        include_examples "for unknown attributes"
      end

      context "when String is passed" do
        let(:value) { ActiveSupport::JSON.encode(attributes) }
        include_examples "for unknown attributes"
      end

      context "when saving model" do
        subject { persisted_product.configuration }

        let(:custom_product_class) do
          build_custom_product_class do
            attribute :configuration, Configuration.to_type
          end
        end

        let(:persisted_product) do
          custom_product_class.create(
            configuration: Configuration.to_type.cast_value(attributes)
          )
        end

        include_examples "for unknown attributes"
      end

      context "when unknown keys are inside nested model" do
        shared_examples "for unknown nested attributes" do
          it { is_expected.to be_a(configuration_class) }

          it("assigns attributes") { is_expected.to have_attributes(color: "red") }

          it "assigns unknown_attributes" do
            expect(subject.suppliers.first.unknown_attributes).to eq(
              "unknown_attribute" => "something"
            )
          end
        end

        let(:configuration_class) do
          Class.new do
            include StoreModel::Model

            attribute :color, :string
            attribute :suppliers, Supplier.to_array_type

            accepts_nested_attributes_for :suppliers
          end
        end

        let(:type) { described_class.new(configuration_class) }

        let(:supplier) { { unknown_attribute: "something" } }
        let(:attributes) { { color: "red", suppliers: [supplier] } }

        context "when Hash is passed" do
          let(:value) { attributes }
          include_examples "for unknown nested attributes"
        end

        context "when Hash is passed with :attributes key" do
          let(:value) { attributes }
          let(:supplier) { { attributes: { unknown_attribute: "something" } } }
          include_examples "for unknown nested attributes"
        end

        context "when Hash is passed with :attributes key and other keys" do
          let(:value) { attributes }
          let(:supplier) do
            {
              attributes: { unknown_attribute: "something" },
              other_unknown_attribute: "will be entirely ignored"
            }
          end
          include_examples "for unknown nested attributes"
        end

        context "when String is passed" do
          let(:value) { ActiveSupport::JSON.encode(attributes) }
          include_examples "for unknown nested attributes"
        end
      end
    end
  end

  describe "#serialize" do
    shared_examples "serialize examples" do
      subject { type.serialize(value) }

      it { is_expected.to be_a(String) }

      it("is equal to attributes") { is_expected.to eq(attributes.to_json) }
    end

    context "when Hash is passed" do
      let(:value) { attributes }

      include_examples "serialize examples"
    end

    context "when String is passed" do
      let(:value) { ActiveSupport::JSON.encode(attributes) }

      include_examples "serialize examples"
    end

    context "when Configuration instance is passed" do
      let(:value) { Configuration.new(attributes) }

      subject { type.serialize(value) }

      it { is_expected.to be_a(String) }

      it("is equal to attributes") { is_expected.to eq(attributes.to_json) }

      context "with unknown attributes" do
        before do
          value.unknown_attributes[:archived] = true
        end

        [true, false].each do |serialize_unknown_attributes|
          it "always includes unknown attributes regardless of the serialize_unknown_attributes option" do
            StoreModel.config.serialize_unknown_attributes = serialize_unknown_attributes
            expect(subject).to eq(attributes.merge(value.unknown_attributes).to_json)
          end
        end

        context "when serialize_unknown_attributes attribute of instance is set to true" do
          it "includes unknown attributes by overriding the globally configured behavior" do
            value.serialize_unknown_attributes = true
            expect(subject).to eq(attributes.merge(value.unknown_attributes).to_json)
          end
        end

        context "when serialize_unknown_attributes attribute of instance is set to false" do
          it "does not include unknown attributes by overriding the globally configured behavior" do
            value.serialize_unknown_attributes = false
            expect(subject).to eq(attributes.to_json)
          end
        end
      end

      context "when empty serialize_empty_attributes is off" do
        before do
          StoreModel.config.serialize_empty_attributes = false
        end

        it "does not serialize empty attributes" do
          expect(subject).to eq(attributes.except(:model, :encrypted_serial).to_json)
        end
      end

      context "with enums" do
        context "when serialize_enums_using_as_json attribute of instance is set to true" do
          it "serializes enums by overriding the globally configured behavior" do
            value.serialize_enums_using_as_json = true
            expect(subject).to eq(attributes.merge(type: "left").to_json)
          end
        end

        context "when serialize_enums_using_as_json attribute of instance is set to false" do
          it "does not serialize enums by overriding the globally configured behavior" do
            value.serialize_enums_using_as_json = false
            expect(subject).to eq(attributes.merge(type: 1).to_json)
          end
        end
      end
    end
  end

  describe "#deserialize" do
    describe "when an empty string is passed" do
      let(:value) { "" }

      subject { type.deserialize(value) }

      it { is_expected.to be_a(Configuration) }

      it("is equal to an empty model") { is_expected.to eq(Configuration.new) }
    end

    describe "when a malformed JSON string is passed" do
      let(:value) { "{/sdfgsdfre}" }

      subject { type.deserialize(value) }

      it { is_expected.to be_a(Configuration) }

      it("is equal to an empty model") { is_expected.to eq(Configuration.new) }
    end
  end
end
