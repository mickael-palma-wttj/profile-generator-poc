# frozen_string_literal: true

module ProfileGenerator
  module Services
    # Responsible for generating a single profile section using prompt builder and the AI client
    class SectionGenerator
      def initialize(client_factory:, prompt_loader:, logger: nil, retryer: nil)
        @client_factory = client_factory
        @prompt_loader = prompt_loader
        @logger = logger
        @retryer = retryer
        @section_name = nil
      end

      # Returns a Models::ProfileSection
      def call(company:, section_name:)
        @section_name = section_name
        prompt_object = @prompt_loader.load(section_name)
        client = @client_factory.client_for(prompt_object.config)

        system_prompt, user_prompt = build_prompts(company, prompt_object.content)

        content = fetch_content(client, user_prompt, system_prompt, company, section_name)

        build_section(section_name, content)
      end

      def fetch_content(client, user_prompt, system_prompt, company, section_name)
        return @retryer.with_retries { call_llm(client, user_prompt, system_prompt, company, section_name) } if @retryer

        call_llm(client, user_prompt, system_prompt, company, section_name)
      end

      def build_section(section_name, content)
        ProfileGenerator::Models::ProfileSection.new(
          name: humanize_section_name(section_name),
          content: content,
          prompt_file: section_name
        )
      end

      private

      def humanize_section_name(section_name)
        section_name.tr("_", " ").split.map(&:capitalize).join(" ")
      end

      def build_prompts(company, prompt_template)
        builder = PromptBuilder.new(company)

        # File analysis should not include company context - analyze objectively
        if @section_name == "file_analysis"
          # For file analysis, use the prompt template as-is without company substitution
          system_prompt = prompt_template
          user_prompt = builder.build_file_analysis_user_prompt
        else
          system_prompt = builder.build_system_prompt(prompt_template)
          user_prompt = builder.build_user_prompt
        end

        [system_prompt, user_prompt]
      end

      def call_llm(client, user_prompt, system_prompt, company, section_name)
        client.generate(
          prompt: user_prompt,
          system_prompt: system_prompt,
          context: { company: company.name, section: section_name }
        )
      end
    end
  end
end
