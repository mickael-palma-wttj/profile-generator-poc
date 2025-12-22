# frozen_string_literal: true

require "net/http"
require "uri"
require "base64"
require "cgi"

module ProfileGenerator
  module Services
    module Langfuse
      # Helper to build Langfuse URIs, add auth headers and execute HTTP requests.
      class Request
        def initialize(config)
          @config = config
        end

        def build_prompt_uri(prompt_name, version: nil, label: nil)
          path = "/api/public/v2/prompts/#{CGI.escape(prompt_name)}"
          query_params = []
          query_params << "version=#{version}" if version
          query_params << "label=#{CGI.escape(label)}" if label

          uri_string = "#{@config.base_url}#{path}"
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

          uri_string = "#{@config.base_url}#{path}?#{query_params.join('&')}"
          URI.parse(uri_string)
        end

        def add_auth_header(request)
          credentials = Base64.strict_encode64("#{@config.public_key}:#{@config.secret_key}")
          request["Authorization"] = "Basic #{credentials}"
        end

        def make_request(uri, request)
          Net::HTTP.start(uri.hostname, uri.port,
                          use_ssl: uri.scheme == "https",
                          read_timeout: @config.timeout,
                          open_timeout: @config.timeout) do |http|
            http.request(request)
          end
        rescue Net::OpenTimeout, Net::ReadTimeout => e
          raise "Request timeout: #{e.message}"
        rescue StandardError => e
          raise "Request failed: #{e.message}"
        end
      end
    end
  end
end
