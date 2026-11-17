# frozen_string_literal: true

require "spec_helper"

RSpec.describe StoreModel::TypedStoreParentAssignment do
  subject { custom_product_class.new }

  let(:custom_product_class) do
    build_custom_product_class do
      store_attribute :settings, :nested, Configuration.to_type
      store_attribute :settings, :nested_list, Configuration.to_array_type
    end
  end

  let(:configuration) { Configuration.new(color: "red") }
  let(:expected_parent) { StoreModel.config.enable_parent_assignment ? subject : nil }

  describe "write" do
    it "assigns the record as parent of the written model" do
      subject.nested = configuration

      expect(configuration.parent).to eq(expected_parent)
    end

    it "assigns the record as parent of each written array element" do
      subject.nested_list = [configuration]

      expect(configuration.parent).to eq(expected_parent)
    end
  end
end
