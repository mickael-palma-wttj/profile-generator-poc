# frozen_string_literal: true

# Zeitwerk autoloads ProfileGenerator modules
require "sinatra/base"
require "json"
require "securerandom"

module ProfileGenerator
  # Main web application using Sinatra
  # Follows thin controller pattern - delegates to interactors
  class Application < Sinatra::Base
    # Store for active generation sessions
    @@sessions = {}
    @@sessions_mutex = Mutex.new

    configure do
      set :root, File.expand_path("..", __dir__)
      set :views, File.join(settings.root, "app", "views")
      set :public_folder, File.join(settings.root, "public")
      set :show_exceptions, development?
    end

    # Home page with form
    get "/" do
      erb :index, locals: { error: nil }
    end

    # Generate profile endpoint
    post "/generate" do
      company_name = params[:company_name]&.strip
      website = params[:website]&.strip

      # Validate inputs
      if company_name.nil? || company_name.empty?
        return erb :index, locals: { error: "Company name is required" }
      end

      begin
        # Create company object
        company = Models::Company.new(
          name: company_name,
          website: website
        )

        # Generate profile
        generator = Interactors::GenerateProfile.new
        result = generator.call(company: company)

        if result.success?
          profile = result.value
          erb :profile, locals: { profile: profile, company: company }
        else
          erb :index, locals: { error: "Failed to generate profile: #{result.error}" }
        end
      rescue ArgumentError => e
        erb :index, locals: { error: e.message }
      rescue StandardError => e
        erb :index, locals: { error: "An unexpected error occurred: #{e.message}" }
      end
    end

    # Start async generation and return session ID
    post "/generate/async" do
      content_type :json

      company_name = params[:company_name]&.strip
      website = params[:website]&.strip

      if company_name.nil? || company_name.empty?
        halt 400, { error: "Company name is required" }.to_json
      end

      begin
        company = Models::Company.new(
          name: company_name,
          website: website
        )

        # Create session
        session_id = SecureRandom.uuid
        @@sessions_mutex.synchronize do
          @@sessions[session_id] = {
            company: company,
            status: "starting",
            sections: {},
            profile: nil,
            error: nil,
            started_at: Time.now
          }
        end

        # Start generation in background thread
        Thread.new do
          # Create formatter for content processing
          formatter = Services::ContentFormatter.new

          progress_callback = lambda do |data|
            @@sessions_mutex.synchronize do
              if @@sessions[session_id]
                # Format the content if section is completed
                formatted_section = data[:section]
                if data[:status] == :completed && data[:section]
                  formatted_content = formatter.format(data[:section].content)
                  formatted_section = Models::ProfileSection.new(
                    name: data[:section].name,
                    content: formatted_content,
                    prompt_file: data[:section].prompt_file
                  )
                end

                @@sessions[session_id][:sections][data[:section_name]] = {
                  status: data[:status].to_s,
                  section: formatted_section,
                  error: data[:error],
                  timestamp: data[:timestamp]
                }
                @@sessions[session_id][:status] = "generating"
              end
            end
          end

          generator = Interactors::GenerateProfile.new(progress_callback: progress_callback)
          result = generator.call(company: company)

          @@sessions_mutex.synchronize do
            if @@sessions[session_id]
              if result.success?
                @@sessions[session_id][:status] = "completed"
                @@sessions[session_id][:profile] = result.value
              else
                @@sessions[session_id][:status] = "failed"
                @@sessions[session_id][:error] = result.error
              end
              @@sessions[session_id][:completed_at] = Time.now
            end
          end
        rescue StandardError => e
          @@sessions_mutex.synchronize do
            if @@sessions[session_id]
              @@sessions[session_id][:status] = "failed"
              @@sessions[session_id][:error] = e.message
              @@sessions[session_id][:completed_at] = Time.now
            end
          end
        end

        { success: true, session_id: session_id }.to_json
      rescue ArgumentError => e
        halt 400, { success: false, error: e.message }.to_json
      rescue StandardError => e
        halt 500, { success: false, error: "An unexpected error occurred: #{e.message}" }.to_json
      end
    end

    # Server-Sent Events endpoint for progress streaming
    get "/generate/stream/:session_id" do
      session_id = params[:session_id]

      content_type "text/event-stream"
      headers "Cache-Control" => "no-cache",
              "X-Accel-Buffering" => "no"

      stream(:keep_open) do |out|
        last_update = {}

        loop do
          session_data = @@sessions_mutex.synchronize { @@sessions[session_id]&.dup }

          break unless session_data

          # Send updates for any changed sections
          session_data[:sections].each do |section_name, section_data|
            section_key = "#{section_name}_#{section_data[:status]}"
            next if last_update[section_key]

            out << "event: section_update\n"
            out << "data: #{JSON.generate({
                                            section_name: section_name,
                                            status: section_data[:status],
                                            error: section_data[:error],
                                            content: section_data[:section]&.content,
                                            humanized_name: section_data[:section]&.name,
                                            timestamp: section_data[:timestamp]&.iso8601
                                          })}\n\n"
            last_update[section_key] = true
          end

          # Send completion event
          if session_data[:status] == "completed"
            out << "event: complete\n"
            out << "data: #{JSON.generate({
                                            status: 'completed',
                                            profile: session_data[:profile]&.to_h
                                          })}\n\n"
            break
          elsif session_data[:status] == "failed"
            out << "event: error\n"
            out << "data: #{JSON.generate({
                                            status: 'failed',
                                            error: session_data[:error]
                                          })}\n\n"
            break
          end

          sleep 0.5
        end

        # Cleanup session after 30 seconds
        Thread.new do
          sleep 30
          @@sessions_mutex.synchronize { @@sessions.delete(session_id) }
        end
      end
    end

    # API endpoint for JSON response
    post "/api/generate" do
      content_type :json

      company_name = params[:company_name]&.strip
      website = params[:website]&.strip

      if company_name.nil? || company_name.empty?
        halt 400, { error: "Company name is required" }.to_json
      end

      begin
        company = Models::Company.new(
          name: company_name,
          website: website
        )

        generator = Interactors::GenerateProfile.new
        result = generator.call(company: company)

        if result.success?
          { success: true, profile: result.value.to_h }.to_json
        else
          halt 500, { success: false, error: result.error }.to_json
        end
      rescue ArgumentError => e
        halt 400, { success: false, error: e.message }.to_json
      rescue StandardError => e
        halt 500, { success: false, error: "An unexpected error occurred: #{e.message}" }.to_json
      end
    end

    # Health check endpoint
    get "/health" do
      content_type :json
      { status: "ok", timestamp: Time.now.iso8601 }.to_json
    end

    # 404 handler
    not_found do
      "Not Found"
    end

    # Error handler
    error do
      "An error occurred: #{env['sinatra.error'].message}"
    end
  end
end
