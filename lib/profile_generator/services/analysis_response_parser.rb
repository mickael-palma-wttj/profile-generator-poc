# frozen_string_literal: true

require "json"

module ProfileGenerator
  module Services
    # Parses Anthropic API responses for file analysis
    # Follows SRP - only responsible for parsing response data
    class AnalysisResponseParser
      def initialize(logger: nil)
        @logger = logger
      end

      # Parse analysis response from API
      # @param response [Hash, Object] API response object
      # @return [Hash] Parsed JSON data or empty hash on failure
      def parse(response)
        content = extract_response_content(response)
        json_data = extract_json_from_content(content)

        @logger&.log_analysis_complete(json_data)
        json_data
      rescue StandardError => e
        @logger&.error("parse", e)
        {}
      end

      private

      def extract_response_content(response)
        case response
        when Hash
          response.dig("content", 0, "text") || ""
        else
          response.respond_to?(:content) ? response.content.first&.text || "" : response.to_s
        end
      end

      def extract_json_from_content(content)
        json_match = content.match(/\{[\s\S]*\}/)
        return {} unless json_match

        JSON.parse(json_match[0])
      end
    end
  end
end
