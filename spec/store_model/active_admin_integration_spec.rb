# frozen_string_literal: true

require "spec_helper"

RSpec.describe "ActiveAdmin Integration" do
  before(:all) do
    # Enable ActiveAdmin compatibility
    StoreModel.config.active_admin_compatibility = true

    # Apply patches (same pattern as Railtie)
    require "store_model/ext/active_admin_compatibility"
    StoreModel::Model.prepend(StoreModel::ActiveAdminCompatibility::NewRecordPatch)
    StoreModel::NestedAttributes::ClassMethods.prepend(StoreModel::ActiveAdminCompatibility::ReflectionMethods)

    # Create a test model class that uses ActiveAdmin compatibility
    # Define once to avoid class redefinition warnings and ensure consistency
    @test_product_class = Class.new(ActiveRecord::Base) do
      self.table_name = "products"
      include StoreModel::NestedAttributes

      attribute :suppliers, Supplier.to_array_type, default: -> { [] }
      accepts_nested_attributes_for :suppliers, allow_destroy: true

      def self.name
        "ActiveAdminIntegrationTestProduct"
      end
    end
  end

  after(:all) do
    StoreModel.config.active_admin_compatibility = false
  end

  let(:test_product_class) { @test_product_class }

  describe "StoreModel compatibility methods" do
    it "TestProduct class has reflect_on_association" do
      expect(test_product_class).to respond_to(:reflect_on_association)
    end

    it "returns reflection for suppliers" do
      reflection = test_product_class.reflect_on_association(:suppliers)
      expect(reflection).not_to be_nil
      expect(reflection).to be_a(StoreModel::ActiveAdminCompatibility::Reflection)
      expect(reflection.klass).to eq(Supplier)
      expect(reflection.name).to eq(:suppliers)
    end

    it "Supplier instances have new_record? method" do
      supplier = Supplier.new(title: "Test")
      expect(supplier).to respond_to(:new_record?)
      expect(supplier.new_record?).to eq(true)
    end

    it "Supplier class has reflect_on_association method" do
      expect(Supplier).to respond_to(:reflect_on_association)
      expect(Supplier.reflect_on_association(:anything)).to be_nil
    end
  end

  describe "Product model with nested suppliers" do
    it "can create a product with suppliers" do
      product = test_product_class.create!(
        name: "Test Product",
        suppliers: [
          Supplier.new(title: "Supplier 1", address: "Address 1"),
          Supplier.new(title: "Supplier 2", address: "Address 2")
        ]
      )

      expect(product.persisted?).to be true
      expect(product.suppliers.size).to eq(2)
      expect(product.suppliers.first.title).to eq("Supplier 1")
    end

    it "can update suppliers using nested attributes" do
      product = test_product_class.create!(
        name: "Test Product",
        suppliers: [Supplier.new(title: "Original Supplier", address: "Original Address")]
      )

      product.update!(
        suppliers_attributes: [
          { title: "Updated Supplier", address: "Updated Address" }
        ]
      )

      expect(product.suppliers.size).to eq(1)
      expect(product.suppliers.first.title).to eq("Updated Supplier")
    end

    it "can destroy suppliers using nested attributes" do
      product = test_product_class.create!(
        name: "Test Product",
        suppliers: [
          Supplier.new(title: "Supplier 1", address: "Address 1"),
          Supplier.new(title: "Supplier 2", address: "Address 2")
        ]
      )

      product.update!(
        suppliers_attributes: [
          { title: "Supplier 1", address: "Address 1" }
        ]
      )

      expect(product.suppliers.size).to eq(1)
      expect(product.suppliers.first.title).to eq("Supplier 1")
    end
  end

  describe "ActiveAdmin DSL compatibility" do
    it "reflection is available for formtastic" do
      # This simulates what Formtastic does when building has_many forms
      reflection = test_product_class.reflect_on_association(:suppliers)

      expect(reflection).not_to be_nil
      expect(reflection.klass).to eq(Supplier)
    end

    it "new_record? is available on StoreModel instances" do
      # This simulates what ActiveAdmin's has_many does
      supplier = Supplier.new(title: "Test", address: "Test Address")

      expect(supplier.new_record?).to be true
    end
  end
end
