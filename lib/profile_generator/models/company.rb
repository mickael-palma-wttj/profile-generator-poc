# frozen_string_literal: true

require "uri"

module ProfileGenerator
  module Models
    # Value object representing a company
    # Follows immutability principle and SRP
    class Company
      attr_reader :name, :website, :output_language

      # Common language label mapping (code => human label)
      LABELS = {
        "en" => "English",
        "fr" => "Français",
        "es" => "Español",
        "de" => "Deutsch",
        "pt" => "Português",
        "zh-CN" => "中文",
        "ja" => "日本語",
        "it" => "Italiano",
        "ar" => "العربية",
        "ru" => "Русский"
      }.freeze

      # Map human names and common aliases to locale codes
      LANGUAGE_MAPPING = {
        "english" => "en", "en" => "en", "anglais" => "en",
        "français" => "fr", "francais" => "fr", "french" => "fr", "fr" => "fr",
        "español" => "es", "espanol" => "es", "spanish" => "es", "es" => "es",
        "deutsch" => "de", "german" => "de", "de" => "de",
        "português" => "pt", "portugues" => "pt", "portuguese" => "pt", "pt" => "pt",
        "中文" => "zh-CN", "chinese" => "zh-CN", "zh" => "zh-CN",
        "日本語" => "ja", "japanese" => "ja", "ja" => "ja",
        "italiano" => "it", "italian" => "it", "it" => "it",
        "العربية" => "ar", "arabic" => "ar", "ar" => "ar",
        "русский" => "ru", "russian" => "ru", "ru" => "ru"
      }.freeze

      # Return a human-friendly label for the output language (e.g. 'Français' for 'fr')
      def output_language_label
        return nil if output_language.nil?

        LABELS.fetch(output_language, output_language)
      end

      def initialize(name:, website:, output_language: nil)
        @name = validate_name(name)
        @website = validate_website(website)
        @output_language = normalize_language(output_language)
        freeze
      end

      def to_h
        {
          name: name,
          website: website,
          output_language: output_language
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

      def normalize_language(lang)
        return nil if lang.nil? || lang.to_s.strip.empty?

        val = lang.to_s.strip

        # If caller already passed a locale like 'fr' or 'zh-CN', accept it
        return val if val.match?(/^[a-z]{2}(-[A-Z]{2})?$/)

        LANGUAGE_MAPPING.fetch(val.downcase, val)
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
