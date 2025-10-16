# frozen_string_literal: true

RSpec.describe ProfileGenerator::Interactors::Result do
  describe ".success" do
    let(:result) { described_class.success({ foo: "bar" }, { generated: 1 }) }

    it "is successful" do
      expect(result).to be_success
    end

    it "exposes the provided value" do
      expect(result.value).to eq({ foo: "bar" })
    end

    it "exposes metadata" do
      expect(result.metadata).to eq({ generated: 1 })
    end

    it "has no error" do
      expect(result.error).to be_nil
    end
  end

  describe ".failure" do
    let(:result) { described_class.failure("something went wrong", { attempts: 2 }) }

    it "is a failure" do
      expect(result).to be_failure
    end

    it "exposes the error" do
      expect(result.error).to eq("something went wrong")
    end

    it "exposes metadata" do
      expect(result.metadata).to eq({ attempts: 2 })
    end

    it "has no value" do
      expect(result.value).to be_nil
    end
  end

  describe "predicate methods" do
    let(:success_result) { described_class.success }
    let(:failure_result) { described_class.failure("err") }

    it "reports success? for a success result" do
      expect(success_result).to be_success
    end

    it "does not report failure? for a success result" do
      expect(success_result).not_to be_failure
    end

    it "reports failure? for a failure result" do
      expect(failure_result).to be_failure
    end

    it "does not report success? for a failure result" do
      expect(failure_result).not_to be_success
    end
  end
end
