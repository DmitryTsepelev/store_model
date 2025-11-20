# frozen_string_literal: true

require "spec_helper"

RSpec.describe StoreModel::Model do
  let(:attributes) do
    {
      color: "red",
      model: nil,
      active: false,
      disabled_at: Time.new(2019, 2, 10, 12).utc,
      encrypted_serial: nil,
      type: "left"
    }
  end

  describe ".from_value" do
    context "when unknown attributes are provided" do
      it "adds unknown attributes" do
        config = Configuration.from_value(attributes.merge(foo: "bar"))
        expect(config.unknown_attributes).to include("foo" => "bar")
      end
    end
  end

  describe ".from_values" do
    context "when unknown attributes are provided" do
      it "adds unknown attributes" do
        config = Configuration.from_values([attributes.merge(foo: "bar")])
        expect(config[0].unknown_attributes).to include("foo" => "bar")
      end
    end
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

    context "when attributes contain a field with a custom type" do
      subject { Configuration.new(attributes) }

      let(:attributes) do
        {
          color: "red",
          model: nil,
          active: false,
          disabled_at: Time.new(2019, 2, 10, 12).utc,
          encrypted_serial: "111-222"
        }
      end

      it("assigns attributes") { is_expected.to have_attributes(attributes) }
    end

    context "when hash-like other class passed" do
      subject do
        class Product < ActiveRecord::Base
          attribute :configuration, Configuration.to_type
        end

        Product.new(configuration: attributes)
      end

      let(:attributes) do
        class NotHash
          def initialize(attrs)
            @attrs = attrs
          end

          def to_h
            @attrs
          end
        end
        NotHash.new(
          color: "red",
          model: nil,
          active: false,
          disabled_at: Time.new(2019, 2, 10, 12).utc,
          encrypted_serial: "111-222"
        )
      end

      it("assigns attributes") do
        expect(subject.configuration).to have_attributes(attributes.to_h)
      end
    end

    if ActiveModel::VERSION::MAJOR >= 8 && ActiveModel::VERSION::MINOR >= 1
      context "when normalization available" do
        subject { Bicycle.new(sku: "foobar") }

        it("calls given normalizer") do
          expect(subject.sku).to eq("FOOBAR")
        end
      end
    end
  end

  describe "#fetch" do
    let(:instance) { MethodModel.new(attributes) }
    let(:attributes) { { gear: "blue" } }
    let(:attr_name) { :gear }

    subject(:fetch) { instance.fetch(attr_name) }

    it { is_expected.to eq("blue") }

    context "when fetching an alias attribute" do
      it { is_expected.to eq("blue") }
    end

    context "when fetching a nil attribute" do
      let(:attr_name) { :tire }

      it { is_expected.to be_nil }
    end

    context "when fetching an attribute that doesn't exist" do
      let(:attr_name) { :unknown_attribute }

      it "raises a KeyError" do
        expect { fetch }.to raise_error(KeyError)
      end
    end
  end

  describe "#as_json" do
    let(:instance) { Configuration.new(attributes) }

    subject { instance.as_json }

    it("returns correct JSON") { is_expected.to eq(attributes.as_json) }

    context "when serialize_enums_using_as_json is off" do
      before do
        StoreModel.config.serialize_enums_using_as_json = false
      end

      it("returns correct JSON") { is_expected.to eq(attributes.merge(type: 1).as_json) }
    end

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

    context "when serialize_empty_attributes is off" do
      before do
        StoreModel.config.serialize_empty_attributes = false
      end

      it("returns correct JSON") { is_expected.to eq(attributes.except(:model, :encrypted_serial).as_json) }
    end
  end

  describe "#blank?" do
    subject { Configuration.new(active: nil).blank? }

    it { is_expected.to be_truthy }
  end

  describe "#inspect" do
    subject { Configuration.new(attributes).inspect }

    it "prints description" do
      expect(subject).to eq(
        "#<Configuration color: \"red\", model: nil, active: false, " \
        "disabled_at: #{attributes[:disabled_at]}, encrypted_serial: nil, type: 1>"
      )
    end
  end

  describe "#parent" do
    let(:configuration) { Configuration.new }

    shared_examples "for singular type" do
      it "returns parent instance" do
        if StoreModel.config.enable_parent_assignment
          expect(subject.configuration.parent).to eq(subject)
        else
          expect(subject.configuration.parent).to be_nil
        end
      end

      it "updates parent after assignment" do
        subject.configuration = configuration
        if StoreModel.config.enable_parent_assignment
          expect(configuration.parent).to eq(subject)
        else
          expect(configuration.parent).to be_nil
        end
      end

      it "uses defaults" do
        expect(subject.configuration.active).to be(true)
      end
    end

    shared_examples "for array type" do
      it "returns parent instance" do
        if StoreModel.config.enable_parent_assignment
          expect(subject.configuration[0].parent).to eq(subject)
        else
          expect(subject.configuration[0].parent).to be_nil
        end
      end

      it "updates parent after assignment" do
        subject.configuration = [configuration]
        if StoreModel.config.enable_parent_assignment
          expect(configuration.parent).to eq(subject)
        else
          expect(configuration.parent).to be_nil
        end
      end
    end

    shared_examples "for hash type" do
      it "returns parent instance" do
        if StoreModel.config.enable_parent_assignment
          expect(subject.configuration[:foo].parent).to eq(subject)
        else
          expect(subject.configuration[:foo].parent).to be_nil
        end
      end

      it "updates parent after assignment" do
        subject.configuration = { "foo" => configuration }
        if StoreModel.config.enable_parent_assignment
          expect(configuration.parent).to eq(subject)
        else
          expect(configuration.parent).to be_nil
        end
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

    context "hash" do
      subject { custom_parent_class.new(configuration: { foo: { bar: :baz } }) }

      context "activerecord model parent" do
        let(:custom_parent_class) do
          build_custom_product_class do
            attribute :configuration, Configuration.to_hash_type
          end
        end

        include_examples "for hash type"
      end

      context "store model parent" do
        let(:custom_parent_class) do
          Class.new do
            include StoreModel::Model

            attribute :configuration, Configuration.to_hash_type
          end
        end

        include_examples "for hash type"
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

  describe ".to_hash_type" do
    subject { custom_product_class.new }

    let(:custom_product_class) do
      build_custom_product_class do
        attribute :configuration, Configuration.to_hash_type
      end
    end

    it "configures type using field name" do
      expect(subject.configuration).to be_a_kind_of(Hash)
    end

    it "allows setting and getting values by key" do
      config = Configuration.new(color: "red", model: "spaceship")
      subject.configuration["primary"] = config

      expect(subject.configuration["primary"]).to eq(config)
      expect(subject.configuration["primary"].color).to eq("red")
      expect(subject.configuration["primary"].model).to eq("spaceship")
    end

    it "serializes and deserializes correctly" do
      subject.configuration["primary"] = Configuration.new(color: "red")
      subject.configuration["secondary"] = Configuration.new(color: "blue")

      subject.save!
      subject.reload

      expect(subject.configuration["primary"].color).to eq("red")
      expect(subject.configuration["secondary"].color).to eq("blue")
    end
  end

  describe ".to_hash_type with StoreModel.one_of" do
    subject { custom_product_class.new }

    let(:configuration_v1) do
      Class.new do
        include StoreModel::Model
        attribute :version, :string, default: "v1"
        attribute :color, :string
      end
    end

    let(:configuration_v2) do
      Class.new do
        include StoreModel::Model
        attribute :version, :string, default: "v2"
        attribute :color, :string
        attribute :size, :string
      end
    end

    let(:custom_product_class) do
      config_v1 = configuration_v1
      config_v2 = configuration_v2

      build_custom_product_class do
        attribute :configuration, StoreModel.one_of { |json|
          (json[:version] || json["version"]) == "v2" ? config_v2 : config_v1
        }.to_hash_type
      end
    end

    it "configures polymorphic hash type" do
      expect(subject.configuration).to be_a_kind_of(Hash)
    end

    it "allows setting different model types by key" do
      config_v1 = configuration_v1.new(version: "v1", color: "red")
      config_v2 = configuration_v2.new(version: "v2", color: "blue", size: "large")

      subject.configuration["old"] = config_v1
      subject.configuration["new"] = config_v2

      expect(subject.configuration["old"]).to eq(config_v1)
      expect(subject.configuration["old"]).to be_a(configuration_v1)
      expect(subject.configuration["old"].color).to eq("red")

      expect(subject.configuration["new"]).to eq(config_v2)
      expect(subject.configuration["new"]).to be_a(configuration_v2)
      expect(subject.configuration["new"].color).to eq("blue")
      expect(subject.configuration["new"].size).to eq("large")
    end

    it "serializes and deserializes polymorphic models correctly" do
      subject.configuration["v1_config"] = configuration_v1.new(version: "v1", color: "green")
      subject.configuration["v2_config"] = configuration_v2.new(version: "v2", color: "yellow", size: "medium")

      subject.save!
      subject.reload

      v1_config = subject.configuration["v1_config"]
      expect(v1_config.class.ancestors).to include(StoreModel::Model)
      expect(v1_config.version).to eq("v1")
      expect(v1_config.color).to eq("green")

      v2_config = subject.configuration["v2_config"]
      expect(v2_config.class.ancestors).to include(StoreModel::Model)
      expect(v2_config.version).to eq("v2")
      expect(v2_config.color).to eq("yellow")
      expect(v2_config.size).to eq("medium")
    end

    it "casts hash values when assigning whole attribute" do
      subject.configuration = {
        "v1_item" => { version: "v1", color: "red" },
        "v2_item" => { version: "v2", color: "blue", size: "small" }
      }

      expect(subject.configuration["v1_item"]).to be_a(configuration_v1)
      expect(subject.configuration["v1_item"].color).to eq("red")

      expect(subject.configuration["v2_item"]).to be_a(configuration_v2)
      expect(subject.configuration["v2_item"].color).to eq("blue")
      expect(subject.configuration["v2_item"].size).to eq("small")
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
