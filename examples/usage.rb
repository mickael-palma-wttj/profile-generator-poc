#!/usr/bin/env ruby
# frozen_string_literal: true

# Example script demonstrating how to use the ProfileGenerator library

require_relative "../config/boot"

def print_separator
  puts "\n" + ("=" * 80) + "\n"
end

def example_basic_usage
  puts "Example 1: Basic Profile Generation"
  print_separator

  # Create a company
  company = ProfileGenerator::Models::Company.new(
    name: "Stripe",
    website: "https://stripe.com"
  )

  puts "Generating profile for: #{company.name}"
  puts "Website: #{company.website}"
  puts "\nThis will take about 1-2 minutes...\n"

  # Generate profile
  generator = ProfileGenerator::Interactors::GenerateProfile.new
  result = generator.call(company: company)

  if result.success?
    profile = result.value
    puts "\n✓ Success! Generated #{profile.sections.count} sections"
    puts "Sections: #{profile.section_names.join(', ')}"

    # Display first section
    first_section = profile.sections.first
    if first_section
      puts "\nFirst section: #{first_section.name}"
      puts "-" * 40
      puts first_section.content[0..200] + "..."
    end
  else
    puts "\n✗ Error: #{result.error}"
  end
end

def example_single_section
  puts "Example 2: Generate Single Section"
  print_separator

  company = ProfileGenerator::Models::Company.new(
    name: "OpenAI",
    website: "https://openai.com"
  )

  puts "Generating company values for: #{company.name}"

  generator = ProfileGenerator::Interactors::GenerateProfile.new
  result = generator.generate_section(
    company: company,
    section_name: "company_values"
  )

  if result.success?
    section = result.value
    puts "\n✓ Success!"
    puts "\n#{section.name}"
    puts "=" * 40
    puts section.content
  else
    puts "\n✗ Error: #{result.error}"
  end
end

def example_available_prompts
  puts "Example 3: List Available Prompts"
  print_separator

  loader = ProfileGenerator::Services::PromptLoader.new
  prompts = loader.available_prompts

  puts "Available prompt templates:"
  prompts.each_with_index do |prompt, index|
    puts "  #{index + 1}. #{prompt}"
  end
end

# Main execution
if __FILE__ == $PROGRAM_NAME
  begin
    example_available_prompts

    # Uncomment to run other examples:
    # example_single_section
    # example_basic_usage
  rescue ProfileGenerator::Error => e
    puts "\nConfiguration Error: #{e.message}"
    puts "\nMake sure you have:"
    puts "1. Created a .env file"
    puts "2. Added your ANTHROPIC_API_KEY"
    exit 1
  end
end
