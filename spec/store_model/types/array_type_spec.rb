# frozen_string_literal: true

require "spec_helper"

RSpec.describe StoreModel::Types::ArrayType do
  let(:type) { described_class.new(Configuration) }

  let(:attributes_array) do
    [
      {
        color: "red",
        disabled_at: Time.new(2019, 2, 22, 12, 30)
      },
      {
        color: "green",
        disabled_at: Time.new(2019, 3, 12, 8, 10)
      }
    ]
  end

  describe "#type" do
    subject { type.type }

    it { is_expected.to eq(:array) }
  end

  describe "#changed_in_place?" do
    let(:configurations) do
      attributes_array.map { |attributes| Configuration.new(attributes) }
    end

    it "marks object as changed" do
      expect(type.changed_in_place?([], configurations)).to be_truthy
    end
  end

  describe "#cast_value" do
    shared_examples "cast examples" do
      subject { type.cast_value(value) }

      it { is_expected.to be_a(Array) }
      it "assigns attributes" do
        subject.zip(attributes_array).each do |config, config_attributes|
          expect(config).to have_attributes(config_attributes)
        end
      end
    end

    context "when String is passed" do
      let(:value) { ActiveSupport::JSON.encode(attributes_array) }
      include_examples "cast examples"
    end

    context "when Array of hashes is passed" do
      let(:value) { attributes_array }
      include_examples "cast examples"
    end

    context "when Array of instances is passed" do
      let(:value) { attributes_array.map { |attrs| Configuration.new(attrs) } }
      include_examples "cast examples"
    end
  end

  describe "#serialize" do
    shared_examples "serialize examples" do
      subject { type.serialize(value) }

      it { is_expected.to be_a(String) }
      it "is equal to attributes" do
        expect(subject).to eq(ActiveSupport::JSON.encode(attributes_array))
      end
    end

    context "when Array is passed" do
      let(:value) { attributes_array }
      include_examples "serialize examples"
    end

    context "when String is passed" do
      let(:value) { ActiveSupport::JSON.encode(attributes_array) }
      include_examples "serialize examples"
    end
  end
end
