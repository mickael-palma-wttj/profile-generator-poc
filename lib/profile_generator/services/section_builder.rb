# frozen_string_literal: true

module ProfileGenerator
  module Services
    # Builds the HTML for all profile sections. Extracted from HtmlGenerator to
    # reduce class size and complexity.
    class SectionBuilder
      include SectionHelpers

      def initialize(content_formatter:)
        @content_formatter = content_formatter
      end

      def build_all_sections(profile)
        [build_story_section(profile), build_values_section(profile), build_description_section(profile),
         build_leadership_section(profile), build_numbers_section(profile), build_locations_section(profile),
         build_perks_section(profile), build_remote_section(profile), build_funding_section(profile)].join("\n")
      end

      private

      def build_story_section(profile)
        content = get_section_html(profile, "their_story")
        indented_content = indent_html(content, 18)

        wrap_section_html("story", "Their Story", "📖", indented_content, active: true, extra_card_class: "story-card")
      end

      def build_values_section(profile)
        content = get_section_html(profile, "company_values")
        indented_content = indent_html(content, 22)

        inner = "<div class=\"values-grid\">\n#{indented_content}\n                            </div>"
        wrap_section_html("values", "Company Values", "💎", inner)
      end

      def build_description_section(profile)
        content = get_section_html(profile, "company_description")
        indented_content = indent_html(content, 18)

        wrap_section_html("description", "Company Overview", "🏢", indented_content)
      end

      def build_leadership_section(profile)
        content = get_section_html(profile, "leadership")
        indented_content = indent_html(content, 18)

        wrap_section_html("leadership", "Leadership Team", "👥", indented_content)
      end

      def build_numbers_section(profile)
        content = get_section_html(profile, "key_numbers")
        indented_content = indent_html(content, 18)

        wrap_section_html("numbers", "Key Numbers", "📊", indented_content)
      end

      def build_locations_section(profile)
        content = get_section_html(profile, "office_locations")
        indented_content = indent_html(content, 18)

        wrap_section_html("locations", "Office Locations", "📍", indented_content)
      end

      def build_perks_section(profile)
        content = get_section_html(profile, "perks_and_benefits")
        indented_content = indent_html(content, 18)

        wrap_section_html("perks", "Perks & Benefits", "🎁", indented_content)
      end

      def build_remote_section(profile)
        content = get_section_html(profile, "remote_policy")
        indented_content = indent_html(content, 18)

        wrap_section_html("remote", "Remote Work Policy", "🏠", indented_content)
      end

      def build_funding_section(profile)
        content = get_section_html(profile, "funding_parser")
        indented_content = indent_html(content, 18)

        wrap_section_html("funding", "Funding Status", "💰", indented_content)
      end

      def get_section_html(profile, section_file_name)
        section = profile.sections.find { |s| s.prompt_file == section_file_name }
        section ||= profile.find_section(section_file_name)
        return "<p>Section not available</p>" unless section

        content = strip_code_fences(section.content)
        looks_like_html?(content) ? content : @content_formatter.format(content)
      end

      # HTML helper methods extracted to SectionHelpers
    end
  end
end
