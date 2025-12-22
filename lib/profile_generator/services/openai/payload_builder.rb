# frozen_string_literal: true

module ProfileGenerator
  module Services
    module OpenAI
      # Builds payload for OpenAI API requests
      class PayloadBuilder
        def initialize(client)
          @document_processor = DocumentProcessor.new(client)
        end

        def build_messages(prompt, system_prompt)
          messages = []
          messages << { role: "system", content: system_prompt } if system_prompt
          messages << { role: "user", content: prompt }
          messages
        end

        def process_prompt_content(prompt_content)
          system_prompt = nil
          content_blocks = []

          prompt_content.each do |block|
            if block[:type] == :text && system_prompt.nil?
              system_prompt = block[:text]
            else
              content_blocks << process_block(block)
            end
          end

          [system_prompt, content_blocks]
        end

        private

        def process_block(block)
          return { type: "text", text: block[:text] } if block[:type] == :text
          return process_document(block) if block[:type] == :document

          block
        end

        def process_document(block)
          media_type = block.dig(:source, :media_type).to_s
          data = block.dig(:source, :data)

          @document_processor.process(media_type, data)
        end
      end
    end
  end
end
