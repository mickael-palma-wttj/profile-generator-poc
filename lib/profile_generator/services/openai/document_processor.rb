# frozen_string_literal: true

require "base64"
require "tempfile"
require "pathname"

module ProfileGenerator
  module Services
    module OpenAI
      # Handles document processing for OpenAI API
      class DocumentProcessor
        def initialize(client)
          @client = client
        end

        def process(media_type, data)
          if media_type == "application/pdf"
            upload_pdf_document(data)
          elsif image_type?(media_type)
            format_image_document(media_type, data)
          elsif text_type?(media_type)
            format_text_document(data)
          else
            raise APIError, "Unsupported media type: #{media_type}"
          end
        end

        private

        def image_type?(media_type)
          ["image/jpeg", "image/png", "image/gif", "image/webp"].include?(media_type)
        end

        def text_type?(media_type)
          media_type.start_with?("text/") ||
            media_type.include?("json") ||
            media_type.include?("xml")
        end

        def upload_pdf_document(data)
          decoded_data = Base64.decode64(data)
          file_id = nil

          Tempfile.create(["analysis", ".pdf"]) do |f|
            f.binmode
            f.write(decoded_data)
            f.rewind
            response = @client.files.create(file: f.path, purpose: "user_data")
            file_id = response[:id]
          end

          { type: "file", file: { file_id: file_id } }
        end

        def format_image_document(media_type, data)
          {
            type: "image_url",
            image_url: {
              url: "data:#{media_type};base64,#{data}"
            }
          }
        end

        def format_text_document(data)
          content = Base64.decode64(data)
          {
            type: "text",
            text: "--- File Content ---\n#{content}\n--- End File Content ---"
          }
        end
      end
    end
  end
end
