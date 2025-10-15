# frozen_string_literal: true

module ProfileGenerator
  module Services
    # Validates and builds Company objects from request parameters
    # Follows SRP - only responsible for company parameter validation
    class CompanyBuilder
      class ValidationError < StandardError; end

      def self.build(params)
        new(params).build
      end

      def initialize(params)
        @company_name = params[:company_name]&.strip
        @website = params[:website]&.strip
        @output_language = params[:output_language] || params[:language] || params[:lang]
      end

      def build
        validate!
        Models::Company.new(name: company_name, website: website, output_language: @output_language)
      end

      private

      attr_reader :company_name, :website

      def validate!
        raise ValidationError, "Company name is required" if company_name_blank?
      end

      def company_name_blank?
        company_name.nil? || company_name.empty?
      end
    end
  end
end
