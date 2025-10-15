# frozen_string_literal: true

module ProfileGenerator
  module Services
    # Unified prompt loader that can fetch prompts from files or Langfuse
    # Provides a consistent interface regardless of source
    class PromptManager
      class PromptNotFoundError < StandardError; end

      attr_reader :source

      # Initialize prompt manager with a specific source
      # @param source [Symbol] :file or :langfuse
      # @param file_loader [PromptLoader, nil] Optional file-based loader
      # @param langfuse_client [LangfuseClient, nil] Optional Langfuse client
      def initialize(source: :file, file_loader: nil, langfuse_client: nil)
        @source = source
        @file_loader = file_loader
        @langfuse_client = langfuse_client
        validate_source!
      end

      # Load a prompt by name
      # @param name [String] The prompt name (local file name like "company_values")
      # @param version [Integer, nil] Optional version (Langfuse only)
      # @param label [String, nil] Optional label (Langfuse only)
      # @return [String] The prompt content
      # @note For Langfuse: The name is automatically mapped to PascalCase (e.g., "company_values" -> "CompanyValues")
      #       When version and label are both nil, fetches the latest version
      #       This is the recommended usage to always get the most up-to-date prompt
      def load(name, version: nil, label: nil)
        case @source
        when :file
          file_loader.load(name)
        when :langfuse
          load_from_langfuse(name, version: version, label: label)
        end
      rescue PromptLoader::PromptNotFoundError, LangfuseClient::PromptNotFoundError => e
        raise PromptNotFoundError, e.message
      end

      # List all available prompts
      # @return [Array<String>] Array of prompt names
      def available_prompts
        case @source
        when :file
          file_loader.available_prompts
        when :langfuse
          list_langfuse_prompts
        end
      end

      # Check if a prompt exists
      # @param name [String] The prompt name
      # @return [Boolean] True if prompt exists
      def exist?(name)
        case @source
        when :file
          file_loader.exist?(name)
        when :langfuse
          begin
            load_from_langfuse(name)
            true
          rescue PromptNotFoundError
            false
          end
        end
      end

      private

      def validate_source!
        return if %i[file langfuse].include?(@source)

        raise ArgumentError, "Invalid source: #{@source}. Must be :file or :langfuse"
      end

      def file_loader
        @file_loader ||= PromptLoader.new
      end

      def langfuse_client
        @langfuse_client ||= LangfuseClient.new
      end

      def load_from_langfuse(name, version: nil, label: nil)
        # Map local file name to Langfuse name (e.g., "company_values" -> "CompanyValues")
        langfuse_name = PromptNameMapper.to_langfuse(name)
        response = langfuse_client.get_prompt(langfuse_name, version: version, label: label)
        extract_prompt_content(response)
      end

      def extract_prompt_content(response)
        # Langfuse returns different formats based on prompt type
        case response["type"]
        when "text"
          response["prompt"]
        when "chat"
          # Convert chat messages to a single text prompt
          messages = response["prompt"]
          messages.map { |msg| "#{msg['role']}: #{msg['content']}" }.join("\n\n")
        else
          raise PromptNotFoundError, "Unsupported prompt type: #{response['type']}"
        end
      end

      def list_langfuse_prompts
        response = langfuse_client.list_prompts(limit: 100)
        response["data"]&.map { |prompt| prompt["name"] } || []
      end
    end
  end
end
