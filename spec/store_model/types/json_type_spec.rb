# frozen_string_literal: true

require "spec_helper"

RSpec.describe StoreModel::Types::JsonType do
  let(:type) { described_class.new(Configuration) }

  let(:attributes) do
    {
      color: "red",
      model: nil,
      active: false,
      disabled_at: Time.new(2019, 2, 22, 12, 30)
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
      let(:value) { [] }

      it "raises exception" do
        expect { type.cast_value(value) }.to raise_error(
          StoreModel::Types::CastError,
          "failed casting [], only String, Hash or Configuration instances are allowed"
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
      include_examples "serialize examples"
    end
  end
end
