# frozen_string_literal: true

require "erb"
require "fileutils"

module ProfileGenerator
  module Services
    # Service for generating beautiful standalone HTML pages from company profiles
    # Follows SRP - single responsibility for HTML generation
    # Uses the same HTML structure as the manually created qonto_profile.html
    class HtmlGenerator
      def initialize(template_path: nil)
        @template_path = template_path || default_template_path
        @content_formatter = ContentFormatter.new
        @section_builder = SectionBuilder.new(content_formatter: @content_formatter)
      end

      # Generate a standalone HTML page from a profile
      # @param profile [Models::Profile] The profile to convert to HTML
      # @return [String] The generated HTML content
      def generate(profile)
        # Generate the complete HTML page
        generate_from_profile(profile)
      end

      # Save the generated HTML to a file
      # @param profile [Models::Profile] The profile to convert
      # @param output_path [String] Where to save the HTML file
      # @return [String] The path to the saved file
      def generate_and_save(profile, output_path)
        html = generate(profile)

        # Ensure directory exists
        FileUtils.mkdir_p(File.dirname(output_path))

        File.write(output_path, html)
        puts "✅ HTML page generated: #{output_path}"
        output_path
      end

      private

      def default_template_path
        File.join(__dir__, "..", "..", "..", "templates", "profile_page.html.erb")
      end

      def generate_from_profile(profile)
        render_page(profile, build_all_sections(profile))
      end

      def render_page(profile, sections_html)
        <<~HTML
          <!DOCTYPE html>
          <html lang="en">
          <head>
              <meta charset="UTF-8">
              <meta name="viewport" content="width=device-width, initial-scale=1.0">
              <title>#{escape_html(profile.company.name)} - Company Profile</title>
              #{css_styles}
          </head>
          <body>
              #{hero_section(profile)}
              <div class="container">
                  #{navigation_tabs}
                  #{sections_html}
              </div>
              #{javascript}
          </body>
          </html>
        HTML
      end

      def hero_section(profile)
        <<~HTML
          <div class="hero">
              <div class="hero-content">
                  <h1>#{escape_html(profile.company.name)}</h1>
                  <p class="subtitle">Company Profile</p>
                  <p class="date">Generated: #{profile.generated_at.strftime('%d/%m/%Y')}</p>
              </div>
          </div>
        HTML
      end

      def navigation_tabs
        <<~HTML
          <nav class="nav-tabs">
              <button class="nav-tab active" onclick="showSection('story')">📖 Their Story</button>
              <button class="nav-tab" onclick="showSection('values')">💎 Values</button>
              <button class="nav-tab" onclick="showSection('description')">🏢 Company Overview</button>
              <button class="nav-tab" onclick="showSection('leadership')">👥 Leadership</button>
              <button class="nav-tab" onclick="showSection('numbers')">📊 Key Numbers</button>
              <button class="nav-tab" onclick="showSection('locations')">📍 Locations</button>
              <button class="nav-tab" onclick="showSection('perks')">🎁 Perks & Benefits</button>
              <button class="nav-tab" onclick="showSection('remote')">🏠 Remote Policy</button>
              <button class="nav-tab" onclick="showSection('funding')">💰 Funding</button>
          </nav>
        HTML
      end

      def build_all_sections(profile)
        @section_builder.build_all_sections(profile)
      end

      # Section building is delegated to SectionBuilder

      def escape_html(text)
        return "" if text.nil?

        text.to_s
            .gsub("&", "&amp;")
            .gsub("<", "&lt;")
            .gsub(">", "&gt;")
            .gsub('"', "&quot;")
            .gsub("'", "&#39;")
      end

      def css_styles
        # Inline CSS from qonto_profile.html
        File.read(File.join(__dir__, "..", "..", "..", "public", "qonto_profile.html"))
            .match(%r{<style>(.*?)</style>}m)[1]
            .then { |css| "<style>#{css}</style>" }
      rescue StandardError
        # Fallback minimal styles
        "<style>body { font-family: sans-serif; max-width: 1200px; margin: 0 auto; padding: 20px; }</style>"
      end

      def javascript
        <<~JS
          <script>
              function showSection(sectionId) {
                  document.querySelectorAll('.section').forEach(section => {
                      section.classList.remove('active');
                  });
                  document.querySelectorAll('.nav-tab').forEach(tab => {
                      tab.classList.remove('active');
                  });
                  document.getElementById(sectionId).classList.add('active');
                  event.target.classList.add('active');
                  window.scrollTo({ top: 0, behavior: 'smooth' });
              }
          </script>
        JS
      end
    end
  end
end
