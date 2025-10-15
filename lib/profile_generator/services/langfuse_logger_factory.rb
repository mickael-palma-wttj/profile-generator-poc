# frozen_string_literal: true

require "logger"

module ProfileGenerator
  module Services
    # Factory for building a default logger for LangfuseClient
    class LangfuseLoggerFactory
      def self.build_default_logger
        logger = Logger.new($stdout)
        logger.level = Logger::INFO
        logger.formatter = proc do |severity, datetime, _progname, msg|
          timestamp = datetime.strftime("%Y-%m-%d %H:%M:%S")
          "[#{timestamp}] #{severity}: #{msg}\n"
        end
        logger
      end
    end
  end
end
