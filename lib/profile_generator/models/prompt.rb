# frozen_string_literal: true

module ProfileGenerator
  module Models
    class Prompt
      attr_reader :content, :config

      def initialize(content:, config: {})
        @content = content
        @config = config
      end

      def to_s
        content
      end
    end
  end
end
