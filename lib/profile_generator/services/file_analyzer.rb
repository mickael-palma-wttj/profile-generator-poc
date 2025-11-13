# frozen_string_literal: true

require "json"
require "base64"

module ProfileGenerator
  module Services
    # Analyzes uploaded files to extract brand insights
    # Delegates logging to a separate concern for testability
    class FileAnalyzer
      def initialize(anthropic_client, prompt_manager: nil, logger: nil, company_name: nil)
        @client = anthropic_client
        @prompt_manager = prompt_manager
        @company_name = company_name || "unknown"
        @logger = logger || DefaultLogger.new
      end

      def analyze_files(files)
        return {} if files.nil? || files.empty?

        file_sources = prepare_file_sources(files)
        return {} if file_sources.empty?

        send_analysis_request(file_sources)
      rescue StandardError => e
        @logger.error("analyze_files", e)
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

        file_data = extract_file_data(file)
        return nil unless file_data

        build_document_block(file_data)
      end

      def extract_file_data(file)
        case file
        when Hash
          extract_from_hash(file)
        else
          nil
        end
      end

      def extract_from_hash(file)
        if file[:content]
          cached_file_data(file)
        elsif file[:tempfile]
          tempfile_data(file)
        end
      end

      def cached_file_data(file)
        content = file[:content]
        return nil if content.nil? || content.empty?

        {
          filename: file[:filename],
          content: content,
          source: :cache
        }
      end

      def tempfile_data(file)
        tempfile = file[:tempfile]
        filename = file[:filename] || "file"

        content = read_tempfile(tempfile)
        return nil unless content

        {
          filename: filename,
          content: content,
          source: :tempfile
        }
      end

      def read_tempfile(tempfile)
        tempfile.rewind if tempfile.respond_to?(:rewind)
        tempfile.read
      rescue StandardError => e
        @logger.warn_tempfile_read(e.message)
        nil
      end

      def build_document_block(file_data)
        @logger.log_file_processing(file_data)

        media_type = get_media_type(file_data[:filename])
        encoded_content = Base64.strict_encode64(file_data[:content])

        {
          type: :document,
          source: {
            type: :base64,
            media_type: media_type.to_sym,
            data: encoded_content
          }
        }
      end

      def send_analysis_request(file_sources)
        prompt_content = build_analysis_prompt(file_sources)
        response = call_anthropic_api(prompt_content)
        parse_analysis(response)
      end

      def call_anthropic_api(prompt_content)
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

      def get_media_type(filename)
        extension = File.extname(filename).downcase
        MEDIA_TYPES[extension] || "application/octet-stream"
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
          @prompt_manager.load("file_analysis")
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

      def parse_analysis(response)
        content = extract_response_content(response)
        json_data = extract_json_from_content(content)

        @logger.log_analysis_complete(json_data)
        json_data
      rescue StandardError => e
        @logger.error("parse_analysis", e)
        {}
      end

      def extract_response_content(response)
        case response
        when Hash
          response.dig("content", 0, "text") || ""
        else
          response.respond_to?(:content) ? response.content.first&.text || "" : response.to_s
        end
      end

      def extract_json_from_content(content)
        json_match = content.match(/\{[\s\S]*\}/)
        return {} unless json_match

        JSON.parse(json_match[0])
      end

      MEDIA_TYPES = {
        ".pdf" => "application/pdf",
        ".txt" => "text/plain",
        ".docx" => "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
        ".doc" => "application/msword",
        ".md" => "text/markdown"
      }.freeze

      # Default logger - can be injected for testing
      class DefaultLogger
        PREFIX = "[FileAnalyzer]"

        def start_file_processing(count)
          puts "\n#{PREFIX} =========================================="
          puts "#{PREFIX} 🔍 Starting file analysis for #{count} file(s)"
          puts "#{PREFIX} =========================================="
        end

        def complete_file_processing(prepared, total)
          puts "#{PREFIX} ✓ Prepared #{prepared}/#{total} file(s) for analysis"
        end

        def log_file_processing(file_data)
          puts "#{PREFIX} 📄 Processing: #{file_data[:filename]} (#{file_data[:content].bytesize} bytes, source: #{file_data[:source]})"
        end

        def warn_tempfile_read(error_msg)
          puts "#{PREFIX} ⚠️  Failed to read from Tempfile: #{error_msg}"
        end

        def start_api_call(content)
          puts "#{PREFIX} ⏳ Sending request to Anthropic API with #{content.length} content block(s)..."
        end

        def complete_api_call(elapsed)
          puts "#{PREFIX} ✓ API response received in #{elapsed.round(2)}s"
        end

        def log_analysis_complete(data)
          puts "#{PREFIX} =========================================="
          puts "#{PREFIX} ✅ Analysis complete!"
          puts "#{PREFIX} Extracted keys: #{data.keys.join(', ')}"
          puts "#{PREFIX} =========================================="
        end

        def error(method, exception)
          puts "#{PREFIX} ❌ Error in #{method}: #{exception.class} - #{exception.message}"
          puts exception.backtrace.first(3).join("\n")
        end
      end
    end
  end
end
