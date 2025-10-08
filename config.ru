# frozen_string_literal: true

require_relative "config/boot"
require_relative "app/application"
require "rack/static"

# Configure Rack
use Rack::Static, urls: ["/styles.css", "/app.js"], root: "public"

# Run the application
run ProfileGenerator::Application
