# frozen_string_literal: true

# Zeitwerk autoloads ProfileGenerator modules
require "sinatra/base"
require "json"
require "securerandom"
require "cgi"

module ProfileGenerator
  # Console logger for application events - separates logging concerns (SRP)
  class RequestLogger
    PREFIX = "[Application]"

    def log_files_cached(count)
      puts "#{PREFIX} Cached #{count} file(s) successfully"
    end

    def log_file_cached(idx, filename, bytes)
      puts "#{PREFIX} 📄 Cached file #{idx}: #{filename} (#{bytes} bytes)"
    end

    def log_file_cache_error(idx, error_msg)
      puts "#{PREFIX} ⚠️ Failed to cache file #{idx}: #{error_msg}"
    end

    def log_analysis_warning(error_msg)
      puts "#{PREFIX} Warning: File analysis failed: #{error_msg}"
    end
  end

  # Main web application using Sinatra
  # Follows thin controller pattern - delegates to service objects
  # Each endpoint is under 10 lines (Sandi Metz rule)
  class Application < Sinatra::Base
    configure do
      set :root, File.expand_path("..", __dir__)
      set :views, File.join(settings.root, "app", "views")
      set :public_folder, File.join(settings.root, "public")
      set :show_exceptions, development?

      # Initialize prompt manager based on environment configuration
      prompt_source = ENV.fetch("PROMPT_SOURCE", "langfuse").to_sym
      begin
        set :prompt_manager, Services::PromptManager.new(source: prompt_source)
        puts "📋 Using #{prompt_source} prompt source"
      rescue Services::LangfuseClient::ConfigurationError => e
        puts "⚠️  Langfuse not configured: #{e.message}"
        puts "📋 Falling back to file-based prompts"
        set :prompt_manager, Services::PromptManager.new(source: :file)
      end

      # Initialize services (dependency injection)
      set :session_manager, Services::SessionManager.new
      set :async_generator, Services::AsyncProfileGenerator.new(
        session_manager: settings.session_manager,
        prompt_manager: settings.prompt_manager
      )
      set :sse_streamer, Services::SseStreamer.new(
        session_manager: settings.session_manager
      )
      set :request_logger, RequestLogger.new
    end

    # Home page with form
    get "/" do
      erb :index, locals: { error: nil }
    end

    # Generate profile endpoint (synchronous)
    post "/generate" do
      company = build_company_from_params
      analyze_files_sync(params[:files]) if file_uploads_present?
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
      spawn_async_workflow(session_id, company, params[:files]) if file_uploads_present?

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

    # Helper: Check if file uploads are present
    def file_uploads_present?
      params[:files] && !params[:files].empty?
    end

    # Helper: Build company from request params
    def build_company_from_params
      Services::CompanyBuilder.build(params)
    end

    # Helper: Spawn async background workflow
    def spawn_async_workflow(session_id, company, files_param)
      cached_files = cache_file_contents(files_param)
      if cached_files.empty?
        notify_analysis_status(session_id, "skipped")
        return
      end

      Thread.new do
        analyze_files_with_progress(session_id, cached_files, company)
        settings.async_generator.generate(session_id, company)
      end
    end

    # Helper: Analyze uploaded files and update progress
    def analyze_files_with_progress(session_id, files, company)
      notify_analysis_status(session_id, "in_progress")

      analyzer = Services::FileAnalyzer.new(
        Services::AnthropicClient.new,
        prompt_manager: settings.prompt_manager,
        company_name: company&.name
      )

      analysis = analyzer.analyze_files(files)
      store_analysis_result(session_id, analysis)
    rescue StandardError => e
      handle_analysis_error(session_id, e)
    end

    # Helper: Format analysis content as JSON
    def format_analysis_content(analysis)
      json_string = JSON.pretty_generate(analysis)
      escaped_json = CGI.escapeHTML(json_string)
      "<pre class=\"analysis-content\"><code>#{escaped_json}</code></pre>"
    end

    # Helper: Analyze files synchronously (for sync endpoint)
    def analyze_files_sync(files_param)
      files = extract_uploaded_files(files_param)
      return if files.empty?

      analyzer = Services::FileAnalyzer.new(
        Services::AnthropicClient.new,
        prompt_manager: settings.prompt_manager
      )

      analysis = analyzer.analyze_files(files)
      ProfileGenerator.configuration.file_analysis = analysis if analysis && !analysis.empty?
    rescue StandardError => e
      settings.request_logger.log_analysis_warning(e.message)
    end

    # Helper: Extract uploaded files from request params
    def extract_uploaded_files(files_param)
      return [] if files_param.nil?

      if files_param.is_a?(Array)
        files_param.compact
      elsif files_param.respond_to?(:read)
        [files_param]
      else
        []
      end
    end

    # Helper: Notify client about analysis status
    def notify_analysis_status(session_id, status)
      settings.session_manager.update_section(session_id, "file_analysis", {
                                                status: status,
                                                section: nil,
                                                raw_content: nil,
                                                error: nil,
                                                timestamp: Time.now
                                              })
    end

    # Helper: Store analysis result and notify client
    def store_analysis_result(session_id, analysis)
      if analysis && !analysis.empty?
        ProfileGenerator.configuration.file_analysis = analysis
        store_analysis_section(session_id, analysis)
      else
        notify_analysis_status(session_id, "completed")
      end
    end

    # Helper: Store analysis section in session manager
    def store_analysis_section(session_id, analysis)
      section = build_analysis_section(analysis)
      settings.session_manager.update_section(session_id, "file_analysis", {
                                                status: "completed",
                                                section: section,
                                                raw_content: analysis.to_json,
                                                error: nil,
                                                timestamp: Time.now
                                              })
    end

    # Helper: Build analysis section model
    def build_analysis_section(analysis)
      Models::ProfileSection.new(
        name: "Reference Files Analysis",
        content: format_analysis_content(analysis),
        prompt_file: "file_analysis.prompt.md"
      )
    end

    # Helper: Handle analysis errors
    def handle_analysis_error(session_id, error)
      settings.request_logger.log_analysis_warning(error.message)
      settings.session_manager.update_section(session_id, "file_analysis", {
                                                status: "failed",
                                                section: nil,
                                                raw_content: nil,
                                                error: error.message,
                                                timestamp: Time.now
                                              })
    end

    # Helper: Generate profile using interactor
    def generate_profile(company)
      generator = Interactors::GenerateProfile.new(
        prompt_manager: settings.prompt_manager
      )
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

    # Helper: Cache file contents while Tempfiles are open
    def cache_file_contents(files_param)
      files = extract_uploaded_files(files_param)
      cached_files = files.each_with_index.filter_map { |file, idx| cache_single_file(file, idx) }

      settings.request_logger.log_files_cached(cached_files.length)
      cached_files
    end

    # Helper: Cache a single file
    def cache_single_file(file, idx)
      return nil unless file.is_a?(Hash) && file[:tempfile]

      filename = extract_filename(file, idx)
      content = read_file_content(file[:tempfile])

      return nil unless content

      settings.request_logger.log_file_cached(idx, filename, content.bytesize)
      { filename: filename, content: content }
    rescue StandardError => e
      settings.request_logger.log_file_cache_error(idx, e.message)
      nil
    end

    # Helper: Extract filename from file object
    def extract_filename(file, idx)
      if file.is_a?(Hash) && file[:filename]
        file[:filename]
      elsif file.respond_to?(:original_filename)
        file.original_filename
      else
        "file_#{idx}"
      end
    end

    # Helper: Read file content safely
    def read_file_content(tempfile)
      tempfile.rewind if tempfile.respond_to?(:rewind)
      content = tempfile.read
      content.empty? ? nil : content
    end

    # Helper: Setup SSE headers
    def setup_sse_headers
      content_type "text/event-stream"
      headers "Cache-Control" => "no-cache",
              "X-Accel-Buffering" => "no"
    end
  end
end
