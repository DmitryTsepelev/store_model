# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Nested attributes" do
  let(:supplier1) { { title: "First" } }
  let(:supplier2) { { title: "Second" } }
  let(:attributes) do
    { color: "red", disabled_at: Time.new(2019, 2, 10, 12), suppliers: [supplier1, supplier2] }
  end

  describe "#initialize" do
    context "when symbolized hash is passed" do
      subject { ComplexConfiguration.new(attributes) }

      it("assigns attrbutes to root model") do
        expect(subject).to have_attributes(attributes.slice(:color, :disabled_at))
      end

      it("assigns attrbutes to nested model") do
        expect(subject.suppliers.first).to have_attributes(supplier1)
        expect(subject.suppliers.second).to have_attributes(supplier2)
      end
    end
  end

  describe "#as_json" do
    subject { ComplexConfiguration.new(attributes) }

    it "returns correct JSON" do
      expect(subject.as_json).to eq(attributes.as_json)
    end
  end
end
