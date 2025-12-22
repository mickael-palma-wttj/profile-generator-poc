# frozen_string_literal: true

module ProfileGenerator
  module Services
    module Anthropic
      # Handles retry logic for Anthropic API requests
      class RetryHandler
        RETRYABLE_ERROR_PATTERNS = [
          "rate limit", "429", "500", "502", "503", "504", "529",
          "timeout", "connection", "overloaded"
        ].freeze

        def initialize(config)
          @config = config
        end

        def with_retry
          attempt = 0
          begin
            attempt += 1
            yield
          rescue ::Anthropic::Errors::APIError => e
            raise unless attempt <= @config.max_retries && retryable_error?(e)

            delay = calculate_delay(attempt)
            warn "[Retry #{attempt}/#{@config.max_retries}] API error (#{e.message}). Retrying in #{delay.round(2)}s..."
            sleep(delay)
            retry
          end
        end

        private

        def retryable_error?(error)
          error_message = error.message.downcase
          RETRYABLE_ERROR_PATTERNS.any? { |pattern| error_message.include?(pattern) }
        end

        def calculate_delay(attempt)
          exponential_delay = @config.base_delay * (2**(attempt - 1))
          jitter = rand * @config.base_delay * 0.5
          [exponential_delay + jitter, 60.0].min
        end
      end
    end
  end
end
