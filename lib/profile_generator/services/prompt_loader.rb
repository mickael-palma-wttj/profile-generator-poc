# frozen_string_literal: true

module ProfileGenerator
  module Services
    # Service object for loading prompt templates from files
    # Follows SRP - only responsible for reading and parsing prompt files
    class PromptLoader
      PROMPT_DIR = File.expand_path("../../../prompts", __dir__)

      class PromptNotFoundError < StandardError; end

      def initialize(prompt_dir: PROMPT_DIR)
        @prompt_dir = prompt_dir
      end

      # Load a specific prompt file
      # @param filename [String] Name of the prompt file (with or without .md extension)
      # @return [String] The prompt content
      def load(filename)
        file_path = build_file_path(filename)

        unless File.exist?(file_path)
          raise PromptNotFoundError,
                "Prompt file not found: #{file_path}"
        end

        File.read(file_path).strip
      end

      # Load all available prompt files
      # @return [Hash<String, String>] Hash of filename => prompt content
      def load_all
        prompt_files.each_with_object({}) do |file, result|
          basename = File.basename(file, ".prompt.md")
          result[basename] = load(file)
        end
      end

      # List all available prompt file names
      # @return [Array<String>] Array of prompt file basenames
      def available_prompts
        prompt_files.map { |file| File.basename(file, ".prompt.md") }
      end

      # Check if a prompt file exists
      # @param filename [String] Name of the prompt file
      # @return [Boolean]
      def exist?(filename)
        file_path = build_file_path(filename)
        File.exist?(file_path)
      end

      private

      attr_reader :prompt_dir

      def build_file_path(filename)
        filename = "#{filename}.prompt.md" unless filename.end_with?(".prompt.md")
        File.join(prompt_dir, filename)
      end

      def prompt_files
        Dir.glob(File.join(prompt_dir, "*.prompt.md"))
      end
    end
  end
end
