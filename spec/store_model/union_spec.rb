# frozen_string_literal: true

require "spec_helper"

RSpec.describe "StoreModel.union ActiveRecord Integration" do
  describe "single union attribute" do
    before do
      stub_const("EmailNotification", Class.new do
        include StoreModel::Model

        discriminator_attribute :channel, value: "email"
        attribute :to_address, :string
        attribute :subject, :string
      end)

      stub_const("SmsNotification", Class.new do
        include StoreModel::Model

        discriminator_attribute :channel, value: "sms"
        attribute :phone_number, :string
        attribute :message, :string
      end)

      stub_const("PushNotification", Class.new do
        include StoreModel::Model

        discriminator_attribute :channel, value: "push"
        attribute :device_token, :string
        attribute :title, :string
        attribute :body, :string
      end)
    end

    let(:notification_union) do
      StoreModel.union([EmailNotification, SmsNotification, PushNotification], discriminator: "channel")
    end

    let(:product_class) do
      union = notification_union
      build_custom_product_class do
        attribute :union_test, union.to_type
      end
    end

    it "persists and retrieves email notification" do
      product = product_class.create!(
        union_test: EmailNotification.new(
          to_address: "user@example.com",
          subject: "Hello World"
        )
      )

      reloaded = product_class.find(product.id)
      expect(reloaded.union_test).to be_a(EmailNotification)
      expect(reloaded.union_test.channel).to eq("email")
      expect(reloaded.union_test.to_address).to eq("user@example.com")
      expect(reloaded.union_test.subject).to eq("Hello World")
    end

    it "persists and retrieves sms notification" do
      product = product_class.create!(
        union_test: SmsNotification.new(
          phone_number: "+1234567890",
          message: "Your code is 123456"
        )
      )

      reloaded = product_class.find(product.id)
      expect(reloaded.union_test).to be_a(SmsNotification)
      expect(reloaded.union_test.channel).to eq("sms")
      expect(reloaded.union_test.phone_number).to eq("+1234567890")
      expect(reloaded.union_test.message).to eq("Your code is 123456")
    end

    it "persists and retrieves push notification" do
      product = product_class.create!(
        union_test: PushNotification.new(
          device_token: "abc123",
          title: "New Message",
          body: "You have a new message"
        )
      )

      reloaded = product_class.find(product.id)

      expect(reloaded.union_test).to be_a(PushNotification)
      expect(reloaded.union_test.channel).to eq("push")
      expect(reloaded.union_test.device_token).to eq("abc123")
      expect(reloaded.union_test.title).to eq("New Message")
      expect(reloaded.union_test.body).to eq("You have a new message")
    end

    it "raises error for unknown channel" do
      expect do
        product_class.create!(
          union_test: { channel: "unknown" }
        )
      end.to raise_error(ArgumentError, "Unknown discriminator value for union: unknown")
    end
  end

  describe "integer discriminator" do
    before do
      stub_const("BasicPlan", Class.new do
        include StoreModel::Model

        discriminator_attribute :tier, type: :integer, value: 1
        attribute :features, :integer, default: 5
        attribute :price, :float, default: 9.99
      end)

      stub_const("ProPlan", Class.new do
        include StoreModel::Model

        discriminator_attribute :tier, type: :integer, value: 2
        attribute :features, :integer, default: 20
        attribute :price, :float, default: 29.99
        attribute :support_level, :string, default: "email"
      end)

      stub_const("EnterprisePlan", Class.new do
        include StoreModel::Model

        discriminator_attribute :tier, type: :integer, value: 3
        attribute :features, :integer, default: -1 # unlimited
        attribute :price, :float, default: 99.99
        attribute :support_level, :string, default: "phone"
        attribute :sla, :boolean, default: true
      end)
    end

    let(:plan_union) { StoreModel.union([BasicPlan, ProPlan, EnterprisePlan], discriminator: "tier") }

    let(:product_class) do
      union = plan_union
      build_custom_product_class do
        attribute :union_test, union.to_type
      end
    end

    it "works with integer discriminators" do
      basic = product_class.create!(union_test: { tier: 1 })
      pro = product_class.create!(union_test: { tier: 2, support_level: "chat" })
      enterprise = product_class.create!(union_test: { tier: 3 })

      basic_reloaded = product_class.find(basic.id)
      expect(basic_reloaded.union_test).to be_a(BasicPlan)
      expect(basic_reloaded.union_test.tier).to eq(1)
      expect(basic_reloaded.union_test.features).to eq(5)
      expect(basic_reloaded.union_test.price).to eq(9.99)

      pro_reloaded = product_class.find(pro.id)
      expect(pro_reloaded.union_test).to be_a(ProPlan)
      expect(pro_reloaded.union_test.tier).to eq(2)
      expect(pro_reloaded.union_test.support_level).to eq("chat")

      enterprise_reloaded = product_class.find(enterprise.id)
      expect(enterprise_reloaded.union_test).to be_a(EnterprisePlan)
      expect(enterprise_reloaded.union_test.tier).to eq(3)
      expect(enterprise_reloaded.union_test.sla).to eq(true)
    end
  end

  describe "null handling" do
    before do
      stub_const("ConfigV1", Class.new do
        include StoreModel::Model

        discriminator_attribute :version, value: "v1"
        attribute :setting, :string
      end)
    end

    let(:config_union) { StoreModel.union([ConfigV1], discriminator: "version") }

    let(:product_class) do
      union = config_union
      build_custom_product_class do
        attribute :union_test, union.to_type
      end
    end

    it "handles nil configuration" do
      product = product_class.create!(union_test: nil)

      reloaded = product_class.find(product.id)
      expect(reloaded.union_test).to be_nil
    end
  end

  describe "duplicate discriminator validation" do
    it "raises error when multiple classes have the same discriminator value" do
      stub_const("DuplicateA", Class.new do
        include StoreModel::Model
        discriminator_attribute :kind, value: "same"
        attribute :field_a, :string
      end)

      stub_const("DuplicateB", Class.new do
        include StoreModel::Model
        discriminator_attribute :kind, value: "same"
        attribute :field_b, :string
      end)

      stub_const("DuplicateC", Class.new do
        include StoreModel::Model
        discriminator_attribute :kind, value: "different"
        attribute :field_c, :string
      end)

      expect do
        StoreModel.union([DuplicateA, DuplicateB, DuplicateC], discriminator: "kind")
      end.to raise_error(RuntimeError, 'Duplicate discriminator values found: "same" => [DuplicateA, DuplicateB]')
    end

    it "raises error for duplicate integer discriminators" do
      stub_const("IntDupA", Class.new do
        include StoreModel::Model
        discriminator_attribute :version, type: :integer, value: 1
        attribute :data, :string
      end)

      stub_const("IntDupB", Class.new do
        include StoreModel::Model
        discriminator_attribute :version, type: :integer, value: 1
        attribute :info, :string
      end)

      expect do
        StoreModel.union([IntDupA, IntDupB], discriminator: "version")
      end.to raise_error(RuntimeError, "Duplicate discriminator values found: 1 => [IntDupA, IntDupB]")
    end
  end

  describe "missing discriminator validation" do
    it "raises error when discriminator attribute is not defined" do
      stub_const("NoDiscriminator", Class.new do
        include StoreModel::Model
        attribute :field, :string
      end)

      stub_const("HasDiscriminator", Class.new do
        include StoreModel::Model
        discriminator_attribute :kind, value: "valid"
        attribute :field, :string
      end)

      expect do
        StoreModel.union([NoDiscriminator, HasDiscriminator], discriminator: "kind")
      end.to raise_error(RuntimeError, "discriminator_attribute not set for kind on NoDiscriminator")
    end

    it "raises error when looking for non-existent discriminator key" do
      stub_const("WrongKey", Class.new do
        include StoreModel::Model
        discriminator_attribute :type, value: "test"
        attribute :field, :string
      end)

      expect do
        StoreModel.union([WrongKey], discriminator: "missing_key")
      end.to raise_error(RuntimeError, "discriminator_attribute not set for missing_key on WrongKey")
    end

    it "raises error for multiple classes missing discriminator" do
      stub_const("MissingA", Class.new do
        include StoreModel::Model
        attribute :field_a, :string
      end)

      stub_const("MissingB", Class.new do
        include StoreModel::Model
        attribute :field_b, :string
      end)

      stub_const("ValidClass", Class.new do
        include StoreModel::Model
        discriminator_attribute value: "valid"
        attribute :field_c, :string
      end)

      expect do
        StoreModel.union([MissingA, MissingB, ValidClass])
      end.to raise_error(RuntimeError, "discriminator_attribute not set for type on MissingA, MissingB")
    end
  end
end
