# frozen_string_literal: true

require "uri"

module ProfileGenerator
  module Models
    # Value object representing a company
    # Follows immutability principle and SRP
    class Company
      attr_reader :name, :website

      def initialize(name:, website:)
        @name = validate_name(name)
        @website = validate_website(website)
        freeze
      end

      def to_h
        {
          name: name,
          website: website
        }
      end

      def ==(other)
        other.is_a?(self.class) &&
          other.name == name &&
          other.website == website
      end

      alias eql? ==

      def hash
        [name, website].hash
      end

      private

      def validate_name(name)
        raise ArgumentError, "Company name cannot be empty" if name.nil? || name.strip.empty?

        name.strip
      end

      def validate_website(website)
        return nil if website.nil? || website.strip.empty?

        normalized = website.strip
        normalized = "https://#{normalized}" unless normalized.match?(%r{\Ahttps?://})

        raise ArgumentError, "Invalid website URL" unless valid_url?(normalized)

        normalized
      end

      def valid_url?(url)
        uri = URI.parse(url)
        uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
      rescue URI::InvalidURIError
        false
      end
    end
  end
end
