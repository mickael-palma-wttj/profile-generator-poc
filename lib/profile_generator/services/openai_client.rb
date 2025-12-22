# frozen_string_literal: true

require "openai"
require "json"
require "fileutils"
require "pathname"
require "base64"
require "tempfile"

module ProfileGenerator
  module Services
    class OpenAIClient
      class APIError < StandardError; end
      class ConfigurationError < StandardError; end

      DEFAULT_MODEL = "gpt-5.2-2025-12-11"
      DEFAULT_MAX_TOKENS = 4096
      DEFAULT_TEMPERATURE = 0.7
      DEFAULT_MAX_RETRIES = 3
      DEFAULT_BASE_DELAY = 1.0

      def initialize(
        api_key: nil,
        model: nil,
        max_tokens: nil,
        temperature: nil,
        max_retries: nil,
        base_delay: nil,
        debug_mode: nil,
        debug_dir: nil
      )
        @api_key = api_key || ENV.fetch("OPENAI_API_KEY", nil)
        @model = model || ENV.fetch("OPENAI_MODEL", DEFAULT_MODEL)
        @max_tokens = max_tokens || ENV.fetch("OPENAI_MAX_TOKENS", DEFAULT_MAX_TOKENS).to_i
        @temperature = temperature || ENV.fetch("OPENAI_TEMPERATURE", DEFAULT_TEMPERATURE).to_f
        @max_retries = max_retries || ENV.fetch("OPENAI_MAX_RETRIES", DEFAULT_MAX_RETRIES).to_i
        @base_delay = base_delay || ENV.fetch("OPENAI_BASE_DELAY", DEFAULT_BASE_DELAY).to_f
        @debug_mode = debug_mode || ENV.fetch("OPENAI_DEBUG", "false") == "true"
        @debug_dir = debug_dir || ENV.fetch("OPENAI_DEBUG_DIR", "debug/api_responses")

        validate_configuration!
        setup_debug_directory if @debug_mode
      end

      def generate(prompt:, system_prompt: nil, context: {})
        validate_prompt!(prompt)

        response = nil
        with_retry do
          messages = []
          messages << { role: "system", content: system_prompt } if system_prompt
          messages << { role: "user", content: prompt }

          params = {
            model: @model,
            messages: messages,
            temperature: @temperature
          }

          # Newer models (o1, gpt-5.2) use max_completion_tokens instead of max_tokens
          if @model.to_s.include?("gpt-5") || @model.to_s.include?("o1") || @model.to_s.include?("o3")
            params[:max_completion_tokens] = @max_tokens
          else
            params[:max_tokens] = @max_tokens
          end

          response = client.chat.completions.create(**params)
          save_debug_response(response, prompt, system_prompt, context) if @debug_mode
          extract_content(response)
        end
      rescue StandardError => e
        save_debug_error(e, prompt, system_prompt, context) if @debug_mode
        raise APIError, "OpenAI API error after #{@max_retries} retries: #{e.message}"
      end

      def upload_file(file:, purpose: "fine-tune")
        file_input = file.is_a?(String) ? Pathname.new(file) : file
        client.files.create(file: file_input, purpose: purpose)
      end

      def generate_file_analysis(prompt_content:, company_name: nil, context: {})
        context[:section] ||= "file_analysis"
        context[:company] ||= company_name || "unknown"

        system_prompt, content_blocks = process_prompt_content(prompt_content)

        generate(
          prompt: content_blocks,
          system_prompt: system_prompt,
          context: context
        )
      end

      private

      def client
        @client ||= OpenAI::Client.new(api_key: @api_key)
      end

      def validate_configuration!
        raise ConfigurationError, "OpenAI API key not found" unless @api_key
      end

      def validate_prompt!(prompt)
        if prompt.is_a?(String)
          raise ArgumentError, "Prompt cannot be empty" if prompt.nil? || prompt.strip.empty?
        elsif prompt.is_a?(Array)
          raise ArgumentError, "Prompt cannot be empty" if prompt.empty?
        else
          raise ArgumentError, "Prompt must be a String or Array"
        end
      end

      def extract_content(response)
        if response.respond_to?(:choices)
          response.choices.first.message.content
        else
          response.dig("choices", 0, "message", "content")
        end
      end

      def with_retry
        retries = 0
        begin
          yield
        rescue StandardError => e
          raise e unless retries < @max_retries

          sleep_time = @base_delay * (2**retries)
          sleep(sleep_time)
          retries += 1
          retry
        end
      end

      def setup_debug_directory
        FileUtils.mkdir_p(@debug_dir)
      end

      def save_debug_response(response, prompt, system_prompt, context)
        timestamp = Time.now.strftime("%Y%m%d_%H%M%S_%L")
        filename = "#{timestamp}_openai_#{context[:section] || 'unknown'}.json"
        path = File.join(@debug_dir, filename)

        data = {
          timestamp: Time.now.iso8601,
          context: context,
          request: {
            model: @model,
            system_prompt: system_prompt,
            user_prompt: sanitize_prompt_for_log(prompt)
          },
          response: response
        }

        File.write(path, JSON.pretty_generate(data))
      end

      def save_debug_error(error, prompt, system_prompt, context)
        timestamp = Time.now.strftime("%Y%m%d_%H%M%S_%L")
        filename = "#{timestamp}_openai_error_#{context[:section] || 'unknown'}.json"
        path = File.join(@debug_dir, filename)

        data = {
          timestamp: Time.now.iso8601,
          context: context,
          request: {
            model: @model,
            system_prompt: system_prompt,
            user_prompt: sanitize_prompt_for_log(prompt)
          },
          error: {
            class: error.class.name,
            message: error.message,
            backtrace: error.backtrace&.first(5)
          }
        }

        File.write(path, JSON.pretty_generate(data))
      end

      def sanitize_prompt_for_log(prompt)
        return prompt if prompt.is_a?(String)
        return prompt unless prompt.is_a?(Array)

        prompt.map do |block|
          if block.is_a?(Hash)
            new_block = block.dup
            new_block[:file_data] = "<base64 data truncated>" if new_block[:file_data]
            if new_block[:image_url] && new_block[:image_url].is_a?(Hash) && new_block[:image_url][:url]&.start_with?("data:")
              new_block[:image_url] = new_block[:image_url].dup
              new_block[:image_url][:url] = "<base64 data truncated>"
            end
            new_block
          else
            block
          end
        end
      end

      def process_prompt_content(prompt_content)
        system_prompt = nil
        content_blocks = []

        prompt_content.each do |block|
          case block[:type]
          when :text
            if system_prompt.nil?
              system_prompt = block[:text]
            else
              content_blocks << { type: "text", text: block[:text] }
            end
          when :document
            content_blocks << process_document_block(block)
          end
        end

        [system_prompt, content_blocks]
      end

      def process_document_block(block)
        media_type = block.dig(:source, :media_type).to_s
        data = block.dig(:source, :data)

        if media_type == "application/pdf"
          upload_pdf_document(data)
        elsif ["image/jpeg", "image/png", "image/gif", "image/webp"].include?(media_type)
          format_image_document(media_type, data)
        elsif media_type.start_with?("text/") || media_type.include?("json") || media_type.include?("xml")
          format_text_document(data)
        else
          raise APIError, "OpenAI Chat API does not support binary file analysis (#{media_type}) directly. Please use text-based files or Anthropic."
        end
      end

      def upload_pdf_document(data)
        decoded_data = Base64.decode64(data)
        file_id = nil

        Tempfile.create(["analysis", ".pdf"]) do |f|
          f.binmode
          f.write(decoded_data)
          f.rewind

          response = upload_file(file: f.path, purpose: "user_data")
          file_id = response[:id]
        end

        { type: "file", file: { file_id: file_id } }
      end

      def format_image_document(media_type, data)
        {
          type: "image_url",
          image_url: {
            url: "data:#{media_type};base64,#{data}"
          }
        }
      end

      def format_text_document(data)
        content = Base64.decode64(data)
        { type: "text", text: "--- File Content ---\n#{content}\n--- End File Content ---" }
      end
    end
  end
end
