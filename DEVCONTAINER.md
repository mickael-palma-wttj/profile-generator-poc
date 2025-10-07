# Using Dev Container with Profile Generator

## Quick Start

1. **Ensure Docker Desktop is running**

2. **Create your `.env` file** (copy from `.env.example`):
   ```bash
   cp .env.example .env
   ```
   Then edit `.env` and add your Anthropic API key.

3. **Open in Dev Container**:
   - Open VS Code
   - Press `Cmd+Shift+P`
   - Type "Dev Containers: Reopen in Container"
   - Wait for the build to complete (2-3 minutes first time)

4. **Start developing**:
   - Press `Cmd+Shift+B` to start the development server
   - Open http://localhost:4567 in your browser

## What You Get

The dev container provides:
- ✅ Ruby 3.2 environment
- ✅ All gems automatically installed
- ✅ Environment variables from `.env` loaded
- ✅ Port 4567 forwarded to your host
- ✅ Ruby extensions for VS Code
- ✅ Pre-configured tasks for all operations
- ✅ Debugging support with breakpoints

## Available Tasks (Cmd+Shift+P → "Tasks: Run Task")

### Main Tasks
- **Start Server (Development)** - Auto-reload on file changes (Default: `Cmd+Shift+B`)
- **Start Server (Production)** - Production mode
- **Install Dependencies** - Run `bundle install`
- **Open Console** - Interactive Ruby console with Pry
- **Run Tests** - Execute RSpec test suite
- **Run RuboCop** - Check code style
- **Run RuboCop (Auto-fix)** - Auto-fix style issues
- **Check Health** - Test the health endpoint
- **View Logs** - Tail development logs

## Tips

### Accessing the Application
- The server runs on port 4567
- VS Code automatically forwards this port
- Click on the "Ports" tab in the terminal panel to see forwarded ports
- Or visit http://localhost:4567 directly

### Making Changes
- All file changes are immediately reflected (bind mount)
- Development server auto-reloads on changes
- No need to rebuild the container for code changes

### Installing New Gems
1. Add gem to `Gemfile`
2. Run the "Install Dependencies" task, or
3. Run `bundle install` in the terminal

### Rebuilding the Container
If you change `.devcontainer/Dockerfile` or `devcontainer.json`:
- Press `Cmd+Shift+P`
- Type "Dev Containers: Rebuild Container"

### Debugging
- Set breakpoints in your Ruby code (click left margin)
- Use `binding.pry` in your code
- When server hits the breakpoint, you get an interactive console

## File Structure

```
.devcontainer/
├── Dockerfile              # Container image definition
├── devcontainer.json       # VS Code dev container config
└── README.md              # This file

.vscode/
├── tasks.json             # Predefined tasks
└── launch.json            # Debug configurations

.dockerignore              # Files to exclude from Docker context
.env                       # Your environment variables (not in Git)
.env.example               # Template for .env file
```

## Troubleshooting

### Container won't start
```bash
# Check Docker is running
docker ps

# Rebuild from scratch
Cmd+Shift+P → "Dev Containers: Rebuild Container Without Cache"
```

### Can't access http://localhost:4567
- Check the "Ports" tab in VS Code terminal panel
- Ensure the server task is running
- Look for errors in the terminal output

### Gems won't install
```bash
# Manually run in terminal
bundle install

# Or use the task
Cmd+Shift+P → "Tasks: Run Task" → "Install Dependencies"
```

### Environment variables not loading
- Ensure `.env` file exists in project root
- Check file has correct format (KEY=value)
- Rebuild container to reload env vars

## Benefits of Using Dev Container

1. **Consistent Environment**: Everyone uses the same Ruby version and setup
2. **No Local Installation**: Don't need Ruby installed on your Mac
3. **Isolated**: Project dependencies don't affect your system
4. **Quick Onboarding**: New developers can start in minutes
5. **Reproducible**: Same environment in development and CI/CD

## Next Steps

- Start the dev server: `Cmd+Shift+B`
- Visit http://localhost:4567
- Edit code and see changes auto-reload
- Run tests with `Cmd+Shift+T`
- Explore the tasks menu for more operations

Enjoy coding! 🚀
