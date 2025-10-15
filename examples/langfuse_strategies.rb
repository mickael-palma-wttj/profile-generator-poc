#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../config/boot"

# Example: Demonstrating different ways to fetch prompts from Langfuse

puts "🎯 Langfuse Prompt Fetching Strategies\n\n"

begin
  client = ProfileGenerator::Services::LangfuseClient.new

  # Get a prompt name from the user
  print "Enter a prompt name to test (e.g., 'company_values'): "
  prompt_name = $stdin.gets.chomp

  if prompt_name.empty?
    puts "❌ No prompt name provided"
    exit 1
  end

  puts "\n#{'=' * 60}"
  puts "Fetching: #{prompt_name}"
  puts "=" * 60

  # Strategy 1: Latest version (recommended)
  puts "\n1️⃣ Fetching LATEST version (no params):"
  begin
    response = client.get_prompt(prompt_name)
    puts "   ✅ Got version #{response['version']}"
    puts "   Labels: #{response['labels'].join(', ')}"
    puts "   → This is the RECOMMENDED approach for production"
  rescue ProfileGenerator::Services::LangfuseClient::PromptNotFoundError => e
    puts "   ❌ #{e.message}"
  end

  # Strategy 2: With label
  puts "\n2️⃣ Fetching with 'production' label:"
  begin
    response = client.get_prompt(prompt_name, label: "production")
    puts "   ✅ Got version #{response['version']}"
    puts "   → Use this if you want explicit environment control"
  rescue ProfileGenerator::Services::LangfuseClient::PromptNotFoundError => e
    puts "   ❌ #{e.message}"
  end

  # Strategy 3: Specific version
  puts "\n3️⃣ Fetching specific version (e.g., version 1):"
  begin
    response = client.get_prompt(prompt_name, version: 1)
    puts "   ✅ Got version #{response['version']}"
    puts "   → Use this for reproducibility or rollback"
  rescue ProfileGenerator::Services::LangfuseClient::PromptNotFoundError => e
    puts "   ❌ #{e.message}"
  end

  puts "\n#{'=' * 60}"
  puts "💡 Recommendation"
  puts "=" * 60
  puts "For most use cases, use the LATEST approach (no params):"
  puts ""
  puts "  manager = PromptManager.new(source: :langfuse)"
  puts "  prompt = manager.load('#{prompt_name}')  # Always gets latest"
  puts ""
  puts "This ensures you always get the most up-to-date prompt without"
  puts "needing to redeploy your code!"
rescue ProfileGenerator::Services::LangfuseClient::ConfigurationError => e
  puts "❌ Configuration Error: #{e.message}"
rescue StandardError => e
  puts "❌ Error: #{e.class} - #{e.message}"
end
