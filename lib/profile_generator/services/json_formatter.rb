# frozen_string_literal: true

require "json"
require "base64"

module ProfileGenerator
  module Services
    # Service for formatting JSON to HTML
    # Follows SRP - only handles JSON formatting
    class JsonFormatter
      # Format valid JSON to HTML
      # @param json_content [String] Valid JSON string
      # @return [String, nil] HTML representation or nil if invalid
      def format(json_content)
        parsed = parse_json(json_content)
        return nil unless parsed

        to_html(parsed)
      end

      # Format potentially truncated JSON with a warning message
      # @param json_content [String] Potentially incomplete JSON string
      # @return [String, nil] HTML with truncation warning or nil if unrecoverable
      def format_with_truncation_warning(json_content)
        parsed = parse_incomplete_json(json_content)
        return nil unless parsed

        truncation_warning + to_html(parsed)
      end

      # Encode formatted HTML as Base64 for placeholder replacement
      # @param json_content [String] JSON string
      # @return [String, nil] Base64 encoded HTML or nil if invalid
      def format_as_placeholder(json_content)
        html = format(json_content)
        return nil unless html

        "<!-- JSON_BLOCK:#{Base64.strict_encode64(html)} -->"
      end

      # Decode Base64 placeholder back to HTML
      # @param encoded [String] Base64 encoded string
      # @return [String] Decoded HTML
      def decode_placeholder(encoded)
        Base64.strict_decode64(encoded)
      end

      private

      def parse_json(content)
        JSON.parse(content)
      rescue JSON::ParserError
        nil
      end

      def parse_incomplete_json(content)
        # Try as-is first
        result = parse_json(content)
        return result if result

        # Try to recover truncated JSON
        recover_truncated_json(content)
      end

      def recover_truncated_json(content)
        last_close = find_last_complete_close(content)
        return nil unless last_close

        truncated = content[0..last_close]
        balanced = balance_brackets(truncated)
        parse_json(balanced)
      end

      def find_last_complete_close(content)
        content.rindex(/\}(?=\s*(?:,\s*\{|\s*\]|\s*$))/m)
      end

      def balance_brackets(content)
        open_braces = content.count("{") - content.count("}")
        open_brackets = content.count("[") - content.count("]")

        content + "\n#{'  ]' * open_brackets}#{"\n}" * open_braces}"
      end

      def to_html(obj, depth = 0)
        case obj
        when Hash then format_hash(obj, depth)
        when Array then format_array(obj, depth)
        else format_value(obj)
        end
      end

      def format_hash(hash, depth)
        items = hash.map do |key, value|
          "<div class='json-key-value'>" \
            "<strong class='json-key'>#{escape_html(key.to_s)}:</strong> " \
            "#{to_html(value, depth + 1)}</div>"
        end
        "<div class='json-object'>#{items.join}</div>"
      end

      def format_array(array, depth)
        items = array.map { |item| "<li>#{to_html(item, depth + 1)}</li>" }
        "<ul class='json-array'>#{items.join}</ul>"
      end

      def format_value(value)
        "<span class='json-value'>#{escape_html(value.to_s)}</span>"
      end

      def escape_html(text)
        text.gsub("&", "&amp;")
            .gsub("<", "&lt;")
            .gsub(">", "&gt;")
            .gsub('"', "&quot;")
            .gsub("'", "&#39;")
      end

      def truncation_warning
        '<div class="json-truncation-warning" style="background: #fff3cd; ' \
          "border-left: 4px solid #ffc107; padding: 12px; margin: 10px 0; " \
          'border-radius: 4px;"><strong>⚠️ Note:</strong> ' \
          "This JSON response was truncated due to API token limits. " \
          "Showing partial data.</div>"
      end
    end
  end
end
