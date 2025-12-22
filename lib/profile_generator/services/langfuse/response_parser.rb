# frozen_string_literal: true

require "json"

module ProfileGenerator
  module Services
    module Langfuse
      # Small parser to handle Langfuse HTTP responses and error extraction.
      class ResponseParser
        class APIError < StandardError; end
        class PromptNotFoundError < StandardError; end

        def parse_response(response)
          code = response.code.to_i

          return JSON.parse(response.body) if (200..299).cover?(code)
          return handle_unauthorized if code == 401
          return handle_not_found if code == 404
          return handle_client_error(response) if (400..499).cover?(code)
          return handle_server_error(code) if (500..599).cover?(code)

          raise APIError, "Unexpected response code: #{response.code}"
        end

        def handle_unauthorized
          raise APIError, "Authentication failed. Check your Langfuse API keys."
        end

        def handle_not_found
          raise PromptNotFoundError, "Prompt not found"
        end

        def handle_client_error(response)
          error_msg = extract_error_message(response.body)
          raise APIError, "Client error (#{response.code}): #{error_msg}"
        end

        def handle_server_error(code)
          raise APIError, "Langfuse server error (#{code})"
        end

        def extract_error_message(body)
          JSON.parse(body)["message"]
        rescue JSON::ParserError, NoMethodError
          body
        end
      end
    end
  end
end
