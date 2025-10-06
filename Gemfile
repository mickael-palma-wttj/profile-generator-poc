# frozen_string_literal: true

source "https://rubygems.org"

ruby "~> 3.2"

# Task runner
gem "rake", "~> 13.2"

# Web framework
gem "puma", "~> 6.4"
gem "rackup", "~> 2.1"
gem "sinatra", "~> 4.0"

# AI API client
gem "ruby-anthropic", "~> 0.4.2"

# Autoloading
gem "zeitwerk", "~> 2.6"

# HTTP client for any additional web scraping needs
gem "faraday", "~> 2.9"
gem "faraday-retry", "~> 2.2"

# Environment variables
gem "dotenv", "~> 3.1"

# JSON handling
gem "multi_json", "~> 1.15"

# Validation
gem "dry-validation", "~> 1.10"

# Concurrency
gem "concurrent-ruby", "~> 1.2"

# Views
gem "erb", "~> 4.0"
gem "redcarpet", "~> 3.6"

group :development do
  gem "rerun", "~> 0.14"
  gem "rubocop", "~> 1.60", require: false
  gem "rubocop-performance", "~> 1.20", require: false
end

group :test do
  gem "rack-test", "~> 2.1"
  gem "rspec", "~> 3.13"
  gem "webmock", "~> 3.23"
end

group :development, :test do
  gem "pry", "~> 0.14"
  gem "pry-byebug", "~> 3.10"
end
