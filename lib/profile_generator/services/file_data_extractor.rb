# frozen_string_literal: true

module ProfileGenerator
  module Services
    # Extracts file data from various file formats
    # Follows SRP - only responsible for file data extraction
    class FileDataExtractor
      def initialize(logger: nil)
        @logger = logger
      end

      # Extract file data from a file object
      # @param file [Hash, Object] File object with content or tempfile
      # @return [Hash, nil] File data hash or nil if invalid
      def extract(file)
        return nil if file.nil?

        case file
        when Hash
          extract_from_hash(file)
        end
      end

      private

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
        @logger&.warn_tempfile_read(e.message)
        nil
      end
    end
  end
end
