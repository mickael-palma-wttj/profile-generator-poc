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

        uri = build_prompt_uri(prompt_name, version: version, label: label)

        log_request(prompt_name, version, label)

        request = Net::HTTP::Get.new(uri)
        add_auth_header(request)
        request["Content-Type"] = "application/json"

        start_time = Time.now
        response = make_request(uri, request)
        duration = Time.now - start_time

        result = parse_response(response)
        log_response(prompt_name, result, duration)

        result
      rescue PromptNotFoundError
        logger.error("[Langfuse] ✗ Prompt '#{prompt_name}' not found")
        raise
      rescue APIError => e
        logger.error("[Langfuse] ✗ API error for '#{prompt_name}': #{e.message}")
        raise
      rescue JSON::ParserError => e
        logger.error("[Langfuse] ✗ Failed to parse response: #{e.message}")
        raise APIError, "Failed to parse Langfuse response: #{e.message}"
      end

      # List all prompts with optional filters
      # @param name [String, nil] Optional prompt name filter
      # @param label [String, nil] Optional label filter
      # @param tag [String, nil] Optional tag filter
      # @param page [Integer] Page number (default: 1)
      # @param limit [Integer] Items per page (default: 50)
      # @return [Hash] Paginated list of prompts
      def list_prompts(name: nil, label: nil, tag: nil, page: 1, limit: 50)
        uri = build_list_uri(name: name, label: label, tag: tag, page: page, limit: limit)

        logger.info("[Langfuse] Listing prompts (page: #{page}, limit: #{limit})")

        request = Net::HTTP::Get.new(uri)
        add_auth_header(request)
        request["Content-Type"] = "application/json"

        start_time = Time.now
        response = make_request(uri, request)
        duration = Time.now - start_time

        result = parse_response(response)
        prompt_count = result.dig("data")&.length || 0
        logger.info("[Langfuse] ✓ Listed #{prompt_count} prompts in #{duration.round(2)}s")

        result
      rescue APIError => e
        logger.error("[Langfuse] ✗ Failed to list prompts: #{e.message}")
        raise
      rescue JSON::ParserError => e
        logger.error("[Langfuse] ✗ Failed to parse response: #{e.message}")
        raise APIError, "Failed to parse Langfuse response: #{e.message}"
      end

      private

      def build_default_logger
        logger = Logger.new($stdout)
        logger.level = Logger::INFO
        logger.formatter = proc do |severity, datetime, _progname, msg|
          timestamp = datetime.strftime("%Y-%m-%d %H:%M:%S")
          "[#{timestamp}] #{severity}: #{msg}\n"
        end
        logger
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

      def build_prompt_uri(prompt_name, version: nil, label: nil)
        path = "/api/public/v2/prompts/#{CGI.escape(prompt_name)}"
        query_params = []
        query_params << "version=#{version}" if version
        query_params << "label=#{CGI.escape(label)}" if label

        uri_string = "#{@base_url}#{path}"
        uri_string += "?#{query_params.join('&')}" unless query_params.empty?

        URI.parse(uri_string)
      end

      def build_list_uri(name: nil, label: nil, tag: nil, page: 1, limit: 50)
        path = "/api/public/v2/prompts"
        query_params = []
        query_params << "name=#{CGI.escape(name)}" if name
        query_params << "label=#{CGI.escape(label)}" if label
        query_params << "tag=#{CGI.escape(tag)}" if tag
        query_params << "page=#{page}"
        query_params << "limit=#{limit}"

        uri_string = "#{@base_url}#{path}?#{query_params.join('&')}"
        URI.parse(uri_string)
      end

      def add_auth_header(request)
        # Langfuse uses HTTP Basic Auth with public_key as username and secret_key as password
        credentials = Base64.strict_encode64("#{@public_key}:#{@secret_key}")
        request["Authorization"] = "Basic #{credentials}"
      end

      def make_request(uri, request)
        Net::HTTP.start(uri.hostname, uri.port,
                        use_ssl: uri.scheme == "https",
                        read_timeout: @timeout,
                        open_timeout: @timeout) do |http|
          http.request(request)
        end
      rescue Net::OpenTimeout, Net::ReadTimeout => e
        raise APIError, "Request timeout: #{e.message}"
      rescue StandardError => e
        raise APIError, "Request failed: #{e.message}"
      end

      def parse_response(response)
        case response.code.to_i
        when 200..299
          JSON.parse(response.body)
        when 401
          raise APIError, "Authentication failed. Check your Langfuse API keys."
        when 404
          raise PromptNotFoundError, "Prompt not found"
        when 400..499
          error_msg = extract_error_message(response.body)
          raise APIError, "Client error (#{response.code}): #{error_msg}"
        when 500..599
          raise APIError, "Langfuse server error (#{response.code})"
        else
          raise APIError, "Unexpected response code: #{response.code}"
        end
      end

      def extract_error_message(body)
        JSON.parse(body)["message"]
      rescue JSON::ParserError, NoMethodError
        body
      end

      def log_request(prompt_name, version, label)
        params = []
        params << "version: #{version}" if version
        params << "label: '#{label}'" if label
        params_str = params.empty? ? "" : " (#{params.join(', ')})"

        logger.info("[Langfuse] Fetching prompt: '#{prompt_name}'#{params_str}")
      end

      def log_response(prompt_name, result, duration)
        version = result["version"]
        labels = result["labels"]&.join(", ") || "none"
        prompt_type = result["type"]
        content_length = case prompt_type
                         when "text"
                           result["prompt"]&.length || 0
                         when "chat"
                           result["prompt"]&.map { |m| m["content"]&.length || 0 }&.sum || 0
                         else
                           0
                         end

        logger.info("[Langfuse] ✓ Fetched '#{prompt_name}' v#{version} [#{labels}] (#{prompt_type}, #{content_length} chars) in #{duration.round(2)}s")
      end
    end
  end
end
