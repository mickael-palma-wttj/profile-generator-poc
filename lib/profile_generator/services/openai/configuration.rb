# frozen_string_literal: true

module ProfileGenerator
  module Services
    module OpenAI
      # Configuration for OpenAI client
      class Configuration
        DEFAULT_MODEL = "gpt-5.2-2025-12-11"
        DEFAULT_MAX_TOKENS = 4096
        DEFAULT_TEMPERATURE = 0.7
        DEFAULT_MAX_RETRIES = 3
        DEFAULT_BASE_DELAY = 1.0

        attr_reader :api_key, :model, :max_tokens, :temperature,
                    :max_retries, :base_delay, :debug_mode, :debug_dir

        def initialize(options = {})
          @api_key = options[:api_key] || ENV.fetch("OPENAI_API_KEY", nil)
          @model = options[:model] || ENV.fetch("OPENAI_MODEL", DEFAULT_MODEL)
          @max_tokens = (options[:max_tokens] || ENV.fetch("OPENAI_MAX_TOKENS", DEFAULT_MAX_TOKENS)).to_i
          @temperature = (options[:temperature] || ENV.fetch("OPENAI_TEMPERATURE", DEFAULT_TEMPERATURE)).to_f
          @max_retries = (options[:max_retries] || ENV.fetch("OPENAI_MAX_RETRIES", DEFAULT_MAX_RETRIES)).to_i
          @base_delay = (options[:base_delay] || ENV.fetch("OPENAI_BASE_DELAY", DEFAULT_BASE_DELAY)).to_f
          @debug_mode = options[:debug_mode] || ENV.fetch("OPENAI_DEBUG", "false") == "true"
          @debug_dir = options[:debug_dir] || ENV.fetch("OPENAI_DEBUG_DIR", "debug/api_responses")
        end

        def validate!
          raise ConfigurationError, "OpenAI API key not found" unless @api_key
        end
      end
    end
  end
end
