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

      def initialize(company)
        @company = company
      end

      # Build system prompt by replacing company placeholders in template
      # @param template [String] The prompt template with placeholders
      # @return [String] The system prompt with Company Name substituted
      def build_system_prompt(template)
        COMPANY_PLACEHOLDERS.reduce(template) do |text, placeholder|
          text.gsub(placeholder, @company.name)
        end
      end

      # Build user prompt with company context
      # @return [String] The user prompt with company information
      def build_user_prompt
        context_parts.compact.join("\n")
      end

      private

      def context_parts
        [
          "Company Name: #{@company.name}",
          website_part
        ]
      end

      def website_part
        return nil unless @company.website

        "Company Website: #{@company.website}"
      end
    end
  end
end
