# frozen_string_literal: true

require "spec_helper"

RSpec.describe StoreModel::Types::ManyPolymorphic do
  let(:type) { described_class.new(proc { Configuration }) }

  let(:attributes_array) do
    [
      {
        color: "red",
        model: nil,
        active: true,
        disabled_at: Time.new(2019, 2, 22, 12, 30).utc,
        encrypted_serial: nil,
        type: "left"
      },
      {
        color: "green",
        model: nil,
        active: false,
        disabled_at: Time.new(2019, 3, 12, 8, 10).utc,
        encrypted_serial: nil,
        type: "right"
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

      context "when model_wrapper does not return model" do
        let(:type) { described_class.new(proc { nil }) }

        it "raises exception" do
          expect { type.cast_value(value) }.to raise_error(
            StoreModel::Types::ExpandWrapperError,
            "#{nil.inspect} is an invalid model klass"
          )
        end
      end
    end

    context "when Array of instances is passed" do
      let(:configuration_class) { Class.new(Configuration) }

      let(:value) { attributes_array.map { |attrs| configuration_class.new(attrs) } }

      it { expect(subject.first).to be_a(configuration_class) }
      it { expect(subject.second).to be_a(configuration_class) }

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
          "failed casting {}, only String, " \
          "Hash or instances which implement StoreModel::Model are allowed"
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

    context "when passing more complex block" do
      let(:type) { described_class.new(configuration_proc) }

      let(:configuration_v1) do
        Class.new do
          include StoreModel::Model

          attribute :version, :string
          attribute :brightness, :string
        end
      end

      let(:configuration_v2) do
        Class.new do
          include StoreModel::Model

          attribute :version, :string
          attribute :brightness, :string
        end
      end

      let(:configuration_proc) do
        proc { |json| json[:version] == "v1" ? configuration_v1 : configuration_v2 }
      end

      context "when data consist of v1" do
        let(:value) { [{ version: "v1" }, { version: "v2" }] }

        it { expect(subject.first).to be_a(configuration_v1) }
        it { expect(subject.second).to be_a(configuration_v2) }
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

    context "when Array of instances is passed" do
      let(:value) { attributes_array.map { |attrs| Configuration.new(attrs) } }
      include_examples "serialize examples"

      context "with unknown attributes" do
        before do
          value.each_with_index { |v, index| v.unknown_attributes[:archived] = index.even? }
        end

        [true, false].each do |serialize_unknown_attributes|
          it "always includes unknown attributes regardless of the serialize_unknown_attributes option" do
            StoreModel.config.serialize_unknown_attributes = serialize_unknown_attributes
            expect(subject).to eq(
              attributes_array.map.with_index do |attrs, index|
                attrs.merge(value[index].unknown_attributes)
              end.to_json
            )
          end
        end

        context "when serialize_unknown_attributes attribute of instances is set to true" do
          it "includes unknown attributes by overriding the globally configured behavior" do
            value.each { |v| v.serialize_unknown_attributes = true }
            expect(subject).to eq(
              attributes_array.map.with_index do |attrs, index|
                attrs.merge(value[index].unknown_attributes)
              end.to_json
            )
          end
        end

        context "when serialize_unknown_attributes attribute of instances is set to false" do
          it "does not include unknown attributes by overriding the globally configured behavior" do
            value.each { |v| v.serialize_unknown_attributes = false }
            expect(subject).to eq(attributes_array.to_json)
          end
        end
      end

      context "with enums" do
        context "when serialize_enums_using_as_json attribute of instances is set to true" do
          it "serializes enums by overriding the globally configured behavior" do
            value.each { |v| v.serialize_enums_using_as_json = true }
            expect(subject).to eq(
              attributes_array.map do |attrs|
                attrs.merge(type: attrs[:type])
              end.to_json
            )
          end
        end

        context "when serialize_enums_using_as_json attribute of instances is set to false" do
          it "does not serialize enums by overriding the globally configured behavior" do
            value.each { |v| v.serialize_enums_using_as_json = false }
            expect(subject).to eq(
              attributes_array.map do |attrs|
                attrs.merge(type: Configuration.types[attrs[:type].to_sym])
              end.to_json
            )
          end
        end
      end
    end
  end
end
