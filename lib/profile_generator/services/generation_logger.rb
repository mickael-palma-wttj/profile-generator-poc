# frozen_string_literal: true

require "logger"

module ProfileGenerator
  module Services
    # Observer for logging generation events
    # Follows Observer pattern and SRP - only responsible for logging
    class GenerationLogger
      SEPARATOR = ("=" * 60).freeze

      def initialize(logger: nil)
        @logger = logger || default_logger
      end

      # Log the start of profile generation
      def generation_started(company, section_names)
        log_with_separator do
          @logger.info("Starting profile generation for: #{company.name}")
          @logger.info("Website: #{company.website}") if company.website
          @logger.info("Sections to generate: #{section_names.join(', ')}")
        end
      end

      # Log the completion of profile generation
      def generation_completed(stats)
        log_with_separator do
          @logger.info("Profile generation complete!")
          @logger.info("Sections: #{stats[:generated]}/#{stats[:requested]} successful")
          @logger.info("Total duration: #{stats[:duration].round(2)}s")
          @logger.info("Average per section: #{stats[:average].round(2)}s")
        end
      end

      # Log when a section generation starts
      def section_started(section_name, company, retry_attempt = 0)
        if retry_attempt.positive?
          attempts = (retry_attempt + 1).to_s
          @logger.warn("Retrying section: #{section_name} (attempt #{attempts})")
        else
          @logger.info("Starting generation: #{section_name} (#{company.name})")
        end
      end

      # Log when a section generation completes successfully
      def section_completed(section_name, duration, content_length, retry_count)
        retry_info = retry_count.positive? ? " (after #{retry_count} retries)" : ""
        message = "Completed: #{section_name} in #{duration.round(2)}s " \
                  "(#{content_length} chars)#{retry_info}"
        @logger.info(message)
      end

      # Log when a section generation fails
      def section_failed(section_name, error, retry_count)
        @logger.error("Failed: #{section_name} after #{retry_count} attempts - #{error}")
      end

      # Log a general error
      def error(message)
        @logger.error(message)
      end

      # Log a general info message
      def info(message)
        @logger.info(message)
      end

      # Log a warning message
      def warn(message)
        @logger.warn(message)
      end

      # Log a debug message
      def debug(message)
        @logger.debug(message)
      end

      private

      def log_with_separator
        @logger.info(SEPARATOR)
        yield
        @logger.info(SEPARATOR)
      end

      def default_logger
        logger = Logger.new($stdout)
        logger.level = ENV.fetch("LOG_LEVEL", "INFO").upcase.to_sym
        logger.formatter = proc do |severity, datetime, _progname, msg|
          "[#{datetime.strftime('%Y-%m-%d %H:%M:%S')}] #{severity}: #{msg}\n"
        end
        logger
      end
    end
  end
end
