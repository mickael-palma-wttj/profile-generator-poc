# frozen_string_literal: true

module ProfileGenerator
  module Services
    # Manages async profile generation sessions
    # Follows SRP - only responsible for session lifecycle management
    class SessionManager
      def initialize
        @sessions = {}
        @mutex = Mutex.new
      end

      def create_session(company)
        session_id = SecureRandom.uuid
        session_data = build_initial_session(company)

        @mutex.synchronize { @sessions[session_id] = session_data }
        session_id
      end

      def get_session(session_id)
        @mutex.synchronize { @sessions[session_id]&.dup }
      end

      def update_section(session_id, section_name, section_data)
        @mutex.synchronize do
          return unless @sessions[session_id]

          @sessions[session_id][:sections][section_name] = section_data
          @sessions[session_id][:status] = "generating"
        end
      end

      def complete_session(session_id, result)
        @mutex.synchronize do
          return unless @sessions[session_id]

          @sessions[session_id][:status] = result.success? ? "completed" : "failed"
          @sessions[session_id][:profile] = result.value if result.success?
          @sessions[session_id][:error] = result.error unless result.success?
          @sessions[session_id][:completed_at] = Time.now
        end
      end

      def fail_session(session_id, error_message)
        @mutex.synchronize do
          return unless @sessions[session_id]

          @sessions[session_id][:status] = "failed"
          @sessions[session_id][:error] = error_message
          @sessions[session_id][:completed_at] = Time.now
        end
      end

      def delete_session(session_id)
        @mutex.synchronize { @sessions.delete(session_id) }
      end

      def session_exists?(session_id)
        @mutex.synchronize { @sessions.key?(session_id) }
      end

      private

      def build_initial_session(company)
        {
          company: company,
          status: "starting",
          sections: {},
          profile: nil,
          error: nil,
          started_at: Time.now
        }
      end
    end
  end
end
