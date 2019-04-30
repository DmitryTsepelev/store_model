# frozen_string_literal: true

require "spec_helper"

RSpec.describe StoreModel::Types::JsonType do
  let(:type) { described_class.new(Configuration) }

  let(:attributes) do
    {
      color: "red",
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
    shared_examples "cast examples" do
      subject { type.cast_value(value) }

      it { is_expected.to be_a(Configuration) }
      it("assigns attributes") { is_expected.to have_attributes(attributes) }
    end

    context "when String is passed" do
      let(:value) { ActiveSupport::JSON.encode(attributes) }
      include_examples "cast examples"
    end

    context "when Hash is passed" do
      let(:value) { attributes }
      include_examples "cast examples"
    end

    context "when Configuration instance is passed" do
      let(:value) { Configuration.new(attributes) }
      include_examples "cast examples"
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
