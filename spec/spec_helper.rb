# frozen_string_literal: true

require "bundler/setup"
require "rspec"

# Load library without running boot that requires real ENV vars
require File.expand_path("../lib/profile_generator", __dir__)

RSpec.configure do |config|
  config.example_status_persistence_file_path = ".rspec_status"
  config.disable_monkey_patching!
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
