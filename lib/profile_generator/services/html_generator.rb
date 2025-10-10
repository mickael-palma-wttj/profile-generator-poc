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
        # Generate complete HTML structure matching qonto_profile.html
        sections = build_all_sections(profile)

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
                  #{sections}
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
        sections = []

        sections << build_story_section(profile)
        sections << build_values_section(profile)
        sections << build_description_section(profile)
        sections << build_leadership_section(profile)
        sections << build_numbers_section(profile)
        sections << build_locations_section(profile)
        sections << build_perks_section(profile)
        sections << build_remote_section(profile)
        sections << build_funding_section(profile)

        sections.join("\n")
      end

      def build_story_section(profile)
        content = get_section_html(profile, "their_story")
        indented_content = indent_html(content, 18)

        <<~HTML
                    <div id="story" class="section active">
                        <div class="card story-card">
                            <h2><span class="section-icon">📖</span>Their Story</h2>
          #{indented_content}
                        </div>
                    </div>
        HTML
      end

      def build_values_section(profile)
        content = get_section_html(profile, "company_values")
        indented_content = indent_html(content, 22)

        <<~HTML
                    <div id="values" class="section">
                        <div class="card">
                            <h2><span class="section-icon">💎</span>Company Values</h2>
                            <div class="values-grid">
          #{indented_content}
                            </div>
                        </div>
                    </div>
        HTML
      end

      def build_description_section(profile)
        content = get_section_html(profile, "company_description")
        indented_content = indent_html(content, 18)

        <<~HTML
                    <div id="description" class="section">
                        <div class="card">
                            <h2><span class="section-icon">🏢</span>Company Overview</h2>
          #{indented_content}
                        </div>
                    </div>
        HTML
      end

      def build_leadership_section(profile)
        content = get_section_html(profile, "leadership")
        indented_content = indent_html(content, 18)

        <<~HTML
                    <div id="leadership" class="section">
                        <div class="card">
                            <h2><span class="section-icon">👥</span>Leadership Team</h2>
          #{indented_content}
                        </div>
                    </div>
        HTML
      end

      def build_numbers_section(profile)
        content = get_section_html(profile, "key_numbers")
        indented_content = indent_html(content, 18)

        <<~HTML
                    <div id="numbers" class="section">
                        <div class="card">
                            <h2><span class="section-icon">📊</span>Key Numbers</h2>
          #{indented_content}
                        </div>
                    </div>
        HTML
      end

      def build_locations_section(profile)
        content = get_section_html(profile, "office_locations")
        indented_content = indent_html(content, 18)

        <<~HTML
                    <div id="locations" class="section">
                        <div class="card">
                            <h2><span class="section-icon">📍</span>Office Locations</h2>
          #{indented_content}
                        </div>
                    </div>
        HTML
      end

      def build_perks_section(profile)
        content = get_section_html(profile, "perks_and_benefits")
        indented_content = indent_html(content, 18)

        <<~HTML
                    <div id="perks" class="section">
                        <div class="card">
                            <h2><span class="section-icon">🎁</span>Perks & Benefits</h2>
          #{indented_content}
                        </div>
                    </div>
        HTML
      end

      def build_remote_section(profile)
        content = get_section_html(profile, "remote_policy")
        indented_content = indent_html(content, 18)

        <<~HTML
                    <div id="remote" class="section">
                        <div class="card">
                            <h2><span class="section-icon">🏠</span>Remote Work Policy</h2>
          #{indented_content}
                        </div>
                    </div>
        HTML
      end

      def build_funding_section(profile)
        content = get_section_html(profile, "funding_parser")
        indented_content = indent_html(content, 18)

        <<~HTML
                    <div id="funding" class="section">
                        <div class="card">
                            <h2><span class="section-icon">💰</span>Funding Status</h2>
          #{indented_content}
                        </div>
                    </div>
        HTML
      end

      def get_section_html(profile, section_file_name)
        # Find section by prompt_file since that's what we use internally
        section = profile.sections.find { |s| s.prompt_file == section_file_name }

        # Also try finding by name as fallback
        section ||= profile.find_section(section_file_name)

        return "<p>Section not available</p>" unless section

        # Strip markdown code fences if present (AI sometimes wraps HTML in ```html blocks)
        content = strip_code_fences(section.content)

        is_html = looks_like_html?(content)

        if is_html
          # Prompts now return HTML directly, return content as-is
          content
        else
          # Fall back to markdown formatter for old-style content
          @content_formatter.format(content)
        end
      end

      def strip_code_fences(content)
        return content if content.nil? || content.strip.empty?

        # Remove markdown code fences like ```html ... ``` or ``` ... ```
        stripped = content.strip

        # Check for ```html or ``` at start and ``` at end
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
        # Check if it starts with an HTML tag (after stripping whitespace)
        # Also check for common HTML patterns like <div, <h3, <p, <ul, etc.
        stripped.start_with?("<") && stripped.include?(">")
      end

      def indent_html(html, spaces)
        return "" if html.nil? || html.empty?

        indent = " " * spaces
        html.lines.map { |line| line.strip.empty? ? line : "#{indent}#{line}" }.join
      end

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
