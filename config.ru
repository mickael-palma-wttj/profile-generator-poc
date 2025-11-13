# frozen_string_literal: true

require_relative "config/boot"
require_relative "app/application"
require "rack/static"

# Dynamically generate list of static files to serve
# This automatically includes all CSS and JS files in the public directory
static_files = Dir.glob("public/**/*.{css,js}").map { |f| "/#{f.sub('public/', '')}" }

# Configure Rack
use Rack::Static, urls: static_files, root: "public"

# Run the application
run ProfileGenerator::Application
