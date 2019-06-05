# frozen_string_literal: true

require "spec_helper"

RSpec.describe ActiveRecord::Base do
  let(:attributes) do
    { color: "red", disabled_at: Time.new(2019, 2, 10, 12) }
  end

  describe "#assign_attributes" do
    let(:custom_product_class) do
      build_custom_product_class do
        attribute :configuration, Configuration.to_type
      end
    end

    let(:configuration) { Configuration.new(attributes) }

    subject { custom_product_class.new(configuration: configuration) }

    it "not overrides missing keys" do
      subject.assign_attributes(configuration: { color: "blue" })

      expect(subject.configuration).to have_attributes(
        color: "blue",
        disabled_at: attributes[:disabled_at]
      )
    end

    context "when hash is passed" do
      let(:configuration) { attributes }

      it "not overrides missing keys" do
        subject.assign_attributes(configuration: { color: "blue" })

        expect(subject.configuration).to have_attributes(
          color: "blue",
          disabled_at: attributes[:disabled_at]
        )
      end
    end

    it "handles hash with nil value is passed" do
      subject.assign_attributes(configuration: nil)

      expect(subject.configuration).to be_nil
    end

    context "when initial stored_model is nil" do
      let(:configuration) { nil }

      it "changes values" do
        subject.assign_attributes(configuration: { color: "blue" })

        expect(subject.configuration).to have_attributes(
          color: "blue",
          disabled_at: nil
        )
      end
    end
  end
end
