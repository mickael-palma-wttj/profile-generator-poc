# frozen_string_literal: true

require "logger"
require "concurrent"

module ProfileGenerator
  module Interactors
    # Interactor for generating a complete company profile
    # Orchestrates the profile generation process
    # Follows SRP and Command pattern
    class GenerateProfile
      def initialize(
        anthropic_client: nil,
        prompt_loader: nil,
        logger: nil,
        max_threads: 5,
        max_retries: 3,
        progress_callback: nil
      )
        @anthropic_client = anthropic_client || Services::AnthropicClient.new(max_retries: max_retries)
        @prompt_loader = prompt_loader || Services::PromptLoader.new
        @logger = logger || default_logger
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
        log_profile_generation_start(company, sections_to_generate)

        start_time = Time.now
        sections = if parallel
                     generate_sections_parallel(company, sections_to_generate)
                   else
                     generate_sections_sequential(company, sections_to_generate)
                   end
        duration = Time.now - start_time

        profile = Models::Profile.new(
          company: company,
          sections: sections
        )

        log_profile_generation_complete(sections.count, sections_to_generate.count, duration)

        Result.success(
          profile,
          sections_generated: sections.count,
          sections_requested: sections_to_generate.count,
          duration_seconds: duration.round(2)
        )
      rescue StandardError => e
        @logger.error("Profile generation failed: #{e.message}")
        Result.failure(
          e.message,
          error_class: e.class.name,
          backtrace: e.backtrace&.first(5)
        )
      end

      # Generate a single section for a company with retry logic
      # @param company [Models::Company] The company
      # @param section_name [String] Name of the section/prompt to use
      # @param retry_attempt [Integer] Current retry attempt (for internal use)
      # @return [Result] Result object with section or error
      def generate_section(company:, section_name:, retry_attempt: 0)
        validate_company!(company)

        unless prompt_loader.exist?(section_name)
          @logger.warn("Prompt file not found: #{section_name}")
          return Result.failure("Prompt file not found: #{section_name}")
        end

        log_section_start(section_name, company, retry_attempt)
        start_time = Time.now

        system_prompt = build_system_prompt(prompt_loader.load(section_name), company)
        user_prompt = build_user_prompt(company)

        content = anthropic_client.generate(
          prompt: user_prompt,
          system_prompt: system_prompt,
          context: {
            company: company.name,
            section: section_name,
            retry_attempt: retry_attempt
          }
        )

        duration = Time.now - start_time
        log_section_complete(section_name, duration, content.length, retry_attempt)

        section = Models::ProfileSection.new(
          name: humanize_section_name(section_name),
          content: content,
          prompt_file: section_name
        )

        Result.success(section)
      rescue StandardError => e
        handle_section_error(e, company, section_name, retry_attempt)
      end

      private

      attr_reader :anthropic_client, :prompt_loader

      def validate_company!(company)
        return if company.is_a?(Models::Company)

        raise ArgumentError, "company must be a Company object"
      end

      def determine_sections(section_names)
        return prompt_loader.available_prompts if section_names.nil? || section_names.empty?

        section_names
      end

      # Sequential generation (original implementation)
      def generate_sections_sequential(company, section_names)
        @logger.info("Generating sections sequentially")
        section_names.filter_map do |section_name|
          result = generate_section(company: company, section_name: section_name)

          if result.success?
            result.value
          else
            @logger.warn("Failed to generate section '#{section_name}': #{result.error}")
            nil
          end
        end
      end

      # Parallel generation using thread pool
      def generate_sections_parallel(company, section_names)
        @logger.info("Generating #{section_names.count} sections in parallel (max #{@max_threads} threads)")

        # Notify start of each section
        section_names.each do |section_name|
          notify_progress(section_name, :pending, nil)
        end

        pool = Concurrent::FixedThreadPool.new(@max_threads)
        futures = section_names.map do |section_name|
          Concurrent::Future.execute(executor: pool) do
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
        end

        # Wait for all futures to complete and collect results
        sections = futures.filter_map(&:value)
        pool.shutdown
        pool.wait_for_termination

        sections
      end

      def log_profile_generation_start(company, section_names)
        @logger.info("=" * 60)
        @logger.info("Starting profile generation for: #{company.name}")
        @logger.info("Website: #{company.website}")
        @logger.info("Sections to generate: #{section_names.join(', ')}")
        @logger.info("=" * 60)
      end

      def log_profile_generation_complete(generated, requested, duration)
        @logger.info("=" * 60)
        @logger.info("Profile generation complete!")
        @logger.info("Sections: #{generated}/#{requested} successful")
        @logger.info("Total duration: #{duration.round(2)}s")
        @logger.info("Average per section: #{(duration / requested).round(2)}s")
        @logger.info("=" * 60)
      end

      def default_logger
        logger = Logger.new($stdout)
        logger.level = ENV["LOG_LEVEL"]&.upcase&.to_sym || Logger::INFO
        logger.formatter = proc do |severity, datetime, _progname, msg|
          "[#{datetime.strftime('%Y-%m-%d %H:%M:%S')}] #{severity}: #{msg}\n"
        end
        logger
      end

      def log_section_start(section_name, company, retry_attempt)
        if retry_attempt.positive?
          @logger.warn("Retrying section: #{section_name} (attempt #{retry_attempt + 1}/#{@max_retries + 1})")
        else
          @logger.info("Starting generation for section: #{section_name} (company: #{company.name})")
        end
      end

      def log_section_complete(section_name, duration, content_length, retry_attempt)
        retry_info = retry_attempt.positive? ? " (after #{retry_attempt} retries)" : ""
        message = "Completed section: #{section_name} in #{duration.round(2)}s " \
                  "(#{content_length} chars)#{retry_info}"
        @logger.info(message)
      end

      def handle_section_error(error, company, section_name, retry_attempt)
        if retry_attempt < @max_retries && retryable_error?(error)
          @logger.warn("Retryable error for section '#{section_name}': #{error.message}")
          sleep_with_backoff(retry_attempt)
          return generate_section(
            company: company,
            section_name: section_name,
            retry_attempt: retry_attempt + 1
          )
        end

        message = "Failed to generate section '#{section_name}' after " \
                  "#{retry_attempt + 1} attempts: #{error.message}"
        @logger.error(message)
        Result.failure(
          error.message,
          section_name: section_name,
          error_class: error.class.name,
          retry_attempts: retry_attempt
        )
      end

      def retryable_error?(error)
        error.is_a?(Services::AnthropicClient::APIError) ||
          error.message.downcase.include?("timeout") ||
          error.message.downcase.include?("connection") ||
          error.message.downcase.include?("rate limit")
      end

      def sleep_with_backoff(attempt)
        delay = [1.0 * (2**attempt), 30.0].min # Cap at 30 seconds
        @logger.debug("Waiting #{delay.round(2)}s before retry...")
        sleep(delay)
      end

      def build_system_prompt(template, company)
        # System prompt: The template with placeholders replaced
        template
          .gsub("[COMPANY NAME]", company.name)
          .gsub("[Company Name]", company.name)
          .gsub("[COMPANY_NAME]", company.name)
          .gsub("[Company]", company.name)
          .gsub("[company]", company.name)
      end

      def build_user_prompt(company)
        # User prompt: Simple context with company information
        context = "Company Name: #{company.name}"
        context += "\nCompany Website: #{company.website}" if company.website
        context
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
