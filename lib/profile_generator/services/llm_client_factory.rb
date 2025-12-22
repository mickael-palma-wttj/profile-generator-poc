# frozen_string_literal: true

module ProfileGenerator
  module Services
    class LLMClientFactory
      def initialize(default_provider: "anthropic")
        @default_provider = default_provider
      end

      def client_for(config)
        provider = config["provider"] || @default_provider
        model = config["model"]

        # Ensure model is not nil if provider is openai, fallback to default if needed
        model = OpenAIClient::DEFAULT_MODEL if provider == "openai" && model.nil?

        case provider
        when "anthropic"
          AnthropicClient.new(model: model)
        when "openai"
          OpenAIClient.new(model: model)
        else
          raise ArgumentError, "Unknown LLM provider: #{provider}"
        end
      end
    end
  end
end
