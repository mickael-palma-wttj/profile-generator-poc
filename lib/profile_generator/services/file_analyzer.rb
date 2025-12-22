# frozen_string_literal: true

require "json"

module ProfileGenerator
  module Services
    # Analyzes uploaded files to extract brand insights
    # Delegates logging to a separate concern for testability
    class FileAnalyzer
      def initialize(client, prompt_manager: nil, logger: nil, company_name: nil)
        @client = client
        @prompt_manager = prompt_manager
        @company_name = company_name || "unknown"
        @logger = logger || FileAnalyzerLogger.new
        @document_builder = DocumentBlockBuilder.new(logger: @logger)
        @response_parser = AnalysisResponseParser.new(logger: @logger)
        @file_extractor = FileDataExtractor.new(logger: @logger)
      end

      def analyze_files(files)
        return {} if files.nil? || files.empty?

        file_sources = prepare_file_sources(files)
        return {} if file_sources.empty?

        send_analysis_request(file_sources)
      rescue StandardError => e
        @logger.error("analyze_files", e)
        @logger.error("analyze_files cause", e.cause) if e.cause
        {}
      end

      private

      def prepare_file_sources(files)
        @logger.start_file_processing(files.length)
        file_sources = files.each_with_object([]) do |file, sources|
          source = build_file_source(file)
          sources << source if source
        end
        @logger.complete_file_processing(file_sources.length, files.length)
        file_sources
      end

      def build_file_source(file)
        return nil if file.nil?

        file_data = @file_extractor.extract(file)
        return nil unless file_data

        @document_builder.build(file_data)
      end

      def send_analysis_request(file_sources)
        prompt_content = build_analysis_prompt(file_sources)
        response = call_llm_api(prompt_content)
        @response_parser.parse(response)
      end

      def call_llm_api(prompt_content)
        @logger.start_api_call(prompt_content)

        start_time = Time.now
        response = @client.generate_file_analysis(
          prompt_content: prompt_content,
          company_name: @company_name
        )

        elapsed = Time.now - start_time
        @logger.complete_api_call(elapsed)
        response
      end

      def build_analysis_prompt(file_sources)
        template = load_prompt_template
        # Remove any company name placeholders - file analysis should be objective
        clean_template = remove_company_placeholders(template)
        [
          { type: :text, text: clean_template },
          *file_sources
        ]
      end

      def load_prompt_template
        if @prompt_manager
          prompt = @prompt_manager.load("file_analysis")
          prompt.respond_to?(:content) ? prompt.content : prompt
        else
          load_prompt_from_file
        end
      end

      def remove_company_placeholders(template)
        # Remove [Company Name] and [Company] placeholders
        template
          .gsub(/\[Company Name\]\s*/, "")
          .gsub(/\[Company\]\s*/, "")
      end

      def load_prompt_from_file
        prompt_path = File.join(__dir__, "../../..", "prompts", "file_analysis.prompt.md")
        File.read(prompt_path, encoding: "UTF-8")
      end
    end
  end
end
