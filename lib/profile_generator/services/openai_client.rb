# frozen_string_literal: true

require "openai"

module ProfileGenerator
  module Services
    # Main client for OpenAI API interactions
    # Delegates responsibilities to specialized classes
    class OpenAIClient
      class APIError < StandardError; end
      class ConfigurationError < StandardError; end

      DEFAULT_MODEL = OpenAI::Configuration::DEFAULT_MODEL

      def initialize(options = {})
        @config = OpenAI::Configuration.new(options)
        @config.validate!
        @logger = OpenAI::DebugLogger.new(@config)
        @client = ::OpenAI::Client.new(
          api_key: @config.api_key,
          timeout: @config.request_timeout
        )
        @payload_builder = OpenAI::PayloadBuilder.new(@client)
      end

      def generate(prompt:, system_prompt: nil, context: {})
        validate_prompt!(prompt)
        messages = @payload_builder.build_messages(prompt, system_prompt)

        with_retry do
          response = call_api(messages)
          @logger.log_response(response, { messages: messages }, context)
          extract_content(response)
        end
      rescue StandardError => e
        @logger.log_error(e, { messages: messages }, context)
        raise APIError, "OpenAI API error: #{e.message}"
      end

      def generate_file_analysis(prompt_content:, company_name: nil, context: {})
        context[:section] ||= "file_analysis"
        context[:company] ||= company_name || "unknown"

        system_prompt, content_blocks = @payload_builder.process_prompt_content(prompt_content)

        generate(
          prompt: content_blocks,
          system_prompt: system_prompt,
          context: context
        )
      end

      private

      def call_api(messages)
        params = {
          model: @config.model,
          messages: messages,
          temperature: @config.temperature
        }

        if use_max_completion_tokens?
          params[:max_completion_tokens] = @config.max_tokens
        else
          params[:max_tokens] = @config.max_tokens
        end

        @client.chat.completions.create(**params)
      end

      def use_max_completion_tokens?
        model = @config.model.to_s
        model.include?("gpt-5") || model.include?("o1") || model.include?("o3")
      end

      def validate_prompt!(prompt)
        return if prompt.is_a?(String) && !prompt.strip.empty?
        return if prompt.is_a?(Array) && !prompt.empty?

        raise ArgumentError, "Prompt cannot be empty"
      end

      def extract_content(response)
        if response.respond_to?(:choices)
          response.choices.first.message.content
        else
          response.dig("choices", 0, "message", "content")
        end
      end

      def with_retry
        retries = 0
        begin
          yield
        rescue StandardError => e
          raise e unless retries < @config.max_retries

          sleep(@config.base_delay * (2**retries))
          retries += 1
          retry
        end
      end
    end
  end
end
