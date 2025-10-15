# frozen_string_literal: true

module ProfileGenerator
  module Services
    # Small private helpers extracted from LangfuseClient to keep class size down
    module LangfuseClientResponseHandlers
      private

      def merge_duration(result, duration)
        # Attach duration for callers that want it
        result.merge("duration" => duration)
      end

      def handle_prompt_not_found(prompt_name, _exception)
        logger.error("[Langfuse] ✗ Prompt '#{prompt_name}' not found")
        raise
      end

      def handle_api_error(prompt_name, exception)
        logger.error("[Langfuse] ✗ API error for '#{prompt_name}': #{exception.message}")
        raise
      end

      def handle_json_parse_error(exception)
        logger.error("[Langfuse] ✗ Failed to parse response: #{exception.message}")
        raise ::ProfileGenerator::Services::LangfuseClient::APIError,
              "Failed to parse Langfuse response: #{exception.message}"
      end
    end
  end
end
