# frozen_string_literal: true

require "logger"

module ProfileGenerator
  module Services
    # Small collaborator to handle Langfuse request/response logging.
    # Extracted to reduce the size/complexity of LangfuseClient.
    class LangfuseResponseLogger
      def initialize(logger:)
        @logger = logger
      end

      def log_request(prompt_name, version, label)
        params = []
        params << "version: #{version}" if version
        params << "label: '#{label}'" if label
        params_str = params.empty? ? "" : " (#{params.join(', ')})"

        @logger.info("[Langfuse] Fetching prompt: '#{prompt_name}'#{params_str}")
      end

      def log_response(prompt_name, result, duration)
        version = result["version"]
        labels = result["labels"]&.join(", ") || "none"
        prompt_type = result["type"]
        content_length = calculate_content_length(result, prompt_type)

        message = "[Langfuse] \u2713 Fetched '#{prompt_name}' v#{version} [#{labels}] "
        message += "(#{prompt_type}, #{content_length} chars) in #{duration.round(2)}s"

        @logger.info(message)
      end

      def calculate_content_length(result, prompt_type)
        return 0 unless result && prompt_type

        if prompt_type == "chat"
          Array(result["prompt"]).sum { |m| m["content"]&.length.to_i }
        else
          result["prompt"]&.length.to_i
        end
      end
    end
  end
end
