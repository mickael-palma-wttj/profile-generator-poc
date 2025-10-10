# frozen_string_literal: true

require "redcarpet"

module ProfileGenerator
  module Services
    # Service for formatting LLM content (Markdown/JSON) to HTML
    # Handles both Markdown and JSON responses from Claude
    # Delegates JSON formatting to JsonFormatter service
    class ContentFormatter
      def initialize(json_formatter: nil)
        @json_formatter = json_formatter || JsonFormatter.new
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

        # Strip JSON code fences if AI wrapped JSON in ```json...```
        cleaned_content = strip_json_code_fences(content)

        # Try to detect and parse JSON first
        if looks_like_json_with_type?(cleaned_content)
          # New web component format
          format_as_component(cleaned_content)
        elsif looks_like_json?(cleaned_content)
          # Legacy JSON format (for backward compatibility)
          format_json(content)
        else
          # Default to Markdown parsing
          format_markdown(content)
        end
      end

      private

      # Check if content is JSON with a "type" field (new web component format)
      def looks_like_json_with_type?(content)
        stripped = content.strip
        return false unless stripped.start_with?("{") && stripped.end_with?("}")

        # Actually parse the JSON to check for "type" field
        begin
          data = JSON.parse(stripped)
          data.is_a?(Hash) && data.key?("type")
        rescue JSON::ParserError
          false
        end
      end

      def looks_like_json?(content)
        stripped = content.strip
        (stripped.start_with?("{") && stripped.end_with?("}")) ||
          (stripped.start_with?("[") && stripped.end_with?("]"))
      end

      # Format JSON as a web component
      def format_as_component(json_content)
        data = JSON.parse(json_content)
        section_type = data["type"]
        component_name = component_name_for_type(section_type)

        # Escape single quotes in JSON for HTML attribute
        escaped_json = json_content.gsub("'", "&apos;")

        # Return web component HTML
        %(<#{component_name} data='#{escaped_json}'></#{component_name}>)
      rescue JSON::ParserError
        # Fall back to markdown if JSON parsing fails
        format_markdown(json_content)
      end

      # Map section types to component names
      def component_name_for_type(type)
        case type
        when "company_description"
          "company-description-section"
        when "their_story"
          "their-story-section"
        when "company_values"
          "company-values-section"
        when "key_numbers"
          "key-numbers-section"
        when "funding_parser"
          "funding-section"
        when "leadership"
          "leadership-section"
        when "office_locations"
          "office-locations-section"
        when "perks_and_benefits"
          "perks-benefits-section"
        when "remote_policy"
          "remote-policy-section"
        else
          "generic-section"
        end
      end

      def format_json(content)
        html = @json_formatter.format(content)
        html || format_markdown(content)
      end

      def format_markdown(content)
        # Clean up the content
        cleaned = clean_content(content)

        # Strip HTML code fences if present (AI sometimes wraps HTML in ```html)
        cleaned = strip_html_code_fences(cleaned)

        # Handle JSON code blocks - convert them to formatted JSON HTML
        cleaned = process_json_code_blocks(cleaned)

        # Convert Markdown to HTML
        html = @markdown.render(cleaned)

        # Post-process HTML for better styling
        post_process_html(html)
      end

      # Strip ```json code fences that wrap JSON content
      # The AI sometimes returns JSON wrapped in markdown code blocks
      # despite being instructed not to
      def strip_json_code_fences(content)
        stripped = content.strip
        # Match ```json at start and ``` at end
        if stripped.start_with?("```json", "```\n{", "```\r\n{")
          stripped = stripped.sub(/^```(?:json)?\s*[\r\n]+/m, "")
          stripped = stripped.sub(/[\r\n\s]*```[\r\n\s]*$/m, "")
          stripped.strip
        else
          content
        end
      end

      # Strip ```html code fences that wrap HTML content
      # The AI sometimes returns HTML wrapped in markdown code blocks
      # which causes Redcarpet to escape it as code instead of rendering it
      def strip_html_code_fences(content)
        # Match ```html or ``` at start, HTML content, and ``` at end
        if /^```(?:html|HTML)?\s*[\r\n]/m.match?(content.strip)
          content = content.sub(/^```(?:html|HTML)?\s*[\r\n]+/m, "")
          content = content.sub(/[\r\n\s]*```[\r\n\s]*$/m, "")
          content.strip
        else
          content
        end
      end

      def process_json_code_blocks(content)
        # First, handle complete ```json code blocks (with closing ```)
        processed = content.gsub(/```json\s*\n(.*?)\n```/m) do
          json_content = Regexp.last_match(1)
          placeholder = @json_formatter.format_as_placeholder(json_content)
          placeholder || "```json\n#{json_content}\n```"
        end

        # Handle incomplete/truncated ```json blocks (no closing ```)
        if processed.include?("```json")
          processed = processed.gsub(/```json\s*\n(\{.*)/m) do
            json_content = Regexp.last_match(1)
            formatted = format_incomplete_json(json_content)
            formatted || "```json\n#{json_content}"
          end
        end

        # Then, detect unwrapped JSON blocks (content between ``` markers)
        processed = processed.gsub(/```\s*\n(\{.*?\})\s*\n?```/m) do
          json_content = Regexp.last_match(1)
          placeholder = @json_formatter.format_as_placeholder(json_content)
          placeholder || "```\n#{json_content}\n```"
        end

        # Finally, detect standalone JSON objects (multiline only)
        processed.gsub(/^(\{\s*\n.*?^\})/m) do
          json_content = Regexp.last_match(1)
          if json_content.lines.count > 3
            placeholder = @json_formatter.format_as_placeholder(json_content)
            placeholder ? "\n\n#{placeholder}\n\n" : json_content
          else
            json_content
          end
        end
      end

      # Try to format incomplete/truncated JSON
      def format_incomplete_json(json_content)
        html = @json_formatter.format_with_truncation_warning(json_content)
        return "<!-- JSON_BLOCK:#{encode_html(html)} -->" if html

        nil
      end

      def encode_html(html)
        require "base64"
        Base64.strict_encode64(html)
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
        processed = add_css_classes(html)
        decode_json_placeholders(processed)
      end

      def add_css_classes(html)
        html.gsub("<h1>", '<h1 class="content-h1">')
            .gsub("<h2>", '<h2 class="content-h2">')
            .gsub("<h3>", '<h3 class="content-h3">')
            .gsub("<ul>", '<ul class="content-list">')
            .gsub("<ol>", '<ol class="content-list-ordered">')
            .gsub("<blockquote>", '<blockquote class="content-quote">')
            .gsub("<code>", '<code class="content-code">')
            .gsub("<pre>", '<pre class="content-pre">')
            .gsub("<table>", '<table class="content-table">')
      end

      def decode_json_placeholders(html)
        html.gsub(/<!-- JSON_BLOCK:(.*?) -->/) do
          @json_formatter.decode_placeholder(Regexp.last_match(1))
        end
      end
    end
  end
end
