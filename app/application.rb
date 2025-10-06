# frozen_string_literal: true

# Zeitwerk autoloads ProfileGenerator modules
require "sinatra/base"
require "json"

module ProfileGenerator
  # Main web application using Sinatra
  # Follows thin controller pattern - delegates to interactors
  class Application < Sinatra::Base
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
