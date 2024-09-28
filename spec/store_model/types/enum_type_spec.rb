# frozen_string_literal: true

require "spec_helper"

RSpec.describe StoreModel::Types::EnumType do
  let(:type) { described_class.new({ active: 1, archived: 0 }, raise_on_invalid_values) }
  let(:float_type) { described_class.new({ pi: 3.14, tau: 6.28 }, raise_on_invalid_values) }
  let(:raise_on_invalid_values) { true }

  describe "#type" do
    subject { type.type }

    it { is_expected.to eq(:integer) }
  end

  describe "#cast_value" do
    subject { type.cast_value(value) }

    context "when String is passed" do
      let(:value) { "active" }

      it { is_expected.to eq(1) }

      context "when value is not in the list" do
        let(:value) { "reactive" }

        context "when raise_on_invalid_values is true" do
          it "raises exception" do
            expect { subject }.to raise_error(
              ArgumentError,
              "invalid value '#{value}' is assigned"
            )
          end
        end

        context "when raise_on_invalid_values is false" do
          let(:raise_on_invalid_values) { false }

          it { is_expected.to eq(value) }
        end
      end
    end

    context "when Symbol is passed" do
      let(:value) { :active }

      it { is_expected.to eq(1) }

      context "when value is not in the list" do
        let(:value) { :reactive }

        context "when raise_on_invalid_values is true" do
          it "raises exception" do
            expect { subject }.to raise_error(
              ArgumentError,
              "invalid value '#{value}' is assigned"
            )
          end
        end

        context "when raise_on_invalid_values is false" do
          let(:raise_on_invalid_values) { false }

          it { is_expected.to eq(value) }
        end
      end
    end

    context "when Integer is passed" do
      let(:value) { 1 }

      it { is_expected.to eq(1) }

      context "when value is not in the list" do
        let(:value) { 5 }

        context "when raise_on_invalid_values is true" do
          it "raises exception" do
            expect { subject }.to raise_error(
              ArgumentError,
              "invalid value '#{value}' is assigned"
            )
          end
        end

        context "when raise_on_invalid_values is false" do
          let(:raise_on_invalid_values) { false }

          it { is_expected.to eq(value) }
        end
      end
    end

    context "when nil is passed" do
      let(:value) { nil }

      it { is_expected.to be_nil }
    end
  end

  describe "float#cast_value" do
    subject { float_type.cast_value(value) }

    context "when Float is passed" do
      let(:value) { 3.14 }

      it { is_expected.to eq(3.14) }

      context "when value is not in the list" do
        let(:value) { 1.5 }

        context "when raise_on_invalid_values is true" do
          it "raises exception" do
            expect { subject }.to raise_error(
              ArgumentError,
              "invalid value '#{value}' is assigned"
            )
          end
        end

        context "when raise_on_invalid_values is false" do
          let(:raise_on_invalid_values) { false }

          it { is_expected.to eq(value) }
        end
      end
    end
  end
end
