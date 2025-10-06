# frozen_string_literal: true

require "zeitwerk"

module ProfileGenerator
  class Error < StandardError; end

  # Configuration management
  class Configuration
    attr_accessor :anthropic_api_key, :anthropic_model, :anthropic_max_tokens,
                  :anthropic_temperature

    def initialize
      @anthropic_api_key = ENV.fetch("ANTHROPIC_API_KEY", nil)
      @anthropic_model = ENV.fetch("ANTHROPIC_MODEL", "claude-3-5-sonnet-20241022")
      @anthropic_max_tokens = ENV.fetch("ANTHROPIC_MAX_TOKENS", "4096").to_i
      @anthropic_temperature = ENV.fetch("ANTHROPIC_TEMPERATURE", "0.7").to_f
    end
  end

  class << self
    attr_writer :configuration

    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end

    def reset_configuration!
      @configuration = Configuration.new
    end
  end
end

# Set up Zeitwerk autoloader AFTER the module is defined
loader = Zeitwerk::Loader.new
loader.push_dir(File.expand_path("profile_generator", __dir__), namespace: ProfileGenerator)
loader.setup
