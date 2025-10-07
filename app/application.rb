# frozen_string_literal: true

# Zeitwerk autoloads ProfileGenerator modules
require "sinatra/base"
require "json"
require "securerandom"

module ProfileGenerator
  # Main web application using Sinatra
  # Follows thin controller pattern - delegates to service objects
  # Each endpoint is under 10 lines (Sandi Metz rule)
  class Application < Sinatra::Base
    configure do
      set :root, File.expand_path("..", __dir__)
      set :views, File.join(settings.root, "app", "views")
      set :public_folder, File.join(settings.root, "public")
      set :show_exceptions, development?

      # Initialize services (dependency injection)
      set :session_manager, Services::SessionManager.new
      set :async_generator, Services::AsyncProfileGenerator.new(
        session_manager: settings.session_manager
      )
      set :sse_streamer, Services::SseStreamer.new(
        session_manager: settings.session_manager
      )
    end

    # Home page with form
    get "/" do
      erb :index, locals: { error: nil }
    end

    # Generate profile endpoint (synchronous)
    post "/generate" do
      company = build_company_from_params
      result = generate_profile(company)

      render_profile_result(result, company)
    rescue Services::CompanyBuilder::ValidationError => e
      erb :index, locals: { error: e.message }
    rescue StandardError => e
      erb :index, locals: { error: "An unexpected error occurred: #{e.message}" }
    end

    # Start async generation and return session ID
    post "/generate/async" do
      content_type :json

      company = build_company_from_params
      session_id = settings.session_manager.create_session(company)
      settings.async_generator.generate(session_id, company)

      { success: true, session_id: session_id }.to_json
    rescue Services::CompanyBuilder::ValidationError => e
      halt 400, { success: false, error: e.message }.to_json
    rescue StandardError => e
      halt 500, { success: false, error: "An unexpected error occurred: #{e.message}" }.to_json
    end

    # Server-Sent Events endpoint for progress streaming
    get "/generate/stream/:session_id" do
      setup_sse_headers

      stream(:keep_open) do |out|
        settings.sse_streamer.stream(params[:session_id], out)
      end
    end

    # API endpoint for JSON response
    post "/api/generate" do
      content_type :json

      company = build_company_from_params
      result = generate_profile(company)

      render_api_result(result)
    rescue Services::CompanyBuilder::ValidationError => e
      halt 400, { success: false, error: e.message }.to_json
    rescue StandardError => e
      halt 500, { success: false, error: "An unexpected error occurred: #{e.message}" }.to_json
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

    private

    # Helper: Build company from request params
    def build_company_from_params
      Services::CompanyBuilder.build(params)
    end

    # Helper: Generate profile using interactor
    def generate_profile(company)
      generator = Interactors::GenerateProfile.new
      generator.call(company: company)
    end

    # Helper: Render profile result for web view
    def render_profile_result(result, company)
      if result.success?
        erb :profile, locals: { profile: result.value, company: company }
      else
        erb :index, locals: { error: "Failed to generate profile: #{result.error}" }
      end
    end

    # Helper: Render profile result for API
    def render_api_result(result)
      if result.success?
        { success: true, profile: result.value.to_h }.to_json
      else
        halt 500, { success: false, error: result.error }.to_json
      end
    end

    # Helper: Setup SSE headers
    def setup_sse_headers
      content_type "text/event-stream"
      headers "Cache-Control" => "no-cache",
              "X-Accel-Buffering" => "no"
    end
  end
end
