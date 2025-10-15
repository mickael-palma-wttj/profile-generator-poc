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

# Profile generation tasks
namespace :profile do
  desc "Generate company profile with HTML export"
  task :generate, [:company_name, :website, :output_dir] do |_t, args|
    require_relative "config/boot"

    usage_msg = "Company name required. Usage: rake 'profile:generate[CompanyName]' (note the quotes for zsh)"
    company_name = args[:company_name] || raise(usage_msg)
    website = args[:website] || "https://#{company_name.downcase.gsub(/\s+/, '')}.com"
    output_dir = args[:output_dir] || "public"

    puts "🚀 Generating profile for #{company_name}..."
    puts "🌐 Website: #{website}"

    # Create company
    company = ProfileGenerator::Models::Company.new(name: company_name, website: website)

    # Generate profile
    generator = ProfileGenerator::Interactors::GenerateProfile.new
    result = generator.call(company: company)

    if result.success?
      profile = result.value
      puts "✅ Profile generated with #{profile.sections.count} sections"

      # Save as markdown
      markdown_file = File.join(output_dir, "#{company_name.downcase.gsub(/\s+/, '_')}_profile.md")
      markdown_content = build_markdown_content(profile)
      File.write(markdown_file, markdown_content)
      puts "📄 Markdown saved: #{markdown_file}"

      # Generate HTML
      html_generator = ProfileGenerator::Services::HtmlGenerator.new
      html_file = File.join(output_dir, "#{company_name.downcase.gsub(/\s+/, '_')}_profile.html")
      html_generator.generate_and_save(profile, html_file)

      puts "\n✨ Success! Files generated:"
      puts "  📄 Markdown: #{markdown_file}"
      puts "  🌐 HTML: #{html_file}"
      puts "\nOpen HTML: open #{html_file}"
    else
      puts "❌ Error: #{result.error}"
      exit 1
    end
  end

  desc "Convert existing markdown profile to HTML"
  task :to_html, [:markdown_file, :output_file] do |_t, args|
    require_relative "config/boot"

    markdown_file = args[:markdown_file] || "qonto_prompt_output.md"
    args[:output_file] || "public/#{File.basename(markdown_file, '.md')}.html"

    unless File.exist?(markdown_file)
      puts "❌ Error: File not found: #{markdown_file}"
      exit 1
    end

    puts "📄 Reading markdown file: #{markdown_file}"
    puts "🎨 Converting to HTML..."
    puts "⚠️  Note: This task requires parsing markdown to rebuild profile structure"
    puts "    For best results, use: rake profile:generate[CompanyName]"

    # This would need a markdown parser to reconstruct the profile object
    # For now, recommend using the generate task instead
    puts "\n💡 Tip: To generate both markdown and HTML:"
    puts "   rake profile:generate[CompanyName]"
  end
end

def build_markdown_content(profile)
  parts = []
  parts << "# #{profile.company.name} - Company Profile"
  parts << "Generated: #{profile.generated_at.strftime('%d/%m/%Y')}"
  parts << ""

  parts.concat(build_sections_markdown(profile.sections))

  parts.join("\n")
end

def build_sections_markdown(sections)
  sections.flat_map do |section|
    ["## #{section.name}", "", section.content, "", "---", ""]
  end
end

task default: :server
