# frozen_string_literal: true

require "concurrent"

module ProfileGenerator
  module Services
    # Orchestrates parallel generation of sections using a SectionGenerator instance.
    class ParallelSectionGenerator
      def initialize(section_generator:, max_threads:, progress_callback: nil, logger: nil, future_builder: nil)
        @section_generator = section_generator
        @max_threads = max_threads
        @progress_callback = progress_callback
        @logger = logger
        # future_builder is a callable that takes (pool) and a block and returns an object
        # responding to `value`. Default uses Concurrent::Future.execute.
        @future_builder = future_builder || ->(pool, &block) { Concurrent::Future.execute(executor: pool, &block) }
      end

      def call(company:, section_names:)
        @logger&.info("Generating #{section_names.size} sections in parallel (max #{@max_threads} threads)")

        section_names.each { |name| notify(name, :pending) }

        pool = Concurrent::FixedThreadPool.new(@max_threads)
        futures = section_names.map { |name| future_for_name(pool, company, name) }

        results = futures.filter_map(&:value)
        pool.shutdown
        pool.wait_for_termination
        results
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

      def future_for_name(pool, company, name)
        @future_builder.call(pool) do
          notify(name, :in_progress)
          generate_section_with_notify(company, name)
        end
      end

      def generate_section_with_notify(company, name)
        section = @section_generator.call(company: company, section_name: name)
        notify(name, :completed, section)
        section
      rescue StandardError => e
        notify(name, :failed, nil, error: e)
        nil
      end
    end
  end
end
