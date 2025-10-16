# frozen_string_literal: true

module ProfileGenerator
  module Services
    # Retryer provides a simple retry-with-backoff policy.
    # It accepts a sleeper lambda for testability (so tests can avoid real sleep).
    class Retryer
      def initialize(max_retries:, logger: nil, base_delay: 1.0, cap: 30.0, sleeper: ->(s) { sleep(s) })
        @max_retries = max_retries
        @logger = logger
        @base_delay = base_delay
        @cap = cap
        @sleeper = sleeper
      end

      # Yields to block and returns the block value on success.
      # Raises last error if retries exhausted.
      def with_retries
        attempt = 0

        loop do
          return yield
        rescue StandardError => e
          raise e if attempt >= @max_retries || !retryable_error?(e)

          perform_backoff(attempt)
          attempt += 1
          next
        end
      end

      def perform_backoff(attempt)
        delay = [@base_delay * (2**attempt), @cap].min
        @logger&.debug("Waiting #{format('%.2f', delay)}s before retry...")
        @sleeper.call(delay)
      end

      private

      def retryable_error?(error)
        return true if error.is_a?(ProfileGenerator::Services::AnthropicClient::APIError)

        msg = error.message.to_s.downcase
        %w[timeout connection rate limit 503 502 500 504 529 overloaded].any? { |p| msg.include?(p) }
      end
    end
  end
end
