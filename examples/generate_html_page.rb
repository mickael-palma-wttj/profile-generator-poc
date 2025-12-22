#!/usr/bin/env ruby
# frozen_string_literal: true

# Example: Generate a beautiful HTML page from a company profile
#
# Usage:
#   ruby examples/generate_html_page.rb [company_name] [output_file]
#
# Examples:
#   ruby examples/generate_html_page.rb "Stripe"
#   ruby examples/generate_html_page.rb "Qonto" "public/qonto.html"

require_relative "../config/boot"

def generate_html_page(company_name, output_file = nil, website = nil)
  puts "🚀 Generating profile for #{company_name}...\n"

  # Create company (website is optional, will auto-generate if not provided)
  website ||= "https://#{company_name.downcase.gsub(/\s+/, '')}.com"
  company = ProfileGenerator::Models::Company.new(name: company_name, website: website)

  # Generate profile
  generator = ProfileGenerator::Interactors::GenerateProfile.new
  result = generator.call(company: company)

  unless result.success?
    puts "❌ Error generating profile: #{result.error}"
    exit 1
  end

  profile = result.value
  puts "✅ Profile generated with #{profile.sections.count} sections\n"

  # Generate HTML
  puts "🎨 Creating beautiful HTML page..."
  html_generator = ProfileGenerator::Services::HTMLGenerator.new

  # Default output file
  output_file ||= "public/#{company_name.downcase.gsub(/\s+/, '_')}_profile.html"

  html_path = html_generator.generate_and_save(profile, output_file)

  puts "\n✨ Success!"
  puts "📄 HTML page: #{html_path}"
  puts "\n💡 To open in browser:"
  puts "   open #{html_path}  # macOS"
  puts "   xdg-open #{html_path}  # Linux"
  puts "   start #{html_path}  # Windows"

  html_path
end

# Main execution
if __FILE__ == $PROGRAM_NAME
  company_name = ARGV[0]
  output_file = ARGV[1]
  website = ARGV[2]

  unless company_name
    puts "Usage: ruby #{__FILE__} COMPANY_NAME [OUTPUT_FILE] [WEBSITE]"
    puts "\nExamples:"
    puts "  ruby #{__FILE__} 'Stripe'"
    puts "  ruby #{__FILE__} 'Qonto' 'public/qonto.html'"
    puts "  ruby #{__FILE__} 'Stripe' 'public/stripe.html' 'https://stripe.com'"
    exit 1
  end

  generate_html_page(company_name, output_file, website)
end
