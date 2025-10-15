# frozen_string_literal: true

require "English"
module ProfileGenerator
  module Helpers
    # Service for formatting section content in views
    # Handles HTML detection, code fence stripping, and markdown formatting
    class SectionContentHelper
      # Content div class names that indicate actual content (not AI thinking/search)
      CONTENT_DIV_CLASSES = %w[
        value-card
        story-content
        company-overview
        leader-card
        funding-content
        stats-grid
        locations-grid
        perks-grid
        remote-policy-content
      ].freeze

      # Indicators that suggest AI included thinking/search tags in output
      THINKING_TAG_INDICATORS = [
        '<code class="search">',
        '<h1 class="content-h1">Searching for'
      ].freeze

      # Format section content, handling various edge cases
      # @param content [String] Raw section content from AI
      # @return [String] Formatted HTML content
      def self.format(content)
        new.format(content)
      end

      def format(content)
        return "" if blank?(content)

        cleaned = content.strip
        cleaned = strip_code_fences(cleaned)
        cleaned = strip_thinking_tags(cleaned)

        html?(cleaned) ? cleaned : format_as_markdown(cleaned)
      end

      private

      def blank?(content)
        content.nil? || content.strip.empty?
      end

      # Strip markdown code fences (```html or ```)
      # AI sometimes wraps HTML output in code fences despite prompt instructions
      def strip_code_fences(content)
        return content unless code_fence?(content)

        content
          .sub(/\A```(?:html|HTML)?[\s\r\n]+/m, "")
          .sub(/[\s\r\n]*```[\s\r\n]*\z/m, "")
          .strip
      end

      def code_fence?(content)
        !!(content =~ /\A```(?:html|HTML)?[\s\r\n]+/m)
      end

      # Remove AI thinking/search tags if present
      # Extracts actual content div if thinking tags are detected
      def strip_thinking_tags(content)
        return content unless thinking_tags?(content)

        if content =~ content_div_pattern
          content[$LAST_MATCH_INFO.pre_match.length..]
        else
          content
        end
      end

      def thinking_tags?(content)
        THINKING_TAG_INDICATORS.any? { |indicator| content.include?(indicator) }
      end

      def content_div_pattern
        # match an opening div tag with one of the known content classes
        @content_div_pattern ||= /<div class="(?:#{CONTENT_DIV_CLASSES.join('|')})"/
      end

      def html?(content)
        content.start_with?("<") && content.include?(">")
      end

      def format_as_markdown(content)
        ProfileGenerator::Services::ContentFormatter.new.format(content)
      end
    end
  end
end
