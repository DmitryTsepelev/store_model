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

  it "has .values class method" do
    expect(config_class.status_values).to eq(active: 1, archived: 0)
  end

  it "aliases the pluralized name to the #values method" do
    expect(subject.statuses).to eq(subject.status_values)
  end

  it "aliases the pluralized name to the .values method" do
    expect(config_class.statuses).to eq(config_class.status_values)
  end

  context "when multiple StoreModel classes are defined" do
    let!(:another_config_class) do
      Class.new do
        include StoreModel::Model

        enum :status, off: 0, on: 1
        enum :level, low: 1, medium: 2, high: 3
      end
    end

    it "does not share enum mapping methods between classes" do
      expect(another_config_class.status_values).to eq(off: 0, on: 1)
      expect(config_class.status_values).to eq(active: 1, archived: 0)
      expect(config_class.respond_to?(:level_values)).to eq(false)
    end
  end

  context "when value is not in the list" do
    let(:value) { "undefined" }

    it "raises exception" do
      expect { subject.status = value }.to raise_error(
        ArgumentError,
        "invalid value '#{value}' is assigned"
      )
    end
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

  context "when multiple enum with prefix is provided" do
    let(:config_class) do
      Class.new do
        include StoreModel::Model

        enum :status, %i[active archived], _prefix: true
        enum :comment_status, %i[active archived], _prefix: "comment"
      end
    end

    subject { config_class.new(status: :active, comment_status: :archived) }

    it "has prefixed predicate methods" do
      expect(subject).to be_status_active
      expect(subject).not_to be_status_archived

      expect(subject).to be_comment_archived
      expect(subject).not_to be_comment_active
    end
  end

  context "when multiple enum with suffix is provided" do
    let(:config_class) do
      Class.new do
        include StoreModel::Model

        enum :status, %i[active archived], _suffix: true
        enum :comment_status, %i[active archived], _suffix: "comment"
      end
    end

    subject { config_class.new(status: :active, comment_status: :archived) }

    it "has suffixed predicate methods" do
      expect(subject).to be_active_status
      expect(subject).not_to be_archived_status

      expect(subject).to be_archived_comment
      expect(subject).not_to be_active_comment
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
