# frozen_string_literal: true

module ProfileGenerator
  module Services
    # Default logger for FileAnalyzer - can be injected for testing
    class FileAnalyzerLogger
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
        filename = file_data[:filename]
        bytesize = file_data[:content].bytesize
        source = file_data[:source]
        puts "#{PREFIX} 📄 Processing: #{filename} (#{bytesize} bytes, source: #{source})"
      end

      def warn_tempfile_read(error_msg)
        puts "#{PREFIX} ⚠️  Failed to read from Tempfile: #{error_msg}"
      end

      def start_api_call(content)
        block_count = content.length
        puts "#{PREFIX} ⏳ Sending request to LLM API with #{block_count} content block(s)..."
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
        puts exception.backtrace.first(3).join("\n") if exception.backtrace
      end
    end
  end
end
