# frozen_string_literal: true

require "spec_helper"

RSpec.describe StoreModel::Types::Many do
  let(:type) { described_class.new(Configuration) }

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

      context "when saving model" do
        subject { persisted_product.configurations }

        let(:custom_product_class) do
          build_custom_product_class do
            attribute :configurations, Configuration.to_array_type
          end
        end

        let(:persisted_product) do
          custom_product_class.create(
            configurations: Configuration.to_array_type.cast_value(attributes_array)
          )
        end

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

    context "when any empty Array is passed" do
      let(:value) { [] }
      let(:attributes_array) { [] }

      include_examples "serialize examples"
    end

    context "when String is passed" do
      let(:value) { ActiveSupport::JSON.encode(attributes_array) }
      include_examples "serialize examples"
    end

    context "when nil is passed" do
      subject { type.serialize(nil) }

      it "returns nil" do
        expect(subject).to be_nil
      end
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

      context "when empty serialize_empty_attributes is off" do
        before do
          StoreModel.config.serialize_empty_attributes = false
        end

        let(:expected_attributes_array) do
          attributes_array.map { |attrs| attrs.except(:model, :encrypted_serial) }
        end

        it "does not serialize empty attributes" do
          expect(subject).to eq(expected_attributes_array.to_json)
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
