# frozen_string_literal: true

module ProfileGenerator
  module Services
    # Service for building prompts with company context
    # Follows Strategy pattern and SRP - only responsible for prompt construction
    class PromptBuilder
      COMPANY_PLACEHOLDERS = [
        "[Company Name]",
        "[Company]"
      ].freeze

      ANALYSIS_FIELDS = %i[
        tone_of_voice
        brand_personality
        core_values
        key_themes
        messaging_style
        target_audience
        language_patterns
        industry_focus
      ].freeze

      def initialize(company)
        @company = company
      end

      # Build system prompt by replacing company placeholders in template
      # @param template [String] The prompt template with placeholders
      # @return [String] The system prompt with Company Name substituted
      def build_system_prompt(template)
        replace_company_placeholders(template)
      end

      # Build user prompt with company context
      # @return [String] The user prompt with company information
      def build_user_prompt
        [
          company_context,
          file_analysis_context,
          language_instruction
        ].compact.join("\n")
      end

      # Build user prompt for file analysis (no company context)
      # File analysis should be objective without company bias
      # @return [String] The user prompt without company information
      def build_file_analysis_user_prompt
        language_instruction
      end

      private

      def replace_company_placeholders(template)
        COMPANY_PLACEHOLDERS.reduce(template) do |text, placeholder|
          text.gsub(placeholder, @company.name)
        end
      end

      def company_context
        parts = [
          "Company Name: #{@company.name}",
          website_context
        ]
        parts.compact.join("\n")
      end

      def website_context
        "Company Website: #{@company.website}" if @company.website
      end

      def file_analysis_context
        return nil unless file_analysis?

        build_analysis_context
      end

      def language_instruction
        lang_code = @company.output_language if @company.respond_to?(:output_language)
        return nil if lang_code.nil? || lang_code.to_s.strip.empty?

        label = @company.respond_to?(:output_language_label) ? @company.output_language_label : lang_code
        "Respond in #{label} (#{lang_code}) unless otherwise instructed. Keep JSON output structure unchanged."
      end

      def file_analysis?
        analysis = ProfileGenerator.configuration.file_analysis
        analysis.is_a?(Hash) && !analysis.empty?
      end

      def file_analysis
        @file_analysis ||= ProfileGenerator.configuration.file_analysis || {}
      end

      def build_analysis_context
        [
          "## Reference Files Analysis:\n",
          "Use these insights from uploaded reference files to guide your response:",
          *formatted_analysis_fields
        ].compact.join("\n")
      end

      def formatted_analysis_fields
        ANALYSIS_FIELDS.filter_map { |field| format_analysis_field(field) }
      end

      def format_analysis_field(field)
        value = file_analysis[field.to_s]
        return nil if value.nil? || (value.respond_to?(:empty?) && value.empty?)

        formatted_value = format_field_value(value)
        humanized_field = humanize_field_name(field.to_s)
        "\n**#{humanized_field}:** #{formatted_value}"
      end

      def humanize_field_name(field)
        field.tr("_", " ").split.map(&:capitalize).join(" ")
      end

      def format_field_value(value)
        if value.is_a?(Array)
          value.join(", ")
        else
          value.to_s
        end
      end
    end
  end
end
