# frozen_string_literal: true

module ProfileGenerator
  module Services
    # Waits for file analysis to complete with timeout and polling
    # Follows SRP - only responsible for polling file analysis state
    class FileAnalysisWaiter
      MAX_WAIT_SECONDS = 120
      POLL_INTERVAL = 0.5

      def initialize(logger: nil)
        @logger = logger || NullLogger.new
      end

      # Wait until file analysis is ready (Hash) or timeout exceeded
      # @return [Hash] The file analysis result (empty hash if timed out)
      def wait_until_ready
        start_time = Time.now

        loop do
          analysis = ProfileGenerator.configuration.file_analysis
          return log_ready(analysis) if analysis.is_a?(Hash)

          elapsed = Time.now - start_time
          return log_timeout if elapsed > MAX_WAIT_SECONDS

          sleep POLL_INTERVAL
        end
      end

      private

      def log_ready(analysis)
        @logger.info("File analysis ready: #{analysis.keys.join(', ')}") if analysis.any?
        analysis
      end

      def log_timeout
        @logger.warn("File analysis did not complete within #{MAX_WAIT_SECONDS}s, proceeding")
        {}
      end

      # Null logger for when no logger is provided
      class NullLogger
        def info(_msg); end
        def warn(_msg); end
      end
    end
  end
end
