# frozen_string_literal: true

module ProfileGenerator
  module Models
    # Value object representing a section of a company profile
    # Each section corresponds to one prompt file result
    class ProfileSection
      attr_reader :name, :content, :prompt_file, :generated_at

      def initialize(name:, content:, prompt_file:, generated_at: Time.now)
        @name = validate_name(name)
        @content = validate_content(content)
        @prompt_file = validate_prompt_file(prompt_file)
        @generated_at = generated_at
        freeze
      end

      def to_h
        {
          name: name,
          content: content,
          prompt_file: prompt_file,
          generated_at: generated_at.iso8601
        }
      end

      def empty?
        content.nil? || content.strip.empty?
      end

      def ==(other)
        other.is_a?(self.class) &&
          other.name == name &&
          other.content == content &&
          other.prompt_file == prompt_file
      end

      alias eql? ==

      def hash
        [name, content, prompt_file].hash
      end

      private

      def validate_name(name)
        raise ArgumentError, "Section name cannot be empty" if name.nil? || name.strip.empty?

        name.strip
      end

      def validate_content(content)
        return "" if content.nil?

        content.strip
      end

      def validate_prompt_file(prompt_file)
        if prompt_file.nil? || prompt_file.strip.empty?
          raise ArgumentError,
                "Prompt file cannot be empty"
        end

        prompt_file.strip
      end
    end
  end
end
