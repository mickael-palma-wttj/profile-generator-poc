# frozen_string_literal: true

require "redcarpet"
require "json"
require "base64"

module ProfileGenerator
  module Services
    # Service for formatting LLM content (Markdown/JSON) to HTML
    # Handles both Markdown and JSON responses from Claude
    class ContentFormatter
      def initialize
        @markdown = Redcarpet::Markdown.new(
          Redcarpet::Render::HTML.new(
            hard_wrap: true,
            link_attributes: { target: "_blank", rel: "noopener noreferrer" }
          ),
          autolink: true,
          tables: true,
          fenced_code_blocks: true,
          strikethrough: true,
          superscript: true,
          underline: true,
          highlight: true,
          footnotes: true,
          no_intra_emphasis: true,
          space_after_headers: true
        )
      end

      # Format content to HTML
      # @param content [String] The raw content from LLM (Markdown or JSON)
      # @return [String] HTML formatted content
      def format(content)
        return "" if content.nil? || content.strip.empty?

        # Try to detect and parse JSON first
        if looks_like_json?(content)
          format_json(content)
        else
          # Default to Markdown parsing
          format_markdown(content)
        end
      end

      private

      def looks_like_json?(content)
        stripped = content.strip
        (stripped.start_with?("{") && stripped.end_with?("}")) ||
          (stripped.start_with?("[") && stripped.end_with?("]"))
      end

      def format_json(content)
        parsed = JSON.parse(content)
        json_to_html(parsed)
      rescue JSON::ParserError
        # If JSON parsing fails, fall back to Markdown
        format_markdown(content)
      end

      def format_markdown(content)
        # Clean up the content
        cleaned = clean_content(content)

        # Handle JSON code blocks - convert them to formatted JSON HTML
        cleaned = process_json_code_blocks(cleaned)

        # Convert Markdown to HTML
        html = @markdown.render(cleaned)

        # Post-process HTML for better styling
        post_process_html(html)
      end

      def process_json_code_blocks(content)
        # First, handle complete ```json code blocks (with closing ```)
        processed = content.gsub(/```json\s*\n(.*?)\n```/m) do
          json_content = Regexp.last_match(1)
          begin
            parsed = JSON.parse(json_content)
            # Replace with HTML comment placeholder that we'll process later
            "<!-- JSON_BLOCK:#{Base64.strict_encode64(json_to_html(parsed))} -->"
          rescue JSON::ParserError
            # If parsing fails, keep the original code block
            "```json\n#{json_content}\n```"
          end
        end

        # Handle incomplete/truncated ```json blocks (no closing ```)
        # This happens when the response hits max_tokens
        if processed.include?("```json")
          processed = processed.gsub(/```json\s*\n(\{.*)/m) do
            json_content = Regexp.last_match(1)
            # Try to extract whatever valid JSON we can
            formatted = format_incomplete_json(json_content)
            formatted || "```json\n#{json_content}"
          end
        end

        # Then, detect unwrapped JSON blocks (content between ``` markers or standalone JSON)
        processed = processed.gsub(/```\s*\n(\{.*?\})\s*\n?```/m) do
          json_content = Regexp.last_match(1)
          begin
            parsed = JSON.parse(json_content)
            "<!-- JSON_BLOCK:#{Base64.strict_encode64(json_to_html(parsed))} -->"
          rescue JSON::ParserError
            # Keep original if not valid JSON
            "```\n#{json_content}\n```"
          end
        end

        # Finally, detect standalone JSON objects that aren't in code blocks
        # Only match if there's a clear JSON structure with proper formatting
        processed.gsub(/^(\{\s*\n.*?^\})/m) do
          json_content = Regexp.last_match(1)
          # Try to parse it to confirm it's valid JSON
          begin
            parsed = JSON.parse(json_content)
            # Only format if it's a substantial JSON object (not a small inline one)
            if json_content.lines.count > 3
              "\n\n<!-- JSON_BLOCK:#{Base64.strict_encode64(json_to_html(parsed))} -->\n\n"
            else
              json_content
            end
          rescue JSON::ParserError
            # Keep original if not valid JSON
            json_content
          end
        end
      end

      # Try to format incomplete/truncated JSON
      def format_incomplete_json(json_content)
        # First, try to parse as-is (might be complete despite missing closing ```)
        begin
          parsed = JSON.parse(json_content)
          return "<!-- JSON_BLOCK:#{Base64.strict_encode64(json_to_html(parsed))} -->"
        rescue JSON::ParserError
          # If it fails, try to find the last complete object/array
          # Look for the last properly closed structure
          last_complete_close = json_content.rindex(/\}(?=\s*(?:,\s*\{|\s*\]|\s*$))/m)

          if last_complete_close
            # Try to extract up to the last complete structure
            truncated = json_content[0..last_complete_close]

            # Try to close any open structures
            open_braces = truncated.count("{") - truncated.count("}")
            open_brackets = truncated.count("[") - truncated.count("]")

            # Add closing braces/brackets
            if open_braces > 0 || open_brackets > 0
              truncated += "\n" + ("  ]" * open_brackets) + ("\n}" * open_braces)
            end

            begin
              parsed = JSON.parse(truncated)
              truncation_note = '<div class="json-truncation-warning" style="background: #fff3cd; border-left: 4px solid #ffc107; padding: 12px; margin: 10px 0; border-radius: 4px;"><strong>⚠️ Note:</strong> This JSON response was truncated due to API token limits. Showing partial data.</div>'
              formatted = truncation_note + json_to_html(parsed)
              return "<!-- JSON_BLOCK:#{Base64.strict_encode64(formatted)} -->"
            rescue JSON::ParserError
              # Still can't parse, give up and show as code
              nil
            end
          end
        end

        nil
      end

      def clean_content(content)
        # Remove common LLM preambles and meta-commentary
        cleaned = content
                  .gsub(/^I'll (research|analyze|provide|create|generate).*?\n\n/m, "")
                  .gsub(/^(Here's|Here is).*?:\n\n/m, "")
                  .gsub(/^Let me.*?\n\n/m, "")

        # Remove XML-like tags that LLMs sometimes include (search, thinking, etc.)
        cleaned = remove_xml_tags(cleaned)

        # Remove horizontal rules used as separators
        cleaned = cleaned.gsub(/^---+\s*$/m, "")

        cleaned.strip
      end

      def remove_xml_tags(content)
        # Remove <search>, <thinking>, <reflection>, <browse>, <url>, <web_search> and similar tags
        content
          .gsub(%r{<search>.*?</search>}m, "")
          .gsub(%r{<thinking>.*?</thinking>}m, "")
          .gsub(%r{<reflection>.*?</reflection>}m, "")
          .gsub(%r{<internal>.*?</internal>}m, "")
          .gsub(%r{<query>.*?</query>}m, "")
          .gsub(%r{<browse>.*?</browse>}m, "")
          .gsub(%r{<url>.*?</url>}m, "")
          .gsub(%r{<web_search>.*?</web_search>}m, "")
          # Remove standalone tags
          .gsub(%r{</?(?:search|thinking|reflection|internal|query|browse|url|web_search)>}i, "")
          # Clean up multiple blank lines left by tag removal
          .gsub(/\n{3,}/, "\n\n")
      end

      def post_process_html(html)
        processed = html
                    .gsub("<h1>", '<h1 class="content-h1">')
                    .gsub("<h2>", '<h2 class="content-h2">')
                    .gsub("<h3>", '<h3 class="content-h3">')
                    .gsub("<ul>", '<ul class="content-list">')
                    .gsub("<ol>", '<ol class="content-list-ordered">')
                    .gsub("<blockquote>", '<blockquote class="content-quote">')
                    .gsub("<code>", '<code class="content-code">')
                    .gsub("<pre>", '<pre class="content-pre">')
                    .gsub("<table>", '<table class="content-table">')

        # Replace JSON block placeholders with actual HTML
        processed.gsub(/<!-- JSON_BLOCK:(.*?) -->/) do
          Base64.strict_decode64(Regexp.last_match(1))
        end
      end

      def json_to_html(obj, depth = 0)
        case obj
        when Hash
          html = '<div class="json-object">'
          obj.each do |key, value|
            html += "<div class='json-key-value'>"
            html += "<strong class='json-key'>#{escape_html(key.to_s)}:</strong> "
            html += json_to_html(value, depth + 1)
            html += "</div>"
          end
          html + "</div>"
        when Array
          html = '<ul class="json-array">'
          obj.each do |item|
            html += "<li>#{json_to_html(item, depth + 1)}</li>"
          end
          html + "</ul>"
        else
          "<span class='json-value'>#{escape_html(obj.to_s)}</span>"
        end
      end

      def escape_html(text)
        text
          .gsub("&", "&amp;")
          .gsub("<", "&lt;")
          .gsub(">", "&gt;")
          .gsub('"', "&quot;")
          .gsub("'", "&#39;")
      end
    end
  end
end
