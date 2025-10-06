# frozen_string_literal: true

require "bundler/setup"
require "dotenv/load"
require_relative "../lib/profile_generator"

# Boot configuration for the application
module ProfileGenerator
  module Boot
    def self.call
      # Configure ProfileGenerator
      ProfileGenerator.configure do |config|
        config.anthropic_api_key = ENV.fetch("ANTHROPIC_API_KEY", nil)
        config.anthropic_model = ENV.fetch("ANTHROPIC_MODEL", "claude-sonnet-4-20250514")
        config.anthropic_max_tokens = ENV.fetch("ANTHROPIC_MAX_TOKENS", "4096").to_i
        config.anthropic_temperature = ENV.fetch("ANTHROPIC_TEMPERATURE", "0.7").to_f
      end

      # Validate configuration
      validate_configuration!
    end

    def self.validate_configuration!
      config = ProfileGenerator.configuration

      return unless config.anthropic_api_key.nil? || config.anthropic_api_key.strip.empty?

      raise ProfileGenerator::Error, "ANTHROPIC_API_KEY environment variable is required"
    end
  end
end

# Boot the application
ProfileGenerator::Boot.call
