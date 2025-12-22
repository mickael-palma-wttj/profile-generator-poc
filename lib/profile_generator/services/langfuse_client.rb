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
      ConfigurationError = Langfuse::Configuration::ConfigurationError
      PromptNotFoundError = Langfuse::ResponseParser::PromptNotFoundError

      attr_reader :config, :logger

      def base_url
        @config.base_url
      end

      def public_key
        @config.public_key
      end

      def initialize(options = {})
        @config = Langfuse::Configuration.new(options)
        @config.validate!
        @logger = @config.logger
        @response_logger = Langfuse::ResponseLogger.new(logger: @logger)
      end

      def response_parser
        @response_parser ||= Langfuse::ResponseParser.new
      end

      def request_helper
        @request_helper ||= Langfuse::Request.new(@config)
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

      include Langfuse::ResponseHandlers

      def parse_and_log_response(prompt_name, response, duration)
        result = response_parser.parse_response(response)
        @response_logger.log_response(prompt_name, result, duration) if prompt_name

        merge_duration(result, duration)
      rescue PromptNotFoundError => e
        handle_prompt_not_found(prompt_name, e)
      rescue Langfuse::ResponseParser::APIError => e
        handle_api_error(prompt_name, e)
      rescue JSON::ParserError => e
        handle_json_parse_error(e)
      end
    end
  end
end
