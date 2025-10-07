# frozen_string_literal: true

module ProfileGenerator
  module Services
    # Handles async profile generation in background thread
    # Follows SRP - only responsible for orchestrating async generation
    class AsyncProfileGenerator
      def initialize(session_manager:, formatter: nil)
        @session_manager = session_manager
        @formatter = formatter || ContentFormatter.new
      end

      def generate(session_id, company)
        Thread.new do
          execute_generation(session_id, company)
        rescue StandardError => e
          @session_manager.fail_session(session_id, e.message)
        end
      end

      private

      attr_reader :session_manager, :formatter

      def execute_generation(session_id, company)
        progress_callback = build_progress_callback(session_id)
        generator = Interactors::GenerateProfile.new(progress_callback: progress_callback)
        result = generator.call(company: company)

        session_manager.complete_session(session_id, result)
      end

      def build_progress_callback(session_id)
        lambda do |data|
          section_data = format_section_data(data)
          session_manager.update_section(session_id, data[:section_name], section_data)
        end
      end

      def format_section_data(data)
        formatted_section = data[:section]

        if data[:status] == :completed && data[:section]
          formatted_content = formatter.format(data[:section].content)
          formatted_section = Models::ProfileSection.new(
            name: data[:section].name,
            content: formatted_content,
            prompt_file: data[:section].prompt_file
          )
        end

        {
          status: data[:status].to_s,
          section: formatted_section,
          error: data[:error],
          timestamp: data[:timestamp]
        }
      end
    end
  end
end
