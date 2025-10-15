# frozen_string_literal: true

require "concurrent"

module ProfileGenerator
  module Interactors
    # Interactor for generating a complete company profile
    # Orchestrates the profile generation process
    # Follows SRP and Command pattern
    # Refactored to delegate to specialized services
    class GenerateProfile
      def initialize(
        anthropic_client: nil,
        prompt_loader: nil,
        prompt_manager: nil,
        generation_logger: nil,
        max_threads: 5,
        max_retries: 3,
        progress_callback: nil
      )
        @anthropic_client = anthropic_client || build_anthropic_client(max_retries)
        # Support both legacy prompt_loader and new prompt_manager
        # prompt_manager takes precedence for flexibility
        @prompt_loader = prompt_manager || prompt_loader || build_default_prompt_loader
        @generation_logger = generation_logger || Services::GenerationLogger.new
        @max_threads = max_threads
        @max_retries = max_retries
        @progress_callback = progress_callback
      end

      # Generate a complete profile for a company
      # @param company [Models::Company] The company to generate a profile for
      # @param section_names [Array<String>, nil] Optional list of sections to generate
      # @param parallel [Boolean] Whether to generate sections in parallel (default: true)
      # @return [Result] Result object with profile or error
      def call(company:, section_names: nil, parallel: true)
        validate_company!(company)

        sections_to_generate = determine_sections(section_names)
        @generation_logger.generation_started(company, sections_to_generate)

        start_time = Time.now
        sections = execute_generation(company, sections_to_generate, parallel)
        duration = Time.now - start_time

        profile = build_profile(company, sections)
        log_completion(sections, sections_to_generate, duration)

        build_success_result(profile, sections, sections_to_generate, duration)
      rescue StandardError => e
        handle_error(e)
      end

      # Generate a single section for a company with retry logic
      # @param company [Models::Company] The company
      # @param section_name [String] Name of the section/prompt to use
      # @param retry_attempt [Integer] Current retry attempt (for internal use)
      # @return [Result] Result object with section or error
      def generate_section(company:, section_name:, retry_attempt: 0)
        validate_company!(company)
        validate_section_exists!(section_name)

        @generation_logger.section_started(section_name, company, retry_attempt)
        start_time = Time.now

        prompt_builder = Services::PromptBuilder.new(company)
        section_content = generate_section_content(
          prompt_builder,
          section_name,
          company
        )

        duration = Time.now - start_time
        @generation_logger.section_completed(
          section_name,
          duration,
          section_content.length,
          retry_count: retry_attempt,
          company: company
        )

        section = Models::ProfileSection.new(
          name: humanize_section_name(section_name),
          content: section_content,
          prompt_file: section_name
        )

        Result.success(section)
      rescue StandardError => e
        handle_section_error(e, company, section_name, retry_attempt)
      end

      private

      attr_reader :anthropic_client, :prompt_loader, :generation_logger

      def build_anthropic_client(max_retries)
        Services::AnthropicClient.new(max_retries: max_retries)
      end

      def build_default_prompt_loader
        # Default to Langfuse if configured, otherwise use file-based
        prompt_source = ENV.fetch("PROMPT_SOURCE", "langfuse").to_sym
        Services::PromptManager.new(source: prompt_source)
      rescue Services::LangfuseClient::ConfigurationError
        # Fall back to file-based if Langfuse not configured
        Services::PromptManager.new(source: :file)
      end

      def validate_company!(company)
        return if company.is_a?(Models::Company)

        raise ArgumentError, "company must be a Company object"
      end

      def validate_section_exists!(section_name)
        return if prompt_loader.exist?(section_name)

        @generation_logger.warn("Prompt file not found: #{section_name}")
        raise ArgumentError, "Prompt file not found: #{section_name}"
      end

      def determine_sections(section_names)
        if section_names.nil? || section_names.empty?
          # Return all available prompts based on source
          # For Langfuse, use the local file names for consistency
          return Services::PromptNameMapper.all_file_names
        end

        section_names
      end

      def execute_generation(company, section_names, parallel)
        if parallel
          generate_sections_parallel(company, section_names)
        else
          generate_sections_sequential(company, section_names)
        end
      end

      # Sequential generation
      def generate_sections_sequential(company, section_names)
        @generation_logger.info("Generating sections sequentially")
        section_names.filter_map do |section_name|
          result = generate_section(company: company, section_name: section_name)
          handle_section_result(result, section_name)
        end
      end

      def handle_section_result(result, section_name)
        return result.value if result.success?

        @generation_logger.warn("Failed: '#{section_name}': #{result.error}")
        nil
      end

      # Parallel generation using thread pool
      def generate_sections_parallel(company, section_names)
        message = "Generating #{section_names.count} sections in parallel " \
                  "(max #{@max_threads} threads)"
        @generation_logger.info(message)

        notify_all_pending(section_names)

        pool = Concurrent::FixedThreadPool.new(@max_threads)
        futures = create_section_futures(pool, company, section_names)

        sections = collect_future_results(futures)
        shutdown_pool(pool)

        sections
      end

      def notify_all_pending(section_names)
        section_names.each { |name| notify_progress(name, :pending, nil) }
      end

      def create_section_futures(pool, company, section_names)
        section_names.map do |section_name|
          Concurrent::Future.execute(executor: pool) do
            execute_section_with_progress(company, section_name)
          end
        end
      end

      def execute_section_with_progress(company, section_name)
        notify_progress(section_name, :in_progress, nil)
        result = generate_section(company: company, section_name: section_name)

        if result.success?
          notify_progress(section_name, :completed, result.value)
          result.value
        else
          notify_progress(section_name, :failed, nil, error: result.error)
          nil
        end
      end

      def collect_future_results(futures)
        futures.filter_map(&:value)
      end

      def shutdown_pool(pool)
        pool.shutdown
        pool.wait_for_termination
      end

      def build_profile(company, sections)
        Models::Profile.new(company: company, sections: sections)
      end

      def log_completion(sections, sections_to_generate, duration)
        @generation_logger.generation_completed(
          generated: sections.count,
          requested: sections_to_generate.count,
          duration: duration,
          average: duration / sections_to_generate.count
        )
      end

      def build_success_result(profile, sections, sections_to_generate, duration)
        Result.success(
          profile,
          sections_generated: sections.count,
          sections_requested: sections_to_generate.count,
          duration_seconds: duration.round(2)
        )
      end

      def handle_error(error)
        @generation_logger.error("Profile generation failed: #{error.message}")
        Result.failure(
          error.message,
          error_class: error.class.name,
          backtrace: error.backtrace&.first(5)
        )
      end

      def generate_section_content(prompt_builder, section_name, company)
        system_prompt = prompt_builder.build_system_prompt(
          prompt_loader.load(section_name)
        )
        user_prompt = prompt_builder.build_user_prompt

        anthropic_client.generate(
          prompt: user_prompt,
          system_prompt: system_prompt,
          context: {
            company: company.name,
            section: section_name
          }
        )
      end

      def handle_section_error(error, company, section_name, retry_attempt)
        if should_retry?(error, retry_attempt)
          perform_retry(error, company, section_name, retry_attempt)
        else
          build_failure_result(error, section_name, retry_attempt)
        end
      end

      def should_retry?(error, retry_attempt)
        retry_attempt < @max_retries && retryable_error?(error)
      end

      def perform_retry(error, company, section_name, retry_attempt)
        @generation_logger.warn("Retryable error: '#{section_name}': #{error.message}")
        sleep_with_backoff(retry_attempt)
        generate_section(
          company: company,
          section_name: section_name,
          retry_attempt: retry_attempt + 1
        )
      end

      def build_failure_result(error, section_name, retry_attempt)
        @generation_logger.section_failed(
          section_name,
          error.message,
          retry_attempt + 1
        )
        Result.failure(
          error.message,
          section_name: section_name,
          error_class: error.class.name,
          retry_attempts: retry_attempt
        )
      end

      def retryable_error?(error)
        return true if error.is_a?(Services::AnthropicClient::APIError)

        error_message = error.message.downcase
        retryable_patterns.any? { |pattern| error_message.include?(pattern) }
      end

      def retryable_patterns
        ["timeout", "connection", "rate limit", "503", "502", "500", "504", "529", "overloaded"]
      end

      def sleep_with_backoff(attempt)
        delay = [1.0 * (2**attempt), 30.0].min
        @generation_logger.debug("Waiting #{delay.round(2)}s before retry...")
        sleep(delay)
      end

      def humanize_section_name(section_name)
        # Convert file name to human-readable title
        # e.g., "company_values" => "Company Values"
        section_name
          .tr("_", " ")
          .split
          .map(&:capitalize)
          .join(" ")
      end

      def notify_progress(section_name, status, section, error: nil)
        return unless @progress_callback

        @progress_callback.call(
          section_name: section_name,
          status: status,
          section: section,
          error: error,
          timestamp: Time.now
        )
      end
    end
  end
end
