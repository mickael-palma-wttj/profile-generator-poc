# frozen_string_literal: true

module ProfileGenerator
  module Services
    # Maps between local file-based prompt names (snake_case) and Langfuse prompt names (PascalCase)
    # Provides bidirectional mapping for seamless switching between prompt sources
    class PromptNameMapper
      # Mapping from local file names (snake_case) to Langfuse names (PascalCase)
      FILE_TO_LANGFUSE = {
        "company_description" => "CompanyDescription",
        "company_values" => "CompanyValues",
        "file_analysis" => "FileAnalysis",
        "funding_parser" => "FundingParser",
        "key_numbers" => "KeyNumbers",
        "leadership" => "Leadership",
        "office_locations" => "OfficeLocations",
        "perks_and_benefits" => "PerksAndBenefits",
        "remote_policy" => "RemotePolicy",
        "their_story" => "TheirStory"
      }.freeze

      # Reverse mapping from Langfuse names (PascalCase) to local file names (snake_case)
      LANGFUSE_TO_FILE = FILE_TO_LANGFUSE.invert.freeze

      class << self
        # Convert local file name to Langfuse prompt name
        # @param file_name [String] Local file name (e.g., "company_values")
        # @return [String] Langfuse prompt name (e.g., "CompanyValues")
        # @raise [ArgumentError] if mapping doesn't exist
        def to_langfuse(file_name)
          FILE_TO_LANGFUSE.fetch(file_name) do
            raise ArgumentError, "No Langfuse mapping found for file name: '#{file_name}'"
          end
        end

        # Convert Langfuse prompt name to local file name
        # @param langfuse_name [String] Langfuse prompt name (e.g., "CompanyValues")
        # @return [String] Local file name (e.g., "company_values")
        # @raise [ArgumentError] if mapping doesn't exist
        def to_file(langfuse_name)
          LANGFUSE_TO_FILE.fetch(langfuse_name) do
            raise ArgumentError, "No file mapping found for Langfuse name: '#{langfuse_name}'"
          end
        end

        # Check if a local file name has a Langfuse mapping
        # @param file_name [String] Local file name
        # @return [Boolean]
        def file_mapped?(file_name)
          FILE_TO_LANGFUSE.key?(file_name)
        end

        # Check if a Langfuse name has a local file mapping
        # @param langfuse_name [String] Langfuse prompt name
        # @return [Boolean]
        def langfuse_mapped?(langfuse_name)
          LANGFUSE_TO_FILE.key?(langfuse_name)
        end

        # Get all local file names
        # @return [Array<String>]
        def all_file_names
          FILE_TO_LANGFUSE.keys
        end

        # Get all Langfuse prompt names
        # @return [Array<String>]
        def all_langfuse_names
          FILE_TO_LANGFUSE.values
        end
      end
    end
  end
end
