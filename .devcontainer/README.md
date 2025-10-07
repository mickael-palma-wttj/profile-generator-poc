# Dev Container Setup

This project includes a complete VS Code Dev Container configuration for a consistent development environment.

## Features

- **Ruby 3.2** with all necessary system dependencies
- **Bundler** pre-installed
- **Auto-installation** of gems on container creation
- **Port forwarding** for the web server (4567)
- **Environment variables** loaded from `.env` file
- **VS Code extensions** for Ruby development
- **Pre-configured tasks** for common operations
- **Non-root user** for better security

## Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop)
- [VS Code](https://code.visualstudio.com/)
- [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)

## Getting Started

1. **Ensure you have a `.env` file** in the project root with your API keys:
   ```env
   ANTHROPIC_API_KEY=your_api_key_here
   ANTHROPIC_MODEL=claude-sonnet-4-5-20250929
   ANTHROPIC_MAX_TOKENS=4096
   ANTHROPIC_TEMPERATURE=0.7
   ```

2. **Open in Dev Container**:
   - Open VS Code in the project folder
   - Press `Cmd+Shift+P` (Mac) or `Ctrl+Shift+P` (Windows/Linux)
   - Select "Dev Containers: Reopen in Container"
   - Wait for the container to build and start (first time takes a few minutes)

3. **Gems are automatically installed** via `postCreateCommand`

## Available Tasks

Access tasks via:
- **Command Palette**: `Cmd+Shift+P` → "Tasks: Run Task"
- **Terminal Menu**: Terminal → Run Task...
- **Keyboard Shortcut**: `Cmd+Shift+B` (default build task)

### Development Tasks

| Task | Description | Shortcut |
|------|-------------|----------|
| **Start Server (Development)** | Run with auto-reload | `Cmd+Shift+B` |
| **Start Server (Production)** | Run production mode | - |
| **Install Dependencies** | Run `bundle install` | - |
| **Open Console** | Open Pry console | - |

### Testing Tasks

| Task | Description | Shortcut |
|------|-------------|----------|
| **Run Tests** | Execute RSpec tests | `Cmd+Shift+T` |
| **Run RuboCop** | Check code style | - |
| **Run RuboCop (Auto-fix)** | Fix style issues | - |

### Utility Tasks

| Task | Description |
|------|-------------|
| **Check Health** | Test the `/health` endpoint |
| **View Logs** | Tail development logs |

## Quick Start Commands

### Start the Development Server
```bash
bundle exec rake dev
```
Access at: http://localhost:4567

### Run Tests
```bash
bundle exec rake test
```

### Open Console
```bash
bundle exec rake console
```

### Check Code Style
```bash
bundle exec rake rubocop
```

## Container Structure

```
/workspace/              # Your project files (mounted from host)
/usr/local/bundle/       # Gems (persistent volume)
/workspace/.bundle/      # Bundler config (mounted from host)
```

## Customization

### Adding System Packages

Edit `.devcontainer/Dockerfile`:
```dockerfile
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    your-package-here \
    && rm -rf /var/lib/apt/lists/*
```

### Adding VS Code Extensions

Edit `.devcontainer/devcontainer.json`:
```json
"extensions": [
  "rebornix.ruby",
  "your.extension"
]
```

### Modifying Tasks

Edit `.vscode/tasks.json` to add or modify tasks.

## Troubleshooting

### Container won't start
- Ensure Docker Desktop is running
- Check that port 4567 is not in use
- Try rebuilding: `Cmd+Shift+P` → "Dev Containers: Rebuild Container"

### Gems not installing
- Manually run: `bundle install`
- Check that your `.env` file exists
- Verify network connectivity

### Port 4567 not accessible
- Check VS Code port forwarding (Ports tab in integrated terminal)
- Verify the server is running (check terminal output)
- Try accessing http://localhost:4567

### Environment variables not loading
- Ensure `.env` file is in project root
- Rebuild container to pick up changes
- Check file permissions on `.env`

## Development Workflow

1. **Start the container** (first time or after changes)
2. **Run the dev server** using the "Start Server (Development)" task
3. **Edit code** - changes are auto-reloaded
4. **Run tests** using the "Run Tests" task
5. **Check code style** with RuboCop
6. **Commit changes** (Git works normally inside the container)

## Benefits

- ✅ **Consistent environment** across all developers
- ✅ **No local Ruby installation** required
- ✅ **Isolated dependencies** won't affect host system
- ✅ **Quick onboarding** for new team members
- ✅ **Pre-configured tools** and extensions
- ✅ **Automatic gem installation**
- ✅ **Port forwarding** configured

## Notes

- The container uses a **non-root user** (`vscode`) for better security
- Gems are stored in a **Docker volume** for faster rebuilds
- Your project files are **bind-mounted** for live editing
- The `.env` file is **automatically loaded** into the container

## Stopping the Container

- Close VS Code window, or
- `Cmd+Shift+P` → "Dev Containers: Reopen Folder Locally"

The container will stop automatically, and your work is saved on the host.
