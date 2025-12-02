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
        @post_processor = ContentPostProcessor.new(json_formatter: @json_formatter)

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

        detector = Services::ContentTypeDetector.new
        cleaned = strip_json_code_fences(content)
        format_by_type(cleaned, detector)
      end

      private

      def format_by_type(content, detector)
        if detector.json_with_type?(content)
          format_as_component(content)
        elsif detector.json?(content)
          format_json(content)
        else
          format_markdown(content)
        end
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
        mapping = {
          "company_description" => "company-description-section",
          "their_story" => "their-story-section",
          "company_values" => "company-values-section",
          "key_numbers" => "key-numbers-section",
          "funding_parser" => "funding-section",
          "leadership" => "leadership-section",
          "office_locations" => "office-locations-section",
          "perks_and_benefits" => "perks-benefits-section",
          "remote_policy" => "remote-policy-section",
          "what_we_are_looking_for" => "what-we-are-looking-for-section",
          "file_analysis" => "file-analysis-section"
        }

        mapping[type] || "generic-section"
      end

      def format_json(content)
        html = @json_formatter.format(content)
        html || format_markdown(content)
      end

      def format_markdown(content)
        cleaned = Services::ContentCleaner.clean(content)
        cleaned = strip_html_code_fences(cleaned)
        cleaned = process_json_code_blocks(cleaned)
        html = @markdown.render(cleaned)
        @post_processor.post_process(html)
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

      def format_incomplete_json(json_content)
        html = @json_formatter.format_with_truncation_warning(json_content)
        return "<!-- JSON_BLOCK:#{encode_html(html)} -->" if html

        nil
      end

      # post-processing responsibilities extracted to ContentPostProcessor
    end
  end
end
