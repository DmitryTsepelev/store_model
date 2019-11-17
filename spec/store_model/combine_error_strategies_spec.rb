# frozen_string_literal: true

require "spec_helper"

RSpec.describe StoreModel::CombineErrorsStrategies do
  describe ".configure" do
    LAMBDA_FHTAGN_STRATEGY =
      lambda do |attribute, base_errors, _store_model_errors|
        base_errors.add(attribute, "cthulhu fhtagn")
      end

    subject { described_class.configure(options) }

    context "when empty hash is passed" do
      let(:options) { {} }

      it { is_expected.to be_a(StoreModel::CombineErrorsStrategies::MarkInvalidErrorStrategy) }
    end

    context "when true is passed" do
      let(:options) { { merge_errors: true } }

      it { is_expected.to be_a(StoreModel::CombineErrorsStrategies::MergeErrorStrategy) }
    end

    context "when custom strategy class name is passed" do
      let(:options) { { merge_errors: :fhtagn_error_strategy } }

      it { is_expected.to be_a(FhtagnErrorStrategy) }
    end

    context "when instance of custom strategy class is passed" do
      let(:options) { { merge_errors: FhtagnErrorStrategy.new } }

      it { is_expected.to be_a(FhtagnErrorStrategy) }
    end

    context "when labmda is passed" do
      let(:options) { { merge_errors: LAMBDA_FHTAGN_STRATEGY } }

      it { is_expected.to eq(LAMBDA_FHTAGN_STRATEGY) }
    end
  end

  describe ".configure_array" do
    LAMBDA_FHTAGN_STRATEGY =
      lambda do |attribute, base_errors, _store_model|
        base_errors.add(attribute, "cthulhu fhtagn")
      end

    subject { described_class.configure_array(options) }

    context "when empty hash is passed" do
      let(:options) { {} }

      it { is_expected.to be_a(StoreModel::CombineErrorsStrategies::MarkInvalidErrorStrategy) }
    end

    context "when true is passed" do
      let(:options) { { merge_array_errors: true } }

      it { is_expected.to be_a(StoreModel::CombineErrorsStrategies::MergeArrayErrorStrategy) }
    end

    context "when custom strategy class name is passed" do
      let(:options) { { merge_array_errors: :fhtagn_error_strategy } }

      it { is_expected.to be_a(FhtagnErrorStrategy) }
    end

    context "when instance of custom strategy class is passed" do
      let(:options) { { merge_array_errors: FhtagnErrorStrategy.new } }

      it { is_expected.to be_a(FhtagnErrorStrategy) }
    end

    context "when labmda is passed" do
      let(:options) { { merge_array_errors: LAMBDA_FHTAGN_STRATEGY } }

      it { is_expected.to eq(LAMBDA_FHTAGN_STRATEGY) }
    end
  end
end
