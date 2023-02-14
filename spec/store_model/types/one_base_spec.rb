# frozen_string_literal: true

require "spec_helper"

RSpec.describe StoreModel::Types::OneBase do
  let(:child_class) { Class.new(described_class) }

  describe "#initialize" do
    described_class::STORAGES.each do |storage|
      context "when storage is #{storage}" do
        specify do
          expect(child_class.new(storage)).to be_instance_of(child_class)
        end
      end
    end

    context "when storage is invalid" do
      it "raises ArgumentError" do
        expect { child_class.new("wrong") }.to \
          raise_error(ArgumentError, "wrong is not supported, supported storages are json, hstore")
      end
    end
  end
end
