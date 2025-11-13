# frozen_string_literal: true

module ProfileGenerator
  module Services
    # Cleans content by removing preambles, meta-commentary, and XML tags
    # Follows SRP - only responsible for content cleaning
    class ContentCleaner
      PREAMBLE_PATTERNS = [
        /^I'll (research|analyze|provide|create|generate).*?\n\n/m,
        /^(Here's|Here is).*?:\n\n/m,
        /^Let me.*?\n\n/m
      ].freeze

      XML_TAG_NAMES = %w[
        search thinking reflection internal query browse url web_search
      ].freeze

      def self.clean(content)
        new.clean(content)
      end

      # Remove preambles, XML tags, and normalize spacing
      # @param content [String] The raw content from LLM
      # @return [String] Cleaned content
      def clean(content)
        cleaned = remove_preambles(content)
        cleaned = remove_xml_tags(cleaned)
        remove_horizontal_rules(cleaned).strip
      end

      private

      def remove_preambles(content)
        PREAMBLE_PATTERNS.reduce(content) { |text, pattern| text.gsub(pattern, "") }
      end

      def remove_xml_tags(content)
        tag_names = XML_TAG_NAMES.join("|")
        closing_pattern = build_closing_tag_pattern
        content
          .gsub(%r{<(?:#{tag_names})>.*?</(?:#{tag_names})>}m, "")
          .gsub(closing_pattern, "")
          .gsub(/\n{3,}/, "\n\n")
      end

      def build_closing_tag_pattern
        names = XML_TAG_NAMES.join("|")
        %r{</?(?:#{names})>}i
      end

      def remove_horizontal_rules(content)
        content.gsub(/^---+\s*$/m, "")
      end
    end
  end
end
