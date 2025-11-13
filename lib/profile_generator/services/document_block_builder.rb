# frozen_string_literal: true

require "base64"

module ProfileGenerator
  module Services
    # Builds document blocks from file data for Anthropic API
    # Follows SRP - only responsible for document block creation
    class DocumentBlockBuilder
      MEDIA_TYPES = {
        ".pdf" => "application/pdf",
        ".txt" => "text/plain",
        ".docx" => "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
        ".doc" => "application/msword",
        ".md" => "text/markdown"
      }.freeze

      def initialize(logger: nil)
        @logger = logger
      end

      # Build a document block from file data
      # @param file_data [Hash] File data with :filename and :content keys
      # @return [Hash] Document block for Anthropic API
      def build(file_data)
        @logger&.log_file_processing(file_data)
        media_type = get_media_type(file_data[:filename])
        build_document_block(media_type, file_data[:content])
      end

      private

      def get_media_type(filename)
        extension = File.extname(filename).downcase
        MEDIA_TYPES[extension] || "application/octet-stream"
      end

      def build_document_block(media_type, content)
        {
          type: :document,
          source: {
            type: :base64,
            media_type: media_type.to_sym,
            data: Base64.strict_encode64(content)
          }
        }
      end
    end
  end
end
