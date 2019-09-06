# frozen_string_literal: true

require "spec_helper"

RSpec.describe StoreModel::Model do
  let(:attributes) do
    { color: "red", disabled_at: Time.new(2019, 2, 10, 12) }
  end

  describe "#initialize" do
    context "when symbolized hash is passed" do
      subject { Configuration.new(attributes) }

      it("assigns attributes") { is_expected.to have_attributes(attributes) }
    end

    context "when stringified hash is passed" do
      subject { Configuration.new(attributes.stringify_keys) }

      it("assigns attributes") { is_expected.to have_attributes(attributes) }
    end
  end

  describe "#as_json" do
    let(:instance) { Configuration.new(attributes) }

    subject { instance.as_json }

    it("returns correct JSON") { is_expected.to eq(attributes.as_json) }

    context "with only" do
      subject { instance.as_json(only: %i[color]) }

      it("returns correct JSON") { is_expected.to eq(attributes.slice(:color).as_json) }
    end
  end

  describe "#blank?" do
    subject { Configuration.new(color: nil).blank? }

    it { is_expected.to be_truthy }
  end

  describe "#inspect" do
    subject { Configuration.new(attributes).inspect }

    it "prints description" do
      expect(subject).to eq(
        "#<Configuration color: red, disabled_at: #{attributes[:disabled_at]}>"
      )
    end
  end

  describe "==" do
    let(:first_setting) { Configuration.new(color: "red") }

    subject { first_setting == second_setting }

    context "when two instances have same attributes" do
      let(:second_setting) { Configuration.new(color: "red") }

      it { is_expected.to be true }
    end

    context "when two instances have different attributes" do
      let(:second_setting) { Configuration.new(color: "black") }

      it { is_expected.to be false }
    end

    context "when StoreModel has enum attribute" do
      let(:config_class) do
        Class.new do
          include StoreModel::Model

          enum :status, in: { active: 1, archived: 0 }
        end
      end

      let(:first_setting) { config_class.new(status: :active) }

      subject { first_setting == second_setting }

      context "when two instances have same attributes" do
        let(:second_setting) { config_class.new(status: :active) }

        it { is_expected.to be true }
      end

      context "when two instances have different attributes" do
        let(:second_setting) { config_class.new(status: :archived) }

        it { is_expected.to be false }
      end
    end
  end

  describe ".parent" do
    subject { custom_product_class.new }

    let(:custom_product_class) do
      build_custom_product_class do
        attribute :configuration, Configuration.to_type
      end
    end

    it "returns parent instance" do
      expect(subject.configuration.parent).to eq(subject)
    end
  end

  describe ".to_type" do
    subject { custom_product_class.new }

    let(:custom_product_class) do
      build_custom_product_class do
        attribute :configuration, Configuration.to_type
      end
    end

    it "configures type using field name" do
      expect(subject.configuration).to be_a_kind_of(Configuration)
    end
  end

  describe ".to_array_type" do
    subject { custom_product_class.new }

    let(:custom_product_class) do
      build_custom_product_class do
        attribute :configuration, Configuration.to_array_type
      end
    end

    it "configures type using field name" do
      expect(subject.configuration).to be_a_kind_of(Array)
    end
  end

  describe "#has_attribute?" do
    let(:attribute) { :color }
    subject { Configuration.new.has_attribute?(attribute) }

    it { is_expected.to be_truthy }

    context "when string value is passed" do
      let(:attribute) { "color" }

      it { is_expected.to be_truthy }
    end

    context "when not defined attribute is passed" do
      let(:attribute) { :tone }

      it { is_expected.to be_falsey }
    end
  end
end
