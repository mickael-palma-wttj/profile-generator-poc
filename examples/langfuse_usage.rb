#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../config/boot"

# Example: Using Langfuse prompts in profile generation
puts "🔄 Generating profile with Langfuse prompts\n\n"

# Create company
company = ProfileGenerator::Models::Company.new(
  name: "Stripe",
  website: "https://stripe.com"
)

begin
  # Initialize prompt manager with Langfuse source
  prompt_manager = ProfileGenerator::Services::PromptManager.new(source: :langfuse)

  puts "✅ Connected to Langfuse"
  puts "Available prompts: #{prompt_manager.available_prompts.length}\n\n"

  # Generate profile using Langfuse prompts
  generator = ProfileGenerator::Interactors::GenerateProfile.new(
    prompt_loader: prompt_manager
  )

  puts "🚀 Generating profile for #{company.name}..."
  puts "Using prompts from Langfuse cloud\n\n"

  result = generator.call(company: company)

  if result.success?
    profile = result.value
    puts "✅ Profile generated successfully!"
    puts "\nSections generated:"
    profile.sections.each do |section|
      puts "  ✓ #{section.name}"
    end
  else
    puts "❌ Error: #{result.error}"
  end
rescue ProfileGenerator::Services::LangfuseClient::ConfigurationError => e
  puts "❌ Langfuse not configured: #{e.message}"
  puts "\n💡 To use Langfuse, add to your .env file:"
  puts "   LANGFUSE_PUBLIC_KEY=pk-lf-your-key"
  puts "   LANGFUSE_SECRET_KEY=sk-lf-your-key"
rescue StandardError => e
  puts "❌ Error: #{e.class} - #{e.message}"
  puts "\nBacktrace:"
  puts(e.backtrace.first(5).map { |line| "  #{line}" })
end
