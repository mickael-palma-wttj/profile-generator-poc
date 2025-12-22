# frozen_string_literal: true

require "json"
require "fileutils"

module ProfileGenerator
  module Services
    module OpenAI
      # Handles debug logging for OpenAI requests
      class DebugLogger
        def initialize(config)
          @config = config
          setup_directory if config.debug_mode
        end

        def log_response(response, request_data, context)
          return unless @config.debug_mode

          save_log(
            "openai",
            context,
            request_data,
            response: response
          )
        end

        def log_error(error, request_data, context)
          return unless @config.debug_mode

          save_log(
            "openai_error",
            context,
            request_data,
            error: format_error(error)
          )
        end

        private

        def setup_directory
          FileUtils.mkdir_p(@config.debug_dir)
        end

        def save_log(type, context, request, data)
          timestamp = Time.now.strftime("%Y%m%d_%H%M%S_%L")
          filename = "#{timestamp}_#{type}_#{context[:section] || 'unknown'}.json"
          path = File.join(@config.debug_dir, filename)

          content = {
            timestamp: Time.now.iso8601,
            context: context,
            request: sanitize_request(request)
          }.merge(data)

          File.write(path, JSON.pretty_generate(content))
        end

        def format_error(error)
          {
            class: error.class.name,
            message: error.message,
            backtrace: error.backtrace&.first(5)
          }
        end

        def sanitize_request(request)
          return request unless request[:messages]

          request.merge(messages: sanitize_messages(request[:messages]))
        end

        def sanitize_messages(messages)
          messages.map do |msg|
            next msg unless msg[:content].is_a?(Array)

            msg.merge(content: sanitize_content(msg[:content]))
          end
        end

        def sanitize_content(content)
          content.map do |block|
            if block[:image_url] && block[:image_url][:url]&.start_with?("data:")
              block.merge(image_url: { url: "<base64 data truncated>" })
            else
              block
            end
          end
        end
      end
    end
  end
end
