# frozen_string_literal: true

module ProfileGenerator
  module Services
    module Langfuse
      # Configuration for Langfuse client
      class Configuration
        class ConfigurationError < StandardError; end

        DEFAULT_BASE_URL = "https://cloud.langfuse.com"
        DEFAULT_TIMEOUT = 30

        attr_reader :base_url, :public_key, :secret_key, :timeout, :logger

        def initialize(options = {})
          @base_url = options[:base_url] || ENV.fetch("LANGFUSE_BASE_URL", DEFAULT_BASE_URL)
          @public_key = options[:public_key] || ENV.fetch("LANGFUSE_PUBLIC_KEY", nil)
          @secret_key = options[:secret_key] || ENV.fetch("LANGFUSE_SECRET_KEY", nil)
          @timeout = options[:timeout] || DEFAULT_TIMEOUT
          @logger = options[:logger] || LoggerFactory.build_default_logger
        end

        def validate!
          if @public_key.nil? || @public_key.empty?
            raise ConfigurationError,
                  "Langfuse public key is required. Set LANGFUSE_PUBLIC_KEY environment variable."
          end

          if @secret_key.nil? || @secret_key.empty?
            raise ConfigurationError,
                  "Langfuse secret key is required. Set LANGFUSE_SECRET_KEY environment variable."
          end

          return unless @base_url.nil? || @base_url.empty?

          raise ConfigurationError, "Langfuse base URL is required"
        end
      end
    end
  end
end
