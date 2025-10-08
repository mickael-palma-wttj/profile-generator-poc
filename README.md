# Company Profile Generator

A Ruby web application that generates comprehensive company profiles using Anthropic's Claude (Sonnet 4) API. Built with clean architecture principles, following Ruby best practices and utilizing Zeitwerk for autoloading.

## Features

- 🤖 **AI-Powered**: Leverages Claude Sonnet 4 for intelligent content generation
- 📋 **Comprehensive Profiles**: Generates 9 distinct sections for each company:
  - Their Story (origin and founding)
  - Company Values
  - Company Description
  - Leadership Team
  - Funding History
  - Key Numbers/Metrics
  - Office Locations
  - Perks & Benefits
  - Remote Work Policy
- 🏗️ **Clean Architecture**: Follows SOLID principles, SRP, DRY, and KISS
- ⚡ **Modern Ruby**: Built with Ruby 3.2+ and Zeitwerk autoloading
- 🎨 **Beautiful UI**: Clean, responsive web interface
- 📄 **Multiple Outputs**: View in browser, print, or copy to clipboard

## Architecture

The application follows Ruby best practices and clean code principles:

```
lib/profile_generator/
├── models/              # Value objects (immutable domain models)
│   ├── company.rb      # Company value object
│   ├── profile.rb      # Profile aggregate
│   └── profile_section.rb  # Section value object
├── services/           # Service objects (single responsibility)
│   ├── anthropic_client.rb  # API communication
│   └── prompt_loader.rb     # Prompt file management
└── interactors/        # Use cases/business logic
    ├── result.rb       # Result object pattern
    └── generate_profile.rb  # Profile generation orchestration
```

### Design Patterns Used

- **Value Objects**: Immutable domain models (Company, ProfileSection, Profile)
- **Service Objects**: Single-purpose services (AnthropicClient, PromptLoader)
- **Interactors/Use Cases**: Business logic orchestration (GenerateProfile)
- **Result Object**: Explicit success/failure handling
- **Dependency Injection**: Services can be injected for testing

### Ruby Best Practices

- ✅ Frozen string literals in all files
- ✅ Methods under 10 lines (Sandi Metz rules)
- ✅ Classes under 100 lines (Sandi Metz rules)
- ✅ Max 4 parameters per method
- ✅ Immutable value objects
- ✅ Explicit error handling
- ✅ No global state
- ✅ Clear separation of concerns

## Prerequisites

- Ruby 3.2 or higher
- Bundler
- Anthropic API key (get one at [console.anthropic.com](https://console.anthropic.com))

## Installation

1. **Clone the repository** (or use your existing directory):
   ```bash
   cd /Users/mickael.palma-ext/dev/personal/profile_generator
   ```

2. **Install dependencies**:
   ```bash
   bundle install
   ```

3. **Set up environment variables**:
   Create a `.env` file from the example:
   ```bash
   cp .env.example .env
   ```
   
   Edit `.env` and add your credentials:
   ```env
   # Required
   ANTHROPIC_API_KEY=your_api_key_here
   
   # Prompt source (langfuse or file)
   PROMPT_SOURCE=langfuse
   
   # Langfuse credentials (if using langfuse)
   LANGFUSE_PUBLIC_KEY=your_langfuse_public_key
   LANGFUSE_SECRET_KEY=your_langfuse_secret_key
   ```
   
   See [`.env.example`](.env.example) for all available configuration options.

## Usage

### Running the Web Server

**Development mode** (with auto-reload):
```bash
bundle exec rake dev
```

**Production mode**:
```bash
bundle exec rake server
```

The application will be available at `http://localhost:4567`

### Using the Web Interface

1. Navigate to `http://localhost:4567`
2. Enter a company name (required)
3. Optionally add the company website
4. Click "Generate Profile"
5. Wait for the AI to generate all sections (this may take 1-2 minutes)
6. View, print, or copy the generated profile

### API Usage

The application also provides a JSON API endpoint:

```bash
curl -X POST http://localhost:4567/api/generate \
  -d "company_name=Stripe" \
  -d "website=https://stripe.com"
```

Response:
```json
{
  "success": true,
  "profile": {
    "company": {
      "name": "Stripe",
      "website": "https://stripe.com"
    },
    "sections": [...],
    "generated_at": "2024-10-06T10:30:00Z",
    "complete": true
  }
}
```

### Using in Ruby Code

You can also use the library programmatically:

```ruby
require_relative "config/boot"

# Create a company
company = ProfileGenerator::Models::Company.new(
  name: "Stripe",
  website: "https://stripe.com"
)

# Generate the profile
generator = ProfileGenerator::Interactors::GenerateProfile.new
result = generator.call(company: company)

if result.success?
  profile = result.value
  puts "Generated #{profile.sections.count} sections"
  
  profile.sections.each do |section|
    puts "\n=== #{section.name} ==="
    puts section.content
  end
else
  puts "Error: #{result.error}"
end
```

## Development

### Running the Console

```bash
bundle exec rake console
```

This opens a Pry console with the application loaded.

### Code Quality

Run RuboCop to check code style:
```bash
bundle exec rake rubocop
```

Auto-fix issues:
```bash
bundle exec rake rubocop_fix
```

### Testing

```bash
bundle exec rake test
```

## Project Structure

```
profile_generator/
├── app/
│   ├── application.rb    # Sinatra web application
│   └── views/            # ERB templates
│       ├── index.erb     # Home page
│       └── profile.erb   # Profile display
├── config/
│   └── boot.rb           # Application bootstrap
├── lib/
│   └── profile_generator/
│       ├── models/       # Domain models
│       ├── services/     # Service objects
│       └── interactors/  # Use cases
├── prompts/              # AI prompt templates
├── public/
│   └── styles.css        # CSS styles
├── config.ru             # Rack configuration
├── Gemfile               # Dependencies
├── Rakefile              # Rake tasks
└── README.md             # This file
```

## Customization

### Adding New Profile Sections

1. Create a new prompt file in `prompts/`:
   ```bash
   touch prompts/custom_section.prompt.md
   ```

2. Write your prompt template (use `[COMPANY NAME]` as placeholder)

3. The section will automatically be included in profile generation

### Modifying AI Settings

Edit your `.env` file:
```env
ANTHROPIC_MODEL=claude-sonnet-4-5-20250929
ANTHROPIC_MAX_TOKENS=4096        # Increase for longer responses
ANTHROPIC_TEMPERATURE=0.7        # 0.0-1.0 (lower = more focused)
```

## Configuration

All configuration is managed through environment variables. See [`.env.example`](.env.example) for a complete list of available settings.

### Key Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `ANTHROPIC_API_KEY` | Anthropic API key | (required) |
| `ANTHROPIC_MODEL` | Claude model to use | `claude-sonnet-4-5-20250929` |
| `ANTHROPIC_MAX_TOKENS` | Max tokens per request | `4096` |
| `ANTHROPIC_TEMPERATURE` | Creativity (0.0-1.0) | `0.7` |
| `PROMPT_SOURCE` | Prompt source (`langfuse` or `file`) | `langfuse` |
| `LANGFUSE_PUBLIC_KEY` | Langfuse public key (if using Langfuse) | - |
| `LANGFUSE_SECRET_KEY` | Langfuse secret key (if using Langfuse) | - |
| `RACK_ENV` | Environment | `development` |
| `PORT` | Server port | `4567` |
| `MAX_THREADS` | Parallel threads for generation | `5` |
| `MAX_RETRIES` | Retries for failed API calls | `3` |

For a complete list of all environment variables with descriptions and examples, see [`.env.example`](.env.example).

## Deployment

### Heroku

```bash
heroku create your-app-name
heroku config:set ANTHROPIC_API_KEY=your_key_here
git push heroku main
```

### Docker

```dockerfile
FROM ruby:3.2-alpine

WORKDIR /app
COPY Gemfile* ./
RUN bundle install
COPY . .

EXPOSE 4567
CMD ["bundle", "exec", "rackup", "config.ru", "-o", "0.0.0.0"]
```

## Troubleshooting

### "ANTHROPIC_API_KEY is required" error
- Make sure you have a `.env` file with your API key
- Check that the `.env` file is in the project root directory

### Profile generation fails
- Verify your API key is valid
- Check your internet connection
- Ensure you have sufficient API credits

### Slow generation
- Profile generation typically takes 1-2 minutes for all 9 sections
- Each section requires a separate API call to Claude

## Contributing

1. Follow Ruby style guide and RuboCop rules
2. Keep methods under 10 lines
3. Maintain single responsibility principle
4. Add tests for new features
5. Update documentation

## License

MIT License - feel free to use this project for any purpose.

## Credits

- Built with [Sinatra](http://sinatrarb.com/)
- Powered by [Anthropic Claude](https://www.anthropic.com/)
- Autoloading with [Zeitwerk](https://github.com/fxn/zeitwerk)

## Support

For issues or questions, please open an issue on GitHub.
