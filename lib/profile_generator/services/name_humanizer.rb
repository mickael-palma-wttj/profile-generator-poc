# frozen_string_literal: true

module ProfileGenerator
  module Services
    # Converts snake_case names to human-readable titles
    # Follows SRP - only responsible for name transformation
    class NameHumanizer
      def self.humanize(name)
        new.humanize(name)
      end

      # Convert snake_case to Title Case
      # e.g., "company_values" => "Company Values"
      # @param name [String] The name to humanize
      # @return [String] The humanized name
      def humanize(name)
        name
          .tr("_", " ")
          .split
          .map(&:capitalize)
          .join(" ")
      end
    end
  end
end
