# frozen_string_literal: true

require "anthropic"

module ProfileGenerator
  module Services
    # Service object for interacting with Anthropic's Claude API
    # Follows SRP - only responsible for API communication
    # Includes retry logic with exponential backoff
    class AnthropicClient
      class APIError < StandardError; end
      class ConfigurationError < StandardError; end

      DEFAULT_MODEL = Anthropic::Configuration::DEFAULT_MODEL

      def initialize(options = {})
        @config = Anthropic::Configuration.new(options)
        @config.validate!
        @logger = Anthropic::DebugLogger.new(@config)
        @retry_handler = Anthropic::RetryHandler.new(@config)
        @client = ::Anthropic::Client.new(api_key: @config.api_key, timeout: 120)
      end

      def generate(prompt:, system_prompt: nil, context: {})
        validate_prompt!(prompt)
        messages = [{ role: "user", content: prompt }]

        @retry_handler.with_retry do
          response = client_create(messages, system_prompt)
          @logger.log_response(response, { messages: messages, system: system_prompt }, context)
          extract_content(response)
        end
      rescue ::Anthropic::Errors::APIError => e
        @logger.log_error(e, { messages: messages, system: system_prompt }, context)
        raise APIError, "Anthropic API error: #{e.message}"
      end

      def generate_file_analysis(prompt_content:, company_name: nil, context: {})
        context[:section] ||= "file_analysis"
        context[:company] ||= company_name || "unknown"

        messages = [{ role: "user", content: prompt_content }]

        @retry_handler.with_retry do
          response = client_create(messages, nil, max_tokens: 2000)
          @logger.log_response(response, { messages: messages }, context)
          response
        end
      rescue ::Anthropic::Errors::APIError => e
        @logger.log_error(e, { messages: messages }, context)
        raise APIError, "Anthropic API error during file analysis: #{e.message}"
      end

      private

      def client_create(messages, system_prompt, max_tokens: nil)
        @client.messages.create(
          model: @config.model,
          max_tokens: max_tokens || @config.max_tokens,
          temperature: @config.temperature,
          system: system_prompt,
          messages: messages
        )
      end

      def validate_prompt!(prompt)
        return unless prompt.nil? || prompt.strip.empty?

        raise ArgumentError, "Prompt cannot be empty"
      end

      def extract_content(response)
        response.content.first.text
      rescue StandardError => e
        raise APIError, "Failed to extract content from response: #{e.message}"
      end
    end
  end
end
