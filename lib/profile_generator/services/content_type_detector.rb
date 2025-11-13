# frozen_string_literal: true

module ProfileGenerator
  module Services
    # Detects the type of content (JSON with type, general JSON, or other)
    # Follows SRP - only responsible for content type detection
    class ContentTypeDetector
      # Check if content is JSON with a "type" field (new web component format)
      # @param content [String] The content to check
      # @return [Boolean] True if content is JSON with type field
      def json_with_type?(content)
        stripped = content.strip
        return false unless json_like_structure?(stripped)

        parse_and_check_type(stripped)
      end

      # Check if content is valid JSON (object or array)
      # @param content [String] The content to check
      # @return [Boolean] True if content looks like JSON
      def json?(content)
        stripped = content.strip
        json_like_structure?(stripped)
      end

      private

      def json_like_structure?(content)
        (content.start_with?("{") && content.end_with?("}")) ||
          (content.start_with?("[") && content.end_with?("]"))
      end

      def parse_and_check_type(content)
        data = JSON.parse(content)
        data.is_a?(Hash) && data.key?("type")
      rescue JSON::ParserError
        false
      end
    end
  end
end
