# Bundle Wrapper Script

The `bin/bundle_wrapper` script provides automatic environment detection for Ruby bundler commands across different development environments.

## Purpose

This script solves the common problem where VS Code tasks fail in different environments due to different Ruby installation methods (asdf, rbenv, rvm, system Ruby, containers, etc.).

## How It Works

The script automatically detects your environment and uses the appropriate bundler command:

1. **Remote Containers/Codespaces**: Uses system `bundle` command
2. **Local with asdf**: Uses `~/.asdf/shims/bundle` 
3. **Local with rbenv**: Uses `bundle` (rbenv handles PATH)
4. **Local with rvm**: Uses `bundle` (rvm handles PATH)
5. **System Ruby**: Uses system `bundle` command

## Environment Detection

The script checks in this order:

1. `$REMOTE_CONTAINERS` - VS Code Remote Containers
2. `$CODESPACES` - GitHub Codespaces
3. `$VSCODE_REMOTE_CONTAINERS_SESSION` - VS Code remote session
4. `~/.asdf/shims/bundle` - asdf version manager
5. `rbenv` command availability
6. `$rvm_path` - RVM version manager
7. Falls back to system `bundle`

## Usage

### In VS Code Tasks
```json
{
  "command": "./bin/bundle_wrapper",
  "args": ["install"]
}
```

### In Terminal
```bash
# Install dependencies
./bin/bundle_wrapper install

# Run rake task
./bin/bundle_wrapper exec rake dev

# Show version with debug info
DEBUG=1 ./bin/bundle_wrapper --version
```

## Debug Mode

Set `DEBUG=1` to see environment detection details:

```bash
DEBUG=1 ./bin/bundle_wrapper --version
```

Output:
```
Environment detection:
  REMOTE_CONTAINERS: <not set>
  CODESPACES: <not set>
  VSCODE_REMOTE_CONTAINERS_SESSION: <not set>
  asdf shims available: yes
  Using bundle command: /Users/user/.asdf/shims/bundle
  Full command: /Users/user/.asdf/shims/bundle --version

Bundler version 2.7.2
```

## Supported Environments

- ✅ **Local Development with asdf**
- ✅ **Local Development with rbenv** 
- ✅ **Local Development with rvm**
- ✅ **VS Code Dev Containers**
- ✅ **GitHub Codespaces**
- ✅ **Remote SSH Development**
- ✅ **System Ruby installations**

## VS Code Task Integration

The script is integrated into all VS Code tasks in `.vscode/tasks.json`:

- Install Dependencies
- Start Server (Development) 
- Start Server (Production)
- Run Tests
- Open Console
- Run RuboCop
- Run RuboCop (Auto-fix)
- Debug Bundle Environment

## Benefits

1. **Single Configuration**: Works across all development environments
2. **Clean Tasks**: No complex inline bash logic in tasks.json
3. **Maintainable**: Environment detection logic in one place
4. **Debuggable**: Easy to troubleshoot with DEBUG mode
5. **Extensible**: Easy to add support for new Ruby version managers