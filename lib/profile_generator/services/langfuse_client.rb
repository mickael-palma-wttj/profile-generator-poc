# frozen_string_literal: true

require "net/http"
require "uri"
require "json"
require "base64"
require "cgi"
require "logger"

module ProfileGenerator
  module Services
    # Service object for interacting with Langfuse API
    # Fetches prompt templates from Langfuse cloud
    # Uses Basic Auth with public/secret keys
    class LangfuseClient
      class APIError < StandardError; end
      class ConfigurationError < StandardError; end
      class PromptNotFoundError < StandardError; end

      DEFAULT_BASE_URL = "https://cloud.langfuse.com"
      DEFAULT_TIMEOUT = 30

      attr_reader :base_url, :public_key, :secret_key, :timeout, :logger

      def response_parser
        @response_parser ||= LangfuseResponseParser.new
      end

      def request_helper
        @request_helper ||= LangfuseRequest.new(
          base_url: @base_url,
          public_key: @public_key,
          secret_key: @secret_key,
          timeout: @timeout
        )
      end

      def initialize(
        base_url: nil,
        public_key: nil,
        secret_key: nil,
        timeout: nil,
        logger: nil
      )
        @base_url = base_url || ENV.fetch("LANGFUSE_BASE_URL", DEFAULT_BASE_URL)
        @public_key = public_key || ENV.fetch("LANGFUSE_PUBLIC_KEY", nil)
        @secret_key = secret_key || ENV.fetch("LANGFUSE_SECRET_KEY", nil)
        @timeout = timeout || DEFAULT_TIMEOUT
        @logger = logger || build_default_logger
        @response_logger = LangfuseResponseLogger.new(logger: @logger)

        validate_configuration!
      end

      # Get a prompt by name and optional version/label
      # @param prompt_name [String] The name of the prompt
      # @param version [Integer, nil] Optional version number
      # @param label [String, nil] Optional label (defaults to 'latest' if neither version nor label specified)
      # @return [Hash] The prompt data
      # @note When both version and label are nil, fetches the prompt with label 'latest'
      #       When only label is provided, returns the latest version with that label
      #       Langfuse API defaults to 'production' label when no parameters given, so we explicitly use 'latest'
      def get_prompt(prompt_name, version: nil, label: nil)
        # If neither version nor label specified, default to 'latest' label
        # (Langfuse API defaults to 'production' which may not exist)
        label = "latest" if version.nil? && label.nil?

        uri = request_helper.build_prompt_uri(prompt_name, version: version, label: label)

        execute_request_and_parse(uri, prompt_name: prompt_name, version: version, label: label)
      end

      # List all prompts with optional filters
      # @param name [String, nil] Optional prompt name filter
      # @param label [String, nil] Optional label filter
      # @param tag [String, nil] Optional tag filter
      # @param page [Integer] Page number (default: 1)
      # @param limit [Integer] Items per page (default: 50)
      # @return [Hash] Paginated list of prompts
      def list_prompts(name: nil, label: nil, tag: nil, page: 1, limit: 50)
        uri = request_helper.build_list_uri(name: name, label: label, tag: tag, page: page, limit: limit)

        logger.info("[Langfuse] Listing prompts (page: #{page}, limit: #{limit})")

        result = execute_request_and_parse(uri)
        prompt_count = result["data"]&.length || 0
        duration_var = (result["duration"] || 0).round(2)
        logger.info("[Langfuse] ✓ Listed #{prompt_count} prompts in #{duration_var}s")

        result
      end

      private

      def build_default_logger
        LangfuseLoggerFactory.build_default_logger
      end

      def execute_request_and_parse(uri, prompt_name: nil, version: nil, label: nil)
        @response_logger.log_request(prompt_name, version, label) if prompt_name

        request = prepare_request(uri)
        response, duration = perform_request(uri, request)

        parse_and_log_response(prompt_name, response, duration)
      end

      def prepare_request(uri)
        request = Net::HTTP::Get.new(uri)
        request["Content-Type"] = "application/json"
        request_helper.add_auth_header(request)
        request
      end

      def perform_request(uri, request)
        start_time = Time.now
        response = request_helper.make_request(uri, request)
        [response, Time.now - start_time]
      rescue Net::OpenTimeout, Net::ReadTimeout => e
        raise APIError, "Request timeout: #{e.message}"
      rescue StandardError => e
        raise APIError, "Request failed: #{e.message}"
      end

      include LangfuseClientResponseHandlers

      def parse_and_log_response(prompt_name, response, duration)
        result = response_parser.parse_response(response)
        @response_logger.log_response(prompt_name, result, duration) if prompt_name

        merge_duration(result, duration)
      rescue PromptNotFoundError => e
        handle_prompt_not_found(prompt_name, e)
      rescue APIError => e
        handle_api_error(prompt_name, e)
      rescue JSON::ParserError => e
        handle_json_parse_error(e)
      end

      def validate_configuration!
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

      # Request and auth helpers are delegated to LangfuseRequest

      # Logging and response parsing are delegated to collaborators
    end
  end
end
