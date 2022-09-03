# frozen_string_literal: true

require "spec_helper"

RSpec.describe StoreModel::Model do
  let(:attributes) do
    {
      color: "red",
      model: nil,
      active: false,
      disabled_at: Time.new(2019, 2, 10, 12)
    }
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

  describe "#fetch" do
    let(:instance) { Configuration.new(attributes) }
    let(:attributes) { { color: "blue" } }
    let(:attr_name) { :color }

    subject(:fetch) { instance.fetch(attr_name) }

    it { is_expected.to eq("blue") }

    context "when fetching a nil attribute" do
      let(:attr_name) { :model }

      it { is_expected.to be_nil }
    end

    context "when fetching an attribute that doesn't exist" do
      let(:attr_name) { :unknown_attribute }

      it "raises a KeyError" do
        expect { fetch }.to raise_error(KeyError, "key not found: :unknown_attribute")
      end
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

    context "with unknown attributes" do
      let(:type) { StoreModel::Types::One.new(Configuration) }
      let(:instance) { type.cast_value(attributes.merge(unknown_attributes)) }

      let(:unknown_attributes) do
        {
          archived: true
        }
      end

      shared_examples "with unknown attributes" do
        it("returns correct JSON") do
          is_expected.to eq(attributes.merge(unknown_attributes).as_json)
        end
      end

      shared_examples "without unknown attributes" do
        it("returns correct JSON") { is_expected.to eq(attributes.as_json) }
      end

      context "with default config about unknown attributes serialization" do
        include_examples "with unknown attributes"
      end

      context "with config set to serialize unknown attributes" do
        before do
          StoreModel.config.serialize_unknown_attributes = true
        end

        include_examples "with unknown attributes"
      end

      context "with config set not to serialize unknown attributes" do
        before do
          StoreModel.config.serialize_unknown_attributes = false
        end

        include_examples "without unknown attributes"
      end

      context "with config set to serialize unknown attributes overridden by option" do
        before do
          StoreModel.config.serialize_unknown_attributes = true
        end

        subject { instance.as_json(serialize_unknown_attributes: false) }

        include_examples "without unknown attributes"
      end

      context "with config set not to serialize unknown attributes overridden by option" do
        before do
          StoreModel.config.serialize_unknown_attributes = false
        end

        subject { instance.as_json(serialize_unknown_attributes: true) }

        include_examples "with unknown attributes"
      end
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
        "#<Configuration color: red, model: nil, active: false, " \
        "disabled_at: #{attributes[:disabled_at]}>"
      )
    end
  end

  describe "#parent" do
    let(:configuration) { Configuration.new }

    shared_examples "for singular type" do
      it "returns parent instance" do
        expect(subject.configuration.parent).to eq(subject)
      end

      it "updates parent after assignment" do
        subject.configuration = configuration
        expect(configuration.parent).to eq(subject)
      end
    end

    shared_examples "for array type" do
      it "returns parent instance" do
        expect(subject.configuration[0].parent).to eq(subject)
      end

      it "updates parent after assignment" do
        subject.configuration = [configuration]
        expect(configuration.parent).to eq(subject)
      end
    end

    context "json" do
      subject { custom_parent_class.new }

      context "activerecord model parent" do
        let(:custom_parent_class) do
          build_custom_product_class do
            attribute :configuration, Configuration.to_type
          end
        end

        include_examples "for singular type"
      end

      context "store model parent" do
        subject { custom_parent_class.new(configuration: {}) }

        let(:custom_parent_class) do
          Class.new do
            include StoreModel::Model

            attribute :configuration, Configuration.to_type
          end
        end

        include_examples "for singular type"
      end
    end

    context "array" do
      subject { custom_parent_class.new(configuration: [{}]) }

      context "activerecord model parent" do
        let(:custom_parent_class) do
          build_custom_product_class do
            attribute :configuration, Configuration.to_array_type
          end
        end

        include_examples "for array type"
      end

      context "store model parent" do
        let(:custom_parent_class) do
          Class.new do
            include StoreModel::Model

            attribute :configuration, Configuration.to_array_type
          end
        end

        include_examples "for array type"
      end
    end
  end

  shared_examples "comparing two instances" do
    let(:first_setting) { Configuration.new(color: "red") }

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

  describe "hash" do
    subject { first_setting.hash == second_setting.hash }

    include_examples "comparing two instances"
  end

  describe "==" do
    subject { first_setting == second_setting }

    include_examples "comparing two instances"
  end

  describe "eql?" do
    subject { first_setting.eql?(second_setting) }

    include_examples "comparing two instances"
  end

  describe "[]" do
    let(:attributes) { { color: "red" } }

    subject { Configuration.new(attributes) }

    it { expect(subject[:color]).to eq "red" }

    context "when string value is passed" do
      it { expect(subject["color"]).to eq "red" }
    end
  end

  describe "[]=" do
    let(:attributes) { { color: "red" } }

    subject { Configuration.new(attributes) }

    it do
      expect { subject[:color] = "black" }.to change { subject.color }.to("black")
    end

    context "when string value is passed" do
      it do
        expect { subject["color"] = "black" }.to change { subject.color }.to("black")
      end
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

    context "when alias attribute is passed" do
      let(:attribute) { :enabled }

      it { is_expected.to be_truthy }
    end
  end

  describe "predicate method for string attribute" do
    subject { Configuration.new(color: value).color? }

    context "when value is present" do
      let(:value) { "red" }

      it { is_expected.to eq(true) }
    end

    context "when value is nil" do
      let(:value) { nil }

      it { is_expected.to eq(false) }
    end

    context "when value is blank" do
      let(:value) { "" }

      it { is_expected.to eq(false) }
    end

    context "when value is \" \"" do
      let(:value) { " " }

      it { is_expected.to eq(false) }
    end
  end

  describe "predicate method for number attribute" do
    subject { Bicycle.new(gears: value).gears? }

    context "when value is 1" do
      let(:value) { 1 }

      it { is_expected.to eq(true) }
    end

    context "when value is nil" do
      let(:value) { nil }

      it { is_expected.to eq(false) }
    end

    context "when value is 0" do
      let(:value) { 0 }

      it { is_expected.to eq(false) }
    end
  end

  describe "predicate method for boolean attribute" do
    subject { Configuration.new(active: value).active? }

    context "when value is true" do
      let(:value) { true }

      it { is_expected.to eq(true) }
    end

    context "when value is nil" do
      let(:value) { nil }

      it { is_expected.to eq(false) }
    end

    context "when value is false" do
      let(:value) { false }

      it { is_expected.to eq(false) }
    end
  end
end
