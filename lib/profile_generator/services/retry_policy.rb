# frozen_string_literal: true

module ProfileGenerator
  module Services
    # Determines whether an error is retryable
    # Follows Strategy pattern - encapsulates retry decision logic
    class RetryPolicy
      RETRYABLE_ERROR_PATTERNS = [
        "timeout", "connection", "rate limit", "503", "502",
        "500", "504", "529", "overloaded"
      ].freeze

      def self.retryable?(error)
        new.retryable?(error)
      end

      def retryable?(error)
        return true if error.is_a?(AnthropicClient::APIError)

        error_message = error.message.downcase
        RETRYABLE_ERROR_PATTERNS.any? { |pattern| error_message.include?(pattern) }
      end
    end
  end
end
