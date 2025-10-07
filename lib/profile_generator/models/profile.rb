# frozen_string_literal: true

module ProfileGenerator
  module Models
    # Value object representing a complete company profile
    # Aggregates multiple ProfileSection objects
    class Profile
      attr_reader :company, :sections, :generated_at

      def initialize(company:, sections: [], generated_at: Time.now)
        @company = validate_company(company)
        @sections = validate_sections(sections)
        @generated_at = generated_at
        freeze
      end

      def add_section(section)
        raise ArgumentError, "Section must be a ProfileSection" unless section.is_a?(ProfileSection)

        self.class.new(
          company: company,
          sections: sections + [section],
          generated_at: generated_at
        )
      end

      def find_section(name)
        sections.find { |section| section.name == name }
      end

      def section_names
        sections.map(&:name)
      end

      def complete?
        sections.any? && sections.none?(&:empty?)
      end

      def to_h
        {
          company: company.to_h,
          sections: sections.map(&:to_h),
          generated_at: generated_at.iso8601,
          complete: complete?
        }
      end

      def ==(other)
        other.is_a?(self.class) &&
          other.company == company &&
          other.sections == sections
      end

      alias eql? ==

      def hash
        [company, sections].hash
      end

      private

      def validate_company(company)
        raise ArgumentError, "Company must be a Company object" unless company.is_a?(Company)

        company
      end

      def validate_sections(sections)
        raise ArgumentError, "Sections must be an array" unless sections.is_a?(Array)

        sections.each do |section|
          raise ArgumentError, "All sections must be ProfileSection objects" unless section.is_a?(ProfileSection)
        end

        sections
      end
    end
  end
end
