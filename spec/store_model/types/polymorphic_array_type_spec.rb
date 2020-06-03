# frozen_string_literal: true

require "spec_helper"

RSpec.describe StoreModel::Types::PolymorphicArrayType do
  let(:type) { described_class.new(Proc.new { Configuration }) }

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

    it { is_expected.to eq(:polymorphic_array) }
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
    subject { type.cast_value(value) }

    shared_examples "cast examples" do
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

    context "when nil is passed" do
      let(:value) { nil }

      it { is_expected.to be_nil }
    end

    context "when instance of illegal class is passed" do
      let(:value) { {} }

      it "raises exception" do
        expect { type.cast_value(value) }.to raise_error(
          StoreModel::Types::CastError,
          "failed casting {}, only String or Array instances are allowed"
        )
      end
    end

    context "when some keys are not defined as attributes" do
      shared_examples "for unknown attributes" do
        it { is_expected.to be_a(Array) }

        it "assigns attributes" do
          expect(subject.first).to have_attributes(color: "red")
          expect(subject.second).to have_attributes(color: "green")
        end

        it "assigns unknown_attributes" do
          expect(subject.first.unknown_attributes).to eq(
            "unknown_attribute" => "something", "one_more" => "anything"
          )
          expect(subject.second.unknown_attributes).to eq(
            "unknown_attribute" => "something greeny", "one_more" => "anything greeny"
          )
        end
      end

      let(:attributes_array) do
        [
          {
            color: "red",
            unknown_attribute: "something",
            one_more: "anything"
          },
          {
            color: "green",
            unknown_attribute: "something greeny",
            one_more: "anything greeny"
          }
        ]
      end

      context "when Hash is passed" do
        let(:value) { attributes_array }
        include_examples "for unknown attributes"
      end

      context "when String is passed" do
        let(:value) { ActiveSupport::JSON.encode(attributes_array) }
        include_examples "for unknown attributes"
      end
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
