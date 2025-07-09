# Git Worktree Oh My Zsh Plugin

A powerful Oh My Zsh plugin that simplifies Git worktree management, allowing you to work on multiple branches simultaneously without the hassle of stashing or switching contexts.

## 🌟 Features

- **Easy worktree creation** with automatic branch creation
- **Automatic file copying** of untracked development files (`.env`, `.vscode`, `.cursor`, etc.)
- **Organized structure** with centralized worktree management
- **Multiple utility commands** for complete worktree lifecycle management
- **Smart editor integration** with configurable editor support (Cursor/VS Code)
- **Convenient aliases** for faster workflow

## 🚀 Installation

### Method 1: Manual Installation

1. **Create the plugin directory:**
   ```bash
   mkdir -p ~/.oh-my-zsh/custom/plugins/git-worktree
   ```

2. **Download the plugin:**
   ```bash
   curl -o ~/.oh-my-zsh/custom/plugins/git-worktree/git-worktree.plugin.zsh \
   https://raw.githubusercontent.com/zaherg/git-worktree/main/git-worktree.plugin.zsh
   ```

3. **Enable the plugin in your `~/.zshrc`:**
   ```bash
   plugins=(git git-worktree your-other-plugins...)
   ```

4. **Reload your shell:**
   ```bash
   source ~/.zshrc
   ```

### Method 2: Clone Repository

```bash
git clone https://github.com/zaherg/git-worktree.git ~/.oh-my-zsh/custom/plugins/git-worktree
```

Then follow steps 3-4 from Method 1.

## 📋 Requirements

- **Git 2.5+** (for worktree support)
- **Oh My Zsh**
- **Zsh shell**

## 🎯 Usage

### Basic Commands

#### `wt <feature-name>`
Create a new worktree with a new branch:
```bash
wt feature/user-authentication
wt bugfix/login-error
wt hotfix/security-patch
```

#### `wt-list` or `wtl`
List all existing worktrees:
```bash
wt-list
# Output:
# 📂 Git Worktrees:
# /Users/zaher/projects/myapp          abc1234 [main]
# /Users/zaher/Developer/worktrees/myapp/feature/auth  def5678 [feature/auth]
```

#### `wt-switch <feature-name>` or `wts`
Switch to an existing worktree:
```bash
wt-switch feature/user-authentication
```

#### `wt-remove <path>` or `wtr`
Remove a worktree:
```bash
wt-remove /Users/zaher/Developer/worktrees/myapp/feature/auth
# or use relative path shown in wt-list
```

#### `wt-prune` or `wtp`
Clean up stale worktree references:
```bash
wt-prune
```

#### `wt-help` or `wth`
Show help information:
```bash
wt-help
```

## 📁 Directory Structure

The plugin organizes worktrees in a clean, predictable structure:

```
/Users/zaher/Developer/worktrees/
├── project-a/
│   ├── feature/user-auth/
│   ├── bugfix/login-issue/
│   └── hotfix/security-fix/
└── project-b/
    ├── feature/new-ui/
    └── feature/api-integration/
```

## 🔄 Workflow Example

Here's a typical development workflow using the plugin:

```bash
# Working on main branch
cd ~/projects/myapp

# Urgent bug comes in, create hotfix worktree
wt hotfix/critical-bug
# → Creates worktree at /Users/zaher/Developer/worktrees/myapp/hotfix/critical-bug
# → Copies .env, .vscode, and other config files
# → Opens in Cursor automatically
# → You're now in the new worktree directory

# Fix the bug, commit, and push
git add .
git commit -m "Fix critical authentication bug"
git push origin hotfix/critical-bug

# Switch back to continue main work
wt-switch feature/user-auth
# or navigate back to main project
cd ~/projects/myapp

# Clean up when done
wt-remove /Users/zaher/Developer/worktrees/myapp/hotfix/critical-bug
```

## ⚙️ Configuration

### Environment Variables

The plugin supports the following environment variables for easy configuration:

#### `GIT_WORKTREE_PATH`
Set a custom directory for worktrees (default: `/Users/zaher/Developer/worktrees`):

```bash
# Add to your ~/.zshrc
export GIT_WORKTREE_PATH="/your/custom/worktrees/path"
```

#### `GIT_WORKTREE_EDITOR`
Choose your preferred editor (`cursor` or `code`, default: `cursor`):

```bash
# Add to your ~/.zshrc
export GIT_WORKTREE_EDITOR="code"    # Use VS Code
export GIT_WORKTREE_EDITOR="cursor"  # Use Cursor (default)
```

### Editor Integration

The plugin automatically opens new worktrees in your preferred editor with intelligent fallbacks:

1. **Preferred editor**: Uses `GIT_WORKTREE_EDITOR` if set and available
2. **Cursor fallback**: Falls back to Cursor if available
3. **VS Code fallback**: Falls back to VS Code if Cursor unavailable
4. **Manual open**: Shows path for manual opening if no editor found

### Configuration Examples

```bash
# Example ~/.zshrc configuration
export GIT_WORKTREE_PATH="/Users/$(whoami)/workspace/worktrees"
export GIT_WORKTREE_EDITOR="code"

# Reload your shell
source ~/.zshrc
```

## 🎨 Aliases

The plugin provides convenient aliases for faster workflow:

| Alias | Command | Description |
|-------|---------|-------------|
| `wtl` | `wt-list` | List worktrees |
| `wtr` | `wt-remove` | Remove worktree |
| `wts` | `wt-switch` | Switch to worktree |
| `wtp` | `wt-prune` | Prune stale entries |
| `wth` | `wt-help` | Show help |

## 🐛 Troubleshooting

### "Not inside a Git repository" error
Make sure you're inside a Git repository when running `wt` commands.

### Worktree already exists
If you get an error about a worktree already existing, use `wt-list` to check existing worktrees and `wt-remove` to clean up if needed.

### Files not copying
The plugin copies untracked hidden files (starting with `.`). If specific files aren't copying, ensure they're not in `.gitignore` and are in the root directory.

### Permission issues
Ensure you have write permissions to the worktree directory (`/Users/zaher/Developer/worktrees/` by default).

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Git Worktree Documentation](https://git-scm.com/docs/git-worktree)
- [Oh My Zsh](https://ohmyz.sh/) for the amazing plugin framework
- The Git community for developing the worktree feature

## 📝 Changelog

### v1.1.0
- Added environment variable support for custom worktree paths (`GIT_WORKTREE_PATH`)
- Added environment variable support for editor selection (`GIT_WORKTREE_EDITOR`)
- Enhanced editor integration with intelligent fallbacks (Cursor → VS Code)
- Improved configuration flexibility

### v1.0.0
- Initial release
- Basic worktree creation with `wt` command
- File copying for untracked development files
- Complete worktree management suite
- Cursor editor integration
- Convenient aliases

---

**Made with ❤️ for developers who love Git worktrees and with Claude 🤖**
