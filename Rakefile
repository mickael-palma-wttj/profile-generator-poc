# frozen_string_literal: true

require "bundler/setup"

desc "Run the web server"
task :server do
  exec "bundle exec rackup config.ru -p 4567"
end

desc "Run the web server with auto-reload"
task :dev do
  exec "bundle exec rerun --dir app,lib,config -- rackup config.ru -p 4567"
end

desc "Open Ruby console with app loaded"
task :console do
  require_relative "config/boot"
  require "pry"
  Pry.start
end

desc "Run RuboCop"
task :rubocop do
  exec "bundle exec rubocop"
end

desc "Run RuboCop with auto-correct"
task :rubocop_fix do
  exec "bundle exec rubocop -A"
end

desc "Run tests"
task :test do
  exec "bundle exec rspec"
end

task default: :server
