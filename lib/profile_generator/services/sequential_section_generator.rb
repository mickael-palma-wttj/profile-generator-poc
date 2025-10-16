# frozen_string_literal: true

module ProfileGenerator
  module Services
    # Orchestrates sequential generation of sections using a SectionGenerator instance.
    class SequentialSectionGenerator
      def initialize(section_generator:, progress_callback: nil, logger: nil)
        @section_generator = section_generator
        @progress_callback = progress_callback
        @logger = logger
      end

      def call(company:, section_names:)
        @logger&.info("Generating #{section_names.size} sections sequentially")

        section_names.each { |name| notify(name, :pending) }

        section_names.filter_map { |name| generate_one(company, name) }
      end

      def generate_one(company, name)
        notify(name, :in_progress)

        section = @section_generator.call(company: company, section_name: name)
        notify(name, :completed, section)
        section
      rescue StandardError => e
        notify(name, :failed, nil, error: e)
        nil
      end

      private

      def notify(name, status, section = nil, error: nil)
        return unless @progress_callback

        @progress_callback.call(
          section_name: name,
          status: status,
          section: section,
          error: error,
          timestamp: Time.now
        )
      end
    end
  end
end
