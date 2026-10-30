# frozen_string_literal: true

require "spec_helper"

RSpec.describe StoreModel::Types::One do
  let(:type) { described_class.new(Configuration) }

  let(:attributes) do
    {
      color: "red",
      model: nil,
      active: false,
      disabled_at: Time.new(2019, 2, 22, 12, 30).utc,
      encrypted_serial: nil,
      type: "left"
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
    subject { type.cast_value(value) }

    shared_examples "for known attributes" do
      it { is_expected.to be_a(Configuration) }
      it("assigns attributes") { is_expected.to have_attributes(attributes) }
    end

    context "when Hash is passed" do
      let(:value) { attributes }
      include_examples "for known attributes"
    end

    context "when String is passed" do
      let(:value) { ActiveSupport::JSON.encode(attributes) }
      include_examples "for known attributes"
    end

    context "when Configuration instance is passed" do
      let(:value) { Configuration.new(attributes) }
      include_examples "for known attributes"
    end

    context "when nil is passed" do
      let(:value) { nil }

      it { is_expected.to be_nil }
    end

    context "when instance of illegal class is passed" do
      let(:value) { 1 }

      it "raises exception" do
        expect { type.cast_value(value) }.to raise_error(
          StoreModel::Types::CastError,
          "failed casting 1, only String, Hash or Configuration instances are allowed"
        )
      end
    end

    context "when some keys are not defined as attributes" do
      shared_examples "for unknown attributes" do
        it { is_expected.to be_a(Configuration) }

        it("assigns attributes") { is_expected.to have_attributes(color: "red") }

        it "assigns unknown_attributes" do
          expect(subject.unknown_attributes).to eq(
            "unknown_attribute" => "something", "one_more" => "anything"
          )
        end
      end

      let(:attributes) { { color: "red", unknown_attribute: "something", one_more: "anything" } }

      context "when Hash is passed" do
        let(:value) { attributes }
        include_examples "for unknown attributes"
      end

      context "when String is passed" do
        let(:value) { ActiveSupport::JSON.encode(attributes) }
        include_examples "for unknown attributes"
      end

      context "when saving model" do
        subject { persisted_product.configuration }

        let(:custom_product_class) do
          build_custom_product_class do
            attribute :configuration, Configuration.to_type
          end
        end

        let(:persisted_product) do
          custom_product_class.create(
            configuration: Configuration.to_type.cast_value(attributes)
          )
        end

        include_examples "for unknown attributes"
      end

      context "when unknown keys are inside nested model" do
        shared_examples "for unknown nested attributes" do
          it { is_expected.to be_a(configuration_class) }

          it("assigns attributes") { is_expected.to have_attributes(color: "red") }

          it "assigns unknown_attributes" do
            expect(subject.suppliers.first.unknown_attributes).to eq(expected_unknown_attributes)
          end
        end

        let(:configuration_class) do
          Class.new do
            include StoreModel::Model

            attribute :color, :string
            attribute :suppliers, Supplier.to_array_type

            accepts_nested_attributes_for :suppliers
          end
        end

        let(:type) { described_class.new(configuration_class) }

        let(:supplier) { { unknown_attribute: "something" } }
        let(:expected_unknown_attributes) { { "unknown_attribute" => "something" } }
        let(:attributes) { { color: "red", suppliers: [supplier] } }

        context "when Hash is passed" do
          let(:value) { attributes }
          include_examples "for unknown nested attributes"
        end

        context "when Hash is passed with :attributes key" do
          let(:value) { attributes }
          let(:supplier) { { attributes: { unknown_attribute: "something" } } }
          include_examples "for unknown nested attributes"
        end

        context "when Hash is passed with :attributes key and other keys" do
          let(:value) { attributes }
          let(:supplier) do
            {
              attributes: { unknown_attribute: "something" },
              other_unknown_attribute: "kept"
            }
          end
          let(:expected_unknown_attributes) do
            { "unknown_attribute" => "something", "other_unknown_attribute" => "kept" }
          end
          include_examples "for unknown nested attributes"
        end

        context "when String is passed" do
          let(:value) { ActiveSupport::JSON.encode(attributes) }
          include_examples "for unknown nested attributes"
        end
      end
    end

    it "keeps nested models and thousands of unknown JSON attributes" do
      configuration_class = Class.new do
        include StoreModel::Model

        attribute :suppliers, Supplier.to_array_type
      end
      unknown_attributes = (1..5_000).to_h { |index| ["extra_#{index}", index] }
      payload = { "suppliers" => [{ "title" => "first" }, { "title" => "second" }] }.merge(unknown_attributes)

      configuration = described_class.new(configuration_class).cast_value(payload.to_json)

      aggregate_failures do
        expect(configuration.suppliers.map(&:title)).to eq(%w[first second])
        expect(configuration.unknown_attributes).to eq(unknown_attributes)
        expect(configuration.as_json).to include("extra_1" => 1, "extra_5000" => 5_000)
      end
    end

    it "stores unknown symbol and string keys with their original values" do
      configuration = type.cast_value(color: "red", symbol_key: 1, "string_key" => { "nested" => true })

      expect(configuration.color).to eq("red")
      expect(configuration.unknown_attributes).to eq(
        "symbol_key" => 1, "string_key" => { "nested" => true }
      )
    end

    it "keeps the last value when both key forms name the same unknown attribute" do
      string_first = type.cast_value("extra" => "string", extra: "symbol")
      symbol_first = type.cast_value(extra: "symbol", "extra" => "string")

      expect(string_first.unknown_attributes).to eq("extra" => "symbol")
      expect(symbol_first.unknown_attributes).to eq("extra" => "string")
    end

    it "uses declared aliases and custom writers on either side of an unknown key" do
      configuration_class = Class.new do
        include StoreModel::Model

        attribute :title, :string
        attribute :tone, :string
        alias_attribute :heading, :title

        def tone=(value)
          self[:tone] = value.upcase
        end
      end
      type = described_class.new(configuration_class)

      first = type.cast_value(heading: "first", extra: "kept", tone: "warm")
      second = type.cast_value(tone: "cool", extra: "kept", heading: "second")

      expect(first).to have_attributes(title: "first", tone: "WARM")
      expect(second).to have_attributes(title: "second", tone: "COOL")
      expect(first.unknown_attributes).to eq("extra" => "kept")
      expect(second.unknown_attributes).to eq("extra" => "kept")
    end

    it "runs a declared writer's side effect once on either side of an unknown key" do
      writes = []
      configuration_class = Class.new do
        include StoreModel::Model

        attribute :name, :string

        define_method(:name=) do |value|
          writes << value
          self[:name] = value
        end
      end

      type = described_class.new(configuration_class)

      type.cast_value(extra: "unknown", name: "Alice")
      type.cast_value(name: "Bob", extra: "unknown")

      expect(writes).to eq(%w[Alice Bob])
    end

    it "raises an unknown attribute error from inside a declared writer" do
      configuration_class = Class.new do
        include StoreModel::Model

        attribute :color, :string

        def color=(_value)
          raise ActiveModel::UnknownAttributeError.new(self, :color)
        end
      end

      expect { described_class.new(configuration_class).cast_value(extra: "kept", color: "red") }
        .to raise_error(ActiveModel::UnknownAttributeError, /color/)
    end

    it "uses a writer enabled by an earlier input value after an unknown key" do
      configuration_class = Class.new do
        include StoreModel::Model

        attribute :mode, :string
        attr_reader :late_value

        def mode=(value)
          self[:mode] = value
          singleton_class.attr_accessor(:late_value) if value == "enabled"
        end
      end

      configuration = described_class.new(configuration_class).cast_value(
        extra: "kept", mode: "enabled", late_value: "assigned"
      )

      expect(configuration.mode).to eq("enabled")
      expect(configuration.late_value).to eq("assigned")
      expect(configuration.unknown_attributes).to eq("extra" => "kept")
    end

    it "preserves values assigned before a duplicate key disables their writer" do
      configuration_class = Class.new do
        include StoreModel::Model

        attribute :mode, :string
        attr_reader :late_value

        def mode=(value)
          self[:mode] = value
          if value == "on"
            singleton_class.define_method(:late_value=) { |late| @late_value = late }
          elsif singleton_class.instance_methods(false).include?(:late_value=)
            singleton_class.remove_method(:late_value=)
          end
        end
      end
      payload = { mode: "on", late_value: "first", "mode" => "off", "late_value" => "second" }

      configuration = described_class.new(configuration_class).cast_value(payload)

      expect(configuration.mode).to eq("off")
      expect(configuration.late_value).to eq("first")
      expect(configuration.unknown_attributes).to eq("late_value" => "second")
    end

    it "finishes custom initialization when casting an unknown key" do
      configuration_class = Class.new do
        include StoreModel::Model

        attribute :color, :string
        attr_reader :completed_initialization

        def initialize(attributes = {})
          super
          @completed_initialization = true
        end
      end

      configuration = described_class.new(configuration_class).cast_value(color: "red", extra: "kept")

      expect(configuration.color).to eq("red")
      expect(configuration.completed_initialization).to be(true)
      expect(configuration.unknown_attributes).to eq("extra" => "kept")
    end

    it "gives a custom initializer the unknown input keys" do
      configuration_class = Class.new do
        include StoreModel::Model

        attr_reader :late

        def initialize(attributes = {})
          singleton_class.attr_accessor(:late) if attributes.key?(:extra)
          super
        end
      end

      configuration = described_class.new(configuration_class).cast_value(extra: "ignored", late: "kept")

      expect(configuration.late).to eq("kept")
      expect(configuration.unknown_attributes).to eq("extra" => "ignored")
    end

    it "casts unknown keys when a model factory returns a subclass" do
      configuration_class = Class.new do
        include StoreModel::Model

        attribute :name, :string
      end
      subclass = Class.new(configuration_class)
      configuration_class.define_singleton_method(:new) do |attributes = {}|
        Class.instance_method(:new).bind_call(subclass, attributes)
      end

      configuration = described_class.new(configuration_class).cast_value(name: "Alice", extra: "kept")

      expect(configuration).to be_a(subclass)
      expect(configuration.name).to eq("Alice")
      expect(configuration.unknown_attributes).to eq("extra" => "kept")
    end

    it "retains multiple unknown keys when a custom initializer duplicates its input" do
      configuration_class = Class.new do
        include StoreModel::Model

        attribute :name, :string

        def initialize(attributes = {})
          super(attributes.dup)
        end
      end

      configuration = configuration_class.to_type.cast_value(extra_one: 1, extra_two: 2, name: "Alice")

      expect(configuration.name).to eq("Alice")
      expect(configuration.unknown_attributes).to eq("extra_one" => 1, "extra_two" => 2)
    end

    it "casts unknown keys when a model factory returns an unrelated class" do
      target_class = Class.new do
        include StoreModel::Model

        attribute :color, :string
      end
      configuration_class = Class.new do
        include StoreModel::Model

        attribute :colour, :string
      end
      configuration_class.define_singleton_method(:new) do |attributes = {}|
        attributes = attributes.dup
        target_class.new(attributes.merge("color" => attributes.delete("colour")))
      end

      configuration = configuration_class.to_type.cast_value("colour" => "red", "extra" => 1)

      expect(configuration).to be_a(target_class)
      expect(configuration.color).to eq("red")
      expect(configuration.unknown_attributes).to eq("extra" => 1)
    end

    it "keeps models built by a writer strict" do
      stub_const("Node", Class.new do
        include StoreModel::Model

        attribute :name, :string

        def label=(value)
          Node.new(name: value, bogus: 1)
        end
      end)

      expect { Node.to_type.cast_value(label: "mk") }
        .to raise_error(ActiveModel::UnknownAttributeError, /bogus/)
    end

    it "assigns declared attributes whose writers are served by method_missing" do
      configuration_class = Class.new do
        include StoreModel::Model

        attribute :name, :string
        attribute_method_suffix "_label"
      end

      configuration = configuration_class.to_type.cast_value("name" => "old", "extra" => 1)

      expect(configuration.name).to eq("old")
      expect(configuration.unknown_attributes).to eq("extra" => 1)
    end

    context "when a custom initializer builds another model before super" do
      let(:address_class) do
        Class.new do
          include StoreModel::Model

          attribute :city, :string
        end
      end

      def customer_class(address_attributes)
        address_class = self.address_class
        Class.new do
          include StoreModel::Model

          attribute :name, :string
          attribute :address, address_class.to_type

          define_method(:initialize) do |attributes = {}|
            super({ address: address_class.new(address_attributes) }.merge(attributes))
          end
        end
      end

      it "keeps unknown keys on the model being cast" do
        customer = customer_class(city: "n/a").to_type.cast_value(name: "a", extra: 1)

        expect(customer.address.city).to eq("n/a")
        expect(customer.unknown_attributes).to eq("extra" => 1)
      end

      it "keeps the other model strict" do
        expect { customer_class(city: "n/a", bogus: 1).to_type.cast_value(name: "a") }
          .to raise_error(ActiveModel::UnknownAttributeError, /bogus/)
      end
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

      subject { type.serialize(value) }

      it { is_expected.to be_a(String) }

      it("is equal to attributes") { is_expected.to eq(attributes.to_json) }

      context "with unknown attributes" do
        before do
          value.unknown_attributes[:archived] = true
        end

        [true, false].each do |serialize_unknown_attributes|
          it "always includes unknown attributes regardless of the serialize_unknown_attributes option" do
            StoreModel.config.serialize_unknown_attributes = serialize_unknown_attributes
            expect(subject).to eq(attributes.merge(value.unknown_attributes).to_json)
          end
        end

        context "when serialize_unknown_attributes attribute of instance is set to true" do
          it "includes unknown attributes by overriding the globally configured behavior" do
            value.serialize_unknown_attributes = true
            expect(subject).to eq(attributes.merge(value.unknown_attributes).to_json)
          end
        end

        context "when serialize_unknown_attributes attribute of instance is set to false" do
          it "does not include unknown attributes by overriding the globally configured behavior" do
            value.serialize_unknown_attributes = false
            expect(subject).to eq(attributes.to_json)
          end
        end
      end

      context "when empty serialize_empty_attributes is off" do
        before do
          StoreModel.config.serialize_empty_attributes = false
        end

        it "does not serialize empty attributes" do
          expect(subject).to eq(attributes.except(:model, :encrypted_serial).to_json)
        end
      end

      context "with enums" do
        context "when serialize_enums_using_as_json attribute of instance is set to true" do
          it "serializes enums by overriding the globally configured behavior" do
            value.serialize_enums_using_as_json = true
            expect(subject).to eq(attributes.merge(type: "left").to_json)
          end
        end

        context "when serialize_enums_using_as_json attribute of instance is set to false" do
          it "does not serialize enums by overriding the globally configured behavior" do
            value.serialize_enums_using_as_json = false
            expect(subject).to eq(attributes.merge(type: 1).to_json)
          end
        end
      end
    end
  end

  describe "#deserialize" do
    describe "when an empty string is passed" do
      let(:value) { "" }

      subject { type.deserialize(value) }

      it { is_expected.to be_a(Configuration) }

      it("is equal to an empty model") { is_expected.to eq(Configuration.new) }
    end

    describe "when a null encoded json value is passed" do
      let(:value) { "null" }

      subject { type.deserialize(value) }

      it { is_expected.to be_nil }
    end

    describe "when a malformed JSON string is passed" do
      let(:value) { "{/sdfgsdfre}" }

      subject { type.deserialize(value) }

      it { is_expected.to be_a(Configuration) }

      it("is equal to an empty model") { is_expected.to eq(Configuration.new) }
    end
  end
end
