# frozen_string_literal: true

require "anthropic"
require "json"
require "fileutils"

module ProfileGenerator
  module Services
    # Service object for interacting with Anthropic's Claude API
    # Follows SRP - only responsible for API communication
    # Includes retry logic with exponential backoff
    class AnthropicClient
      class APIError < StandardError; end
      class ConfigurationError < StandardError; end

      DEFAULT_MODEL = "claude-sonnet-4-5-20250929"
      DEFAULT_MAX_TOKENS = 4096
      DEFAULT_TEMPERATURE = 0.7
      DEFAULT_MAX_RETRIES = 3
      DEFAULT_BASE_DELAY = 1.0

      RETRYABLE_ERROR_PATTERNS = [
        "rate limit", "429", "500", "502", "503", "504", "529",
        "timeout", "connection", "overloaded"
      ].freeze

      def initialize(
        api_key: nil,
        model: nil,
        max_tokens: nil,
        temperature: nil,
        max_retries: nil,
        base_delay: nil,
        debug_mode: nil,
        debug_dir: nil
      )
        @api_key = api_key || ENV.fetch("ANTHROPIC_API_KEY", nil)
        @model = model || ENV.fetch("ANTHROPIC_MODEL", DEFAULT_MODEL)
        @max_tokens = max_tokens || ENV.fetch("ANTHROPIC_MAX_TOKENS", DEFAULT_MAX_TOKENS).to_i
        @temperature = temperature || ENV.fetch("ANTHROPIC_TEMPERATURE", DEFAULT_TEMPERATURE).to_f
        @max_retries = max_retries || ENV.fetch("ANTHROPIC_MAX_RETRIES", DEFAULT_MAX_RETRIES).to_i
        @base_delay = base_delay || ENV.fetch("ANTHROPIC_BASE_DELAY", DEFAULT_BASE_DELAY).to_f
        @debug_mode = debug_mode || ENV.fetch("ANTHROPIC_DEBUG", "false") == "true"
        @debug_dir = debug_dir || ENV.fetch("ANTHROPIC_DEBUG_DIR", "debug/api_responses")

        validate_configuration!
        setup_debug_directory if @debug_mode
      end

      # Generate content using Claude API with retry logic
      # @param prompt [String] The prompt to send to Claude
      # @param system_prompt [String, nil] Optional system prompt
      # @param context [Hash, nil] Optional context for debug logging (e.g., company, section)
      # @return [String] The generated content
      def generate(prompt:, system_prompt: nil, context: {})
        validate_prompt!(prompt)

        response = nil
        with_retry do
          response = client.messages.create(
            model: model,
            max_tokens: max_tokens,
            temperature: temperature,
            system: system_prompt,
            messages: [
              { role: "user", content: prompt }
            ]
          )
          save_debug_response(response, prompt, system_prompt, context) if @debug_mode
          extract_content(response)
        end
      rescue Anthropic::Errors::APIError => e
        save_debug_error(e, prompt, system_prompt, context) if @debug_mode
        raise APIError, "Anthropic API error after #{@max_retries} retries: #{e.message}"
      end

      # Generate content with streaming (for future enhancement)
      # @param prompt [String] The prompt to send to Claude
      # @param system_prompt [String, nil] Optional system prompt
      # @yield [String] Yields chunks of generated content
      def generate_stream(prompt:, system_prompt: nil)
        validate_prompt!(prompt)

        client.messages.stream(
          model: model,
          max_tokens: max_tokens,
          temperature: temperature,
          system: system_prompt,
          messages: [
            { role: "user", content: prompt }
          ]
        ).text.each do |chunk|
          yield(chunk) if chunk
        end
      rescue Anthropic::Errors::APIError => e
        raise APIError, "Anthropic API error: #{e.message}"
      end

      # Generate file analysis with special handling for file content blocks
      # @param prompt_content [Array] Array with text and document blocks
      # @param company_name [String, nil] Company name for debug logging
      # @param context [Hash, nil] Optional context for debug logging
      # @return [Object] Raw API response object
      def generate_file_analysis(prompt_content:, company_name: nil, context: {})
        context[:section] ||= "file_analysis"
        context[:company] ||= company_name || "unknown"

        response = nil
        with_retry do
          response = client.messages.create(
            model: model,
            max_tokens: 2000,
            messages: [
              {
                role: "user",
                content: prompt_content
              }
            ]
          )
          save_debug_response(response, prompt_content, nil, context) if @debug_mode
          response
        end
      rescue Anthropic::Errors::APIError => e
        save_debug_error(e, prompt_content, nil, context) if @debug_mode
        raise APIError, "Anthropic API error during file analysis after #{@max_retries} retries: #{e.message}"
      end

      private

      attr_reader :api_key, :model, :max_tokens, :temperature, :max_retries, :base_delay,
                  :debug_mode, :debug_dir

      def client
        @client ||= Anthropic::Client.new(
          api_key: api_key,
          timeout: 120 # 2 minutes timeout for individual requests
        )
      end

      # Retry logic with exponential backoff and jitter
      def with_retry
        attempt = 0
        begin
          attempt += 1
          yield
        rescue Anthropic::Errors::APIError => e
          raise unless attempt <= max_retries && retryable_error?(e)

          delay = calculate_delay(attempt)
          warn "[Retry #{attempt}/#{max_retries}] API error (#{e.message}). Retrying in #{delay.round(2)}s..."
          sleep(delay)
          retry
        end
      end

      # Check if error is retryable (rate limit, server error, timeout, overloaded)
      def retryable_error?(error)
        error_message = error.message.downcase
        RETRYABLE_ERROR_PATTERNS.any? { |pattern| error_message.include?(pattern) }
      end

      # Calculate delay with exponential backoff and jitter
      # Formula: base_delay * (2 ** (attempt - 1)) + random_jitter
      def calculate_delay(attempt)
        exponential_delay = base_delay * (2**(attempt - 1))
        jitter = rand * base_delay * 0.5 # Random jitter up to 50% of base_delay
        [exponential_delay + jitter, 60.0].min # Cap at 60 seconds
      end

      def validate_configuration!
        raise ConfigurationError, "ANTHROPIC_API_KEY is required" if api_key.nil? || api_key.strip.empty?

        return unless model.nil? || model.strip.empty?

        raise ConfigurationError, "Model must be specified"
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

      # Setup debug directory
      def setup_debug_directory
        FileUtils.mkdir_p(debug_dir)
      end

      # Save raw API response for debugging
      def save_debug_response(response, prompt, system_prompt, context)
        timestamp = Time.now.strftime("%Y%m%d_%H%M%S_%L")
        company = context[:company] || "unknown"
        section = context[:section] || "unknown"

        filename = "#{timestamp}_#{company}_#{section}.json"
        filepath = File.join(debug_dir, filename)

        debug_data = {
          timestamp: timestamp,
          context: context,
          request: {
            model: model,
            max_tokens: max_tokens,
            temperature: temperature,
            system_prompt: system_prompt,
            user_prompt: format_prompt_for_debug(prompt)
          },
          response: response.to_h,
          extracted_content: extract_content(response)
        }

        File.write(filepath, JSON.pretty_generate(debug_data))
      rescue StandardError => e
        # Don't fail the main operation if debug logging fails
        warn "Failed to save debug response: #{e.message}"
      end

      # Format prompt for debug logging (handles both string and content arrays)
      def format_prompt_for_debug(prompt)
        if prompt.is_a?(Array)
          # File analysis prompt with content blocks
          prompt.map do |block|
            if block.is_a?(Hash)
              if block[:type] == :document
                "#{block[:type]}: #{block[:source]&.dig(:media_type) || 'unknown'} [base64-encoded]"
              else
                block
              end
            else
              block
            end
          end
        else
          prompt
        end
      end

      # Save error information for debugging
      def save_debug_error(error, prompt, system_prompt, context)
        timestamp = Time.now.strftime("%Y%m%d_%H%M%S_%L")
        company = context[:company] || "unknown"
        section = context[:section] || "unknown"

        filename = "#{timestamp}_#{company}_#{section}_ERROR.json"
        filepath = File.join(debug_dir, filename)

        debug_data = {
          timestamp: timestamp,
          context: context,
          request: {
            model: model,
            max_tokens: max_tokens,
            temperature: temperature,
            system_prompt: system_prompt,
            user_prompt: format_prompt_for_debug(prompt)
          },
          error: {
            class: error.class.name,
            message: error.message,
            backtrace: error.backtrace&.first(10)
          }
        }

        File.write(filepath, JSON.pretty_generate(debug_data))
      rescue StandardError => e
        # Don't fail the main operation if debug logging fails
        warn "Failed to save debug error: #{e.message}"
      end
    end
  end
end
