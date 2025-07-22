# frozen_string_literal: true

require "spec_helper"

RSpec.describe "StoreModel::Model.discriminator_attribute" do
  describe "basic usage" do
    let(:dog_class) do
      Class.new do
        include StoreModel::Model

        discriminator_attribute value: "dog"
        attribute :breed, :string
      end
    end

    it "creates a type attribute with the specified default" do
      dog = dog_class.new
      expect(dog.type).to eq("dog")
    end

    it "allows overriding the type value" do
      dog = dog_class.new(type: "puppy")
      expect(dog.type).to eq("puppy")
    end

    it "includes type in attributes" do
      dog = dog_class.new
      expect(dog.attributes).to include("type" => "dog")
    end
  end

  describe "custom attribute name" do
    let(:payment_class) do
      Class.new do
        include StoreModel::Model

        discriminator_attribute :kind, value: "credit_card"
        attribute :number, :string
      end
    end

    it "creates attribute with custom name" do
      payment = payment_class.new
      expect(payment.kind).to eq("credit_card")
    end

    it "does not create a 'type' attribute" do
      payment = payment_class.new
      expect(payment.attributes).not_to have_key("type")
      expect(payment.attributes).to include("kind" => "credit_card")
    end
  end

  describe "custom attribute type" do
    let(:version_class) do
      Class.new do
        include StoreModel::Model

        discriminator_attribute :version, type: :integer, value: 1
        attribute :data, :string
      end
    end

    let(:priority_class) do
      Class.new do
        include StoreModel::Model

        discriminator_attribute :priority, type: :integer, value: 10
        attribute :message, :string
      end
    end

    it "creates an integer discriminator attribute" do
      instance = version_class.new
      expect(instance.version).to eq(1)
      expect(instance.version).to be_a(Integer)
    end

    it "allows overriding the integer value" do
      instance = version_class.new(version: 2)
      expect(instance.version).to eq(2)
    end

    it "includes integer type in attributes" do
      instance = version_class.new
      expect(instance.attributes).to include("version" => 1)
    end
  end
end
