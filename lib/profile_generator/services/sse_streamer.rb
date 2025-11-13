# frozen_string_literal: true

module ProfileGenerator
  module Services
    # Streams Server-Sent Events for profile generation progress
    # Follows SRP - only responsible for SSE event streaming
    class SseStreamer
      POLL_INTERVAL = 0.5
      SESSION_CLEANUP_DELAY = 30

      def initialize(session_manager:)
        @session_manager = session_manager
      end

      def stream(session_id, output_stream)
        last_update = {}

        loop do
          session_data = session_manager.get_session(session_id)
          break unless session_data

          stream_section_updates(output_stream, session_data, last_update)

          break if completed_or_failed?(output_stream, session_data)

          sleep POLL_INTERVAL
        end

        schedule_session_cleanup(session_id)
      end

      private

      attr_reader :session_manager

      def stream_section_updates(output_stream, session_data, last_update)
        session_data[:sections].each do |section_name, section_data|
          section_key = "#{section_name}_#{section_data[:status]}"
          next if last_update[section_key]

          send_section_update(output_stream, section_name, section_data)
          last_update[section_key] = true
        end
      end

      def send_section_update(output_stream, section_name, section_data)
        data = build_section_update_data(section_name, section_data)
        send_sse_event(output_stream, "section_update", data)
      end

      def send_completion_event(output_stream, session_data)
        data = { status: "completed", profile: session_data[:profile]&.to_h }
        send_sse_event(output_stream, "complete", data)
      end

      def send_error_event(output_stream, session_data)
        data = { status: "failed", error: safe_utf8_string(session_data[:error]) }
        send_sse_event(output_stream, "error", data)
      end

      def completed_or_failed?(output_stream, session_data)
        if session_data[:status] == "completed"
          send_completion_event(output_stream, session_data)
          true
        elsif session_data[:status] == "failed"
          send_error_event(output_stream, session_data)
          true
        else
          false
        end
      end

      # Helper: Send SSE event with proper formatting
      def send_sse_event(output_stream, event_type, data)
        output_stream << "event: #{event_type}\n"
        output_stream << "data: #{JSON.generate(data)}\n\n"
      end

      def schedule_session_cleanup(session_id)
        Thread.new do
          sleep SESSION_CLEANUP_DELAY
          session_manager.delete_session(session_id)
        end
      end

      def build_section_update_data(section_name, section_data)
        {
          section_name: safe_utf8_string(section_name),
          status: safe_utf8_string(section_data[:status]),
          error: safe_utf8_string(section_data[:error]),
          content: safe_utf8_string(section_data[:section]&.content),
          raw_content: safe_utf8_string(section_data[:raw_content]),
          humanized_name: safe_utf8_string(section_data[:section]&.name),
          timestamp: section_data[:timestamp]&.iso8601
        }
      end

      # DRY: Extract repeated UTF-8 encoding logic
      def safe_utf8_string(value)
        return nil if value.nil?

        value.to_s.dup.force_encoding("UTF-8")
      end
    end
  end
end
