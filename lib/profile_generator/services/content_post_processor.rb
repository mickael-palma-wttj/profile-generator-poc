# frozen_string_literal: true

module ProfileGenerator
  module Services
    # Small helper to post-process HTML produced by the markdown/json formatters
    class ContentPostProcessor
      def initialize(json_formatter:)
        @json_formatter = json_formatter
      end

      def post_process(html)
        processed = add_css_classes(html)
        decode_json_placeholders(processed)
      end

      private

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
