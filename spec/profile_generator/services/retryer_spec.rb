# frozen_string_literal: true

RSpec.describe ProfileGenerator::Services::Retryer do
  let(:sleeps) { [] }
  let(:sleeper) { ->(s) { sleeps << s } }
  let(:logger) { nil }

  def perform_recovering_call(retryer)
    call_count = 0

    retryer.with_retries do
      call_count += 1
      raise StandardError, "timeout error" if call_count == 1

      "recovered"
    end
  end

  context "when block succeeds first time" do
    it "returns the value" do
      retryer = described_class.new(max_retries: 3, sleeper: sleeper, logger: logger)

      expect(retryer.with_retries { "ok" }).to eq("ok")
    end

    it "does not sleep" do
      retryer = described_class.new(max_retries: 3, sleeper: sleeper, logger: logger)

      retryer.with_retries { "ok" }
      expect(sleeps).to be_empty
    end
  end

  context "when block fails then succeeds" do
    it "retries and returns the value" do
      retryer = described_class.new(max_retries: 3, sleeper: sleeper, logger: logger, base_delay: 0.5, cap: 2.0)

      expect(perform_recovering_call(retryer)).to eq("recovered")
    end

    it "sleeps at least once" do
      retryer = described_class.new(max_retries: 3, sleeper: sleeper, logger: logger, base_delay: 0.5, cap: 2.0)

      perform_recovering_call(retryer)
      expect(sleeps.count).to be >= 1
    end
  end

  context "when retries exhausted" do
    it "raises the last error" do
      retryer = described_class.new(max_retries: 1, sleeper: sleeper, logger: logger)

      expect do
        retryer.with_retries { raise StandardError, "rate limit exceeded" }
      end.to raise_error(StandardError, /rate limit exceeded/)
    end

    it "sleeps once" do
      retryer = described_class.new(max_retries: 1, sleeper: sleeper, logger: logger)

      expect do
        retryer.with_retries { raise StandardError, "rate limit exceeded" }
      rescue StandardError
        # ignore
      end.to change(sleeps, :size).by(1)
    end
  end

  context "when error is not retryable" do
    it "raises immediately" do
      retryer = described_class.new(max_retries: 3, sleeper: sleeper, logger: logger)

      expect do
        retryer.with_retries { raise ArgumentError, "bad arg" }
      end.to raise_error(ArgumentError)
    end

    it "does not sleep" do
      retryer = described_class.new(max_retries: 3, sleeper: sleeper, logger: logger)

      expect do
        retryer.with_retries { raise ArgumentError, "bad arg" }
      rescue ArgumentError
        # ignore
      end.not_to change(sleeps, :size)
    end
  end

  context "when backoff cap is respected" do
    def perform_exhausting_call(retryer)
      attempt = 0

      begin
        retryer.with_retries do
          attempt += 1
          raise StandardError, "timeout" if attempt <= 4
        end
      rescue StandardError
        # ignore
      end
    end

    def call_and_ignore(retryer, error_class, msg)
      retryer.with_retries { raise error_class, msg }
    rescue StandardError
      # ignore
    end

    it "does not exceed cap" do
      sleeps_local = []
      sleeper_local = ->(s) { sleeps_local << s }
      cap_retryer = described_class.new(max_retries: 4, sleeper: sleeper_local, base_delay: 2.0, cap: 3.0)

      perform_exhausting_call(cap_retryer)
      expect(sleeps_local).to all(be <= 3.0)
    end
  end
end
