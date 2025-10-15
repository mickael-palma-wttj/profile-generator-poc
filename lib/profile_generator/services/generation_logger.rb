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
          if company&.output_language
            lang_label = company.output_language_label || company.output_language
            @logger.info("Output language: #{lang_label}")
            @logger.info("Output locale: #{company.output_language}")
          end
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
          message = "Starting generation: #{section_name} (#{company.name})"
          message += lang_suffix(company)
          @logger.info(message)
        end
      end

      # Log when a section generation completes successfully
      # section_completed accepts an options hash to avoid long parameter lists
      # options may include :retry_count and :company
      def section_completed(section_name, duration, content_length, options = {})
        retry_count = options.fetch(:retry_count, 0)
        company = options[:company]

        retry_info = retry_count.positive? ? " (after #{retry_count} retries)" : ""
        message = "Completed: #{section_name} in #{duration.round(2)}s " \
                  "(#{content_length} chars)#{retry_info}"
        message += lang_suffix(company)
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

      def lang_suffix(company)
        return "" unless company&.output_language

        lang_label = company.output_language_label || company.output_language
        " [lang: #{lang_label} (#{company.output_language})]"
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
