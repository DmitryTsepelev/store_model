# frozen_string_literal: true

require "spec_helper"

RSpec.describe StoreModel::Model do
  let(:config_class) do
    Class.new do
      include StoreModel::Model

      enum :status, in: { active: 1, archived: 0 }
    end
  end

  subject { config_class.new(status: :archived) }

  it "sets default value" do
    expect(subject.status).to eq("archived")
  end

  it "has setter" do
    subject.status = :active
    expect(subject.status).to eq("active")
  end

  it "has predicate methods" do
    expect(subject).not_to be_active
    expect(subject).to be_archived
  end

  it "has #value method" do
    expect(subject.status_value).to eq(0)
  end

  it "has #values method" do
    expect(subject.status_values).to eq(active: 1, archived: 0)
  end

  context "when hash is passed without :in" do
    let(:config_class) do
      Class.new do
        include StoreModel::Model

        enum :status, active: 1, archived: 0
      end
    end

    subject { config_class.new }

    it "converts mapping to hash" do
      expect(subject.status_values).to eq(active: 1, archived: 0)
    end
  end

  context "when enum values are in array" do
    let(:config_class) do
      Class.new do
        include StoreModel::Model

        enum :status, in: %i[active archived]
      end
    end

    subject { config_class.new }

    it "converts mapping to hash" do
      expect(subject.status_values).to eq(active: 0, archived: 1)
    end

    context "when passed as second argument" do
      let(:config_class) do
        Class.new do
          include StoreModel::Model

          enum :status, %i[active archived]
        end
      end

      it "converts mapping to hash" do
        expect(subject.status_values).to eq(active: 0, archived: 1)
      end
    end
  end

  context "when default is provided" do
    let(:config_class) do
      Class.new do
        include StoreModel::Model

        enum :status, in: %i[active archived], default: :active
      end
    end

    subject { config_class.new }

    it "sets default value" do
      expect(subject.status).to eq("active")
    end
  end

  describe "#valid?" do
    let(:config_class) do
      Class.new do
        def self.model_name
          ActiveModel::Name.new(self, nil, "ValidatedConfiguration")
        end

        include StoreModel::Model

        enum :status, in: { active: 1, archived: 0 }

        validates :status, presence: true
      end
    end

    let(:status) { nil }

    subject { config_class.new(status: status) }

    it "is invalid" do
      expect(subject).to be_invalid
      expect(subject.errors.messages).to eq(status: ["can't be blank"])
    end

    context "when status is specified" do
      let(:status) { :active }

      it "is invalid" do
        expect(subject).to be_valid
      end
    end
  end
end
