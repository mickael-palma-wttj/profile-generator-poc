# frozen_string_literal: true

module ProfileGenerator
  module Services
    # Calculates exponential backoff delay with jitter
    # Follows SRP - only responsible for backoff delay calculation
    class BackoffCalculator
      MAX_DELAY = 30.0 # Maximum 30 seconds delay
      BASE_DELAY = 1.0

      def self.calculate(attempt)
        new.calculate(attempt)
      end

      # Calculate exponential backoff with jitter
      # Formula: base * (2 ** attempt) + random_jitter, capped at MAX_DELAY
      # @param attempt [Integer] The retry attempt number (0-indexed)
      # @return [Float] The delay in seconds
      def calculate(attempt)
        exponential = BASE_DELAY * (2**attempt)
        jitter = rand * BASE_DELAY * 0.5
        delay = exponential + jitter
        [delay, MAX_DELAY].min
      end
    end
  end
end
