# frozen_string_literal: true

require "spec_helper"

class ExampleModel
  include StoreModel::Model

  attribute :amount, :float

  validates :amount, numericality: { greater_than_or_equal_to: 0 }
end

RSpec.describe StoreModel::Model do
  subject { ExampleModel.new(amount: amount) }

  context "when attribute is cast from an invalid value" do
    let(:amount) { "junk" }

    it { is_expected.to be_invalid }
  end

  context "when attribute is cast from a valid value" do
    let(:amount) { "20" }

    it { is_expected.to be_valid }
  end
end
