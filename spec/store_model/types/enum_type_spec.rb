# frozen_string_literal: true

require "spec_helper"

RSpec.describe StoreModel::Types::EnumType do
  let(:type) { described_class.new(active: 1, archived: 0) }

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

        it "raises exception" do
          expect { subject }.to raise_error(
            ArgumentError,
            "invalid value '#{value}' is assigned"
          )
        end
      end
    end

    context "when Symbol is passed" do
      let(:value) { :active }

      it { is_expected.to eq(1) }

      context "when value is not in the list" do
        let(:value) { :reactive }

        it "raises exception" do
          expect { subject }.to raise_error(
            ArgumentError,
            "invalid value '#{value}' is assigned"
          )
        end
      end
    end

    context "when Integer is passed" do
      let(:value) { 1 }

      it { is_expected.to eq(1) }

      context "when value is not in the list" do
        let(:value) { 5 }

        it "raises exception" do
          expect { subject }.to raise_error(
            ArgumentError,
            "invalid value '#{value}' is assigned"
          )
        end
      end
    end

    context "when nil is passed" do
      let(:value) { nil }

      it { is_expected.to be_nil }
    end

    context "when instance of illegal class is passed" do
      let(:value) { 3.5 }

      it "raises exception" do
        expect { subject }.to raise_error(
          StoreModel::Types::CastError,
          "failed casting #{value}, only String, Symbol or Integer instances are allowed"
        )
      end
    end
  end
end
