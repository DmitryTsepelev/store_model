# frozen_string_literal: true

require "spec_helper"

RSpec.describe StoreModel::Types::HashPolymorphic do
  let(:configuration_v1) do
    Class.new do
      include StoreModel::Model

      attribute :version, :string, default: "v1"
      attribute :max_connections, :integer

      def self.to_s
        "V1"
      end
    end
  end

  let(:configuration_v2) do
    Class.new do
      include StoreModel::Model

      attribute :version, :string, default: "v2"
      attribute :max_connections, :integer
      attribute :timeout, :integer

      def self.to_s
        "V2"
      end
    end
  end

  let(:configuration_proc) do
    proc do |json|
      case json[:version] || json["version"]
      when "v1" then configuration_v1
      when "v2" then configuration_v2
      else configuration_v1
      end
    end
  end

  let(:type) { described_class.new(configuration_proc) }

  let(:attributes_hash) do
    {
      "primary" => {
        version: "v1",
        max_connections: 10
      },
      "secondary" => {
        version: "v2",
        max_connections: 20,
        timeout: 30
      }
    }
  end

  describe "#type" do
    subject { type.type }

    it { is_expected.to eq(:polymorphic_hash) }
  end

  describe "#cast_value" do
    subject { type.cast_value(value) }

    shared_examples "cast examples" do
      it { is_expected.to be_a(Hash) }

      it "has correct keys" do
        expect(subject.keys).to eq(%w[primary secondary])
      end

      it "casts to correct model types" do
        expect(subject["primary"]).to be_a(configuration_v1)
        expect(subject["secondary"]).to be_a(configuration_v2)
      end

      it "assigns attributes correctly" do
        expect(subject["primary"]).to have_attributes(
          version: "v1",
          max_connections: 10
        )

        expect(subject["secondary"]).to have_attributes(
          version: "v2",
          max_connections: 20,
          timeout: 30
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
        {
          "primary" => configuration_v1.new(attributes_hash["primary"]),
          "secondary" => configuration_v2.new(attributes_hash["secondary"])
        }
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

    context "when empty hash is passed" do
      let(:value) { {} }

      it { is_expected.to eq({}) }
    end

    context "when mixed model types in hash" do
      let(:value) do
        {
          "v1_config" => { version: "v1", max_connections: 5 },
          "v2_config" => { version: "v2", max_connections: 10, timeout: 15 },
          "default" => { max_connections: 1 }
        }
      end

      it "casts each value to appropriate type" do
        expect(subject["v1_config"]).to be_a(configuration_v1)
        expect(subject["v2_config"]).to be_a(configuration_v2)
        expect(subject["default"]).to be_a(configuration_v1) # default case
      end
    end

    context "when model wrapper returns invalid class" do
      let(:configuration_proc) do
        proc { |_json| String }
      end

      let(:value) { { "key" => { data: "test" } } }

      it "raises ExpandWrapperError" do
        expect { subject }.to raise_error(
          StoreModel::Types::ExpandWrapperError,
          /String is an invalid model klass/
        )
      end
    end

    context "when invalid type is passed" do
      let(:value) { [] }

      it "raises CastError" do
        expect { subject }.to raise_error(
          StoreModel::Types::CastError,
          /failed casting \[\], only String, Hash or instances which implement StoreModel::Model are allowed/
        )
      end
    end

    context "with nil values in hash" do
      let(:value) do
        {
          "primary" => { version: "v1", max_connections: 10 },
          "empty" => nil
        }
      end

      it "preserves nil values" do
        expect(subject["empty"]).to be_nil
      end

      it "casts non-nil values" do
        expect(subject["primary"]).to be_a(configuration_v1)
      end
    end
  end

  describe "#serialize" do
    subject { type.serialize(value) }

    context "when Hash of instances is passed" do
      let(:value) do
        {
          "primary" => configuration_v1.new(version: "v1", max_connections: 10),
          "secondary" => configuration_v2.new(version: "v2", max_connections: 20, timeout: 30)
        }
      end

      it { is_expected.to be_a(String) }

      it "serializes correctly" do
        parsed = JSON.parse(subject)
        expect(parsed["primary"]).to include("version" => "v1", "max_connections" => 10)
        expect(parsed["secondary"]).to include("version" => "v2", "max_connections" => 20, "timeout" => 30)
      end
    end

    context "when empty hash is passed" do
      let(:value) { {} }

      it { is_expected.to eq("{}") }
    end
  end

  describe "#changed_in_place?" do
    let(:configurations) do
      {
        "primary" => configuration_v1.new(version: "v1", max_connections: 10),
        "secondary" => configuration_v2.new(version: "v2", max_connections: 20)
      }
    end

    it "marks object as changed" do
      expect(type.changed_in_place?({}, configurations)).to be_truthy
    end
  end
end
