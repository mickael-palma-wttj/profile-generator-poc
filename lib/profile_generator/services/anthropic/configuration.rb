# frozen_string_literal: true

module ProfileGenerator
  module Services
    module Anthropic
      # Configuration for Anthropic client
      class Configuration
        DEFAULT_MODEL = "claude-sonnet-4-5-20250929"
        DEFAULT_MAX_TOKENS = 4096
        DEFAULT_TEMPERATURE = 0.7
        DEFAULT_MAX_RETRIES = 3
        DEFAULT_BASE_DELAY = 1.0

        attr_reader :api_key, :model, :max_tokens, :temperature,
                    :max_retries, :base_delay, :debug_mode, :debug_dir

        def initialize(options = {})
          @api_key = options[:api_key] || ENV.fetch("ANTHROPIC_API_KEY", nil)
          @model = options[:model] || ENV.fetch("ANTHROPIC_MODEL", DEFAULT_MODEL)
          @max_tokens = (options[:max_tokens] || ENV.fetch("ANTHROPIC_MAX_TOKENS", DEFAULT_MAX_TOKENS)).to_i
          @temperature = (options[:temperature] || ENV.fetch("ANTHROPIC_TEMPERATURE", DEFAULT_TEMPERATURE)).to_f
          @max_retries = (options[:max_retries] || ENV.fetch("ANTHROPIC_MAX_RETRIES", DEFAULT_MAX_RETRIES)).to_i
          @base_delay = (options[:base_delay] || ENV.fetch("ANTHROPIC_BASE_DELAY", DEFAULT_BASE_DELAY)).to_f
          @debug_mode = options[:debug_mode] || ENV.fetch("ANTHROPIC_DEBUG", "false") == "true"
          @debug_dir = options[:debug_dir] || ENV.fetch("ANTHROPIC_DEBUG_DIR", "debug/api_responses")
        end

        def validate!
          raise ConfigurationError, "ANTHROPIC_API_KEY is required" if api_key.nil? || api_key.strip.empty?
          raise ConfigurationError, "Model must be specified" if model.nil? || model.strip.empty?
        end
      end
    end
  end
end
