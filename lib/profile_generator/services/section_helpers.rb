# frozen_string_literal: true

module ProfileGenerator
  module Services
    # Small helpers for building section HTML (indent, wrap, simple fences)
    module SectionHelpers
      def strip_code_fences(content)
        return content if content.nil? || content.strip.empty?

        stripped = content.strip
        if stripped.start_with?("```html")
          stripped = stripped.sub(/\A```html\s*\n?/, "").sub(/\n?```\z/, "")
        elsif stripped.start_with?("```")
          stripped = stripped.sub(/\A```\s*\n?/, "").sub(/\n?```\z/, "")
        end

        stripped
      end

      def looks_like_html?(content)
        return false if content.nil? || content.strip.empty?

        stripped = content.strip
        stripped.start_with?("<") && stripped.include?(">")
      end

      def indent_html(html, spaces)
        return "" if html.nil? || html.empty?

        indent = " " * spaces
        html.lines.map { |line| line.strip.empty? ? line : "#{indent}#{line}" }.join
      end

      def wrap_section_html(id, title, emoji, inner_html, active: false, extra_card_class: nil)
        active_class = active ? " active" : ""
        card_class = extra_card_class ? "card #{extra_card_class}" : "card"

        <<~HTML
                    <div id="#{id}" class="section#{active_class}">
                        <div class="#{card_class}">
                            <h2><span class="section-icon">#{emoji}</span>#{title}</h2>
          #{inner_html}
                        </div>
                    </div>
        HTML
      end
    end
  end
end
