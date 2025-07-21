# frozen_string_literal: true

require "spec_helper"

RSpec.describe StoreModel::Types::Hash do
  let(:type) { described_class.new(Configuration) }

  let(:attributes_hash) do
    {
      "primary" => {
        color: "red",
        model: nil,
        active: true,
        disabled_at: Time.new(2019, 2, 22, 12, 30).utc,
        encrypted_serial: nil,
        type: "left"
      },
      "secondary" => {
        color: "green",
        model: nil,
        active: false,
        disabled_at: Time.new(2019, 3, 12, 8, 10).utc,
        encrypted_serial: nil,
        type: "right"
      }
    }
  end

  describe "#type" do
    subject { type.type }

    it { is_expected.to eq(:hash) }
  end

  describe "#changed_in_place?" do
    let(:configurations) do
      attributes_hash.transform_values { |attributes| Configuration.new(attributes) }
    end

    it "marks object as changed" do
      expect(type.changed_in_place?({}, configurations)).to be_truthy
    end
  end

  describe "#cast_value" do
    subject { type.cast_value(value) }

    shared_examples "cast examples" do
      it { is_expected.to be_a(Hash) }

      it "has correct keys" do
        expect(subject.keys).to eq(%w[primary secondary])
      end

      it "assigns attributes" do
        configuration = subject["primary"]

        expect(configuration).to be_a(Configuration)
        expect(configuration).to have_attributes(
          color: "red",
          active: true,
          disabled_at: Time.new(2019, 2, 22, 12, 30).utc,
          type: "left"
        )
      end
    end

    context "when String is passed" do
      let(:value) { attributes_hash.to_json }

      include_examples "cast examples"
    end

    context "when Hash is passed" do
      let(:value) { attributes_hash }

      include_examples "cast examples"
    end

    context "when Hash of instances is passed" do
      let(:value) do
        attributes_hash.transform_values { |attrs| Configuration.new(attrs) }
      end

      include_examples "cast examples"

      it "keeps instances intact" do
        expect(subject["primary"]).to equal(value["primary"])
        expect(subject["secondary"]).to equal(value["secondary"])
      end
    end

    context "when nil is passed" do
      let(:value) { nil }

      it { is_expected.to be_nil }
    end

    context "when instance of illegal class is passed" do
      let(:value) { [] }

      it "raises exception" do
        expect { subject }.to raise_error(
          StoreModel::Types::CastError,
          "failed casting [], only String or Hash instances are allowed"
        )
      end
    end

    context "when some keys have nil values" do
      let(:value) do
        {
          "primary" => attributes_hash["primary"],
          "empty" => nil
        }
      end

      it "casts non-nil values" do
        expect(subject["primary"]).to be_a(Configuration)
      end

      it "preserves nil values" do
        expect(subject["empty"]).to be_nil
      end
    end

    context "when JSON is invalid" do
      let(:value) { "invalid_json" }

      it "returns empty hash" do
        expect(subject).to eq({})
      end
    end

    context "with unknown attributes" do
      let(:value) do
        {
          "primary" => attributes_hash["primary"].merge(unknown_attribute: "value")
        }
      end

      it "handles unknown attributes based on model settings" do
        expect { subject }.not_to raise_error
      end
    end
  end

  describe "#serialize" do
    subject { type.serialize(value) }

    shared_examples "serialize examples" do
      it { is_expected.to be_a(String) }

      it "is equal to attributes hash JSON" do
        expect(subject).to eq(attributes_hash.to_json)
      end
    end

    context "when Hash of instances is passed" do
      let(:value) do
        attributes_hash.transform_values { |attrs| Configuration.new(attrs) }
      end

      include_examples "serialize examples"
    end

    context "when Hash is passed" do
      let(:value) { attributes_hash }

      include_examples "serialize examples"
    end

    context "when String is passed" do
      let(:value) { attributes_hash.to_json }

      it { is_expected.to eq(value) }
    end

    context "when nil is passed" do
      let(:value) { nil }

      it { is_expected.to be_nil }
    end

    context "when empty hash is passed" do
      let(:value) { {} }

      it { is_expected.to eq("{}") }
    end

    context "when hash with mixed types is passed" do
      let(:value) do
        {
          "primary" => Configuration.new(attributes_hash["primary"]),
          "raw" => { some: "data" }
        }
      end

      it "serializes to JSON" do
        parsed = JSON.parse(subject)
        expect(parsed["primary"]).to eq(JSON.parse(attributes_hash["primary"].to_json))
        expect(parsed["raw"]).to eq({ "some" => "data" })
      end
    end
  end
end
