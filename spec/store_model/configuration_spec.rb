# frozen_string_literal: true

require "spec_helper"

RSpec.describe StoreModel::Configuration do
  subject(:configuration) { described_class.new }

  specify "parent assignment is enabled by default" do
    expect(configuration.enable_parent_assignment).to eq(true)

    configuration.enable_parent_assignment = false
    expect(configuration.enable_parent_assignment).to eq(false)
  end
end
