# Oh My Zsh Git Worktree Plugin
# 
# Installation:
# 1. Create directory: ~/.oh-my-zsh/custom/plugins/git-worktree
# 2. Save this file as: ~/.oh-my-zsh/custom/plugins/git-worktree/git-worktree.plugin.zsh
# 3. Add 'git-worktree' to plugins array in ~/.zshrc: plugins=(git git-worktree)
# 4. Reload: source ~/.zshrc
#
# Usage: wt <feature-name>

# Main worktree creation function
wt() {
    # Exit immediately on error
    set -e

    # Get the current git project directory (must be inside a Git repo)
    local project_dir=$(git rev-parse --show-toplevel 2>/dev/null)
    if [[ $? -ne 0 ]]; then
        echo "❌ Error: Not inside a Git repository"
        return 1
    fi

    # Get the base name of the current project folder
    local project_name=$(basename "$project_dir")

    # Get the desired feature/branch name from the first argument
    local feature_name="$1"

    # Fail fast if no feature name was provided
    if [[ -z "$feature_name" ]]; then
        echo "❌ Usage: wt <feature-name>"
        echo "📖 Example: wt feature/user-auth"
        return 1
    fi

    # Define the parent folder where all worktrees go
    local worktree_parent="${GIT_WORKTREE_PATH:-/Users/zaher/Developer/worktrees}/${project_name}"

    # Define the full path of the new worktree folder
    local worktree_path="${worktree_parent}/${feature_name}"

    # Create the parent worktrees folder if it doesn't exist
    mkdir -p "$worktree_parent"

    # Create the worktree and the branch
    echo "🌳 Creating worktree for branch '$feature_name'..."
    git -C "$project_dir" worktree add -b "$feature_name" "$worktree_path"

    # Copy untracked files and directories (like .env, .claude, .cursor, etc.)
    echo "📋 Copying untracked files and hidden directories..."
    
    # Use find to get all files and directories that are not tracked by git
    # Copy them while preserving directory structure
    cd "$project_dir"
    find . -maxdepth 1 -name ".*" -not -name ".git" -not -name ".gitignore" -not -name "." -not -name ".." | while read item; do
        if [[ -e "$item" ]]; then
            cp -R "$item" "$worktree_path/"
            echo "📋 Copied $item"
        fi
    done
    
    echo "✅ Untracked files copied successfully."

    # cd into the new worktree
    cd "$worktree_path"

    # Open the worktree in preferred editor
    local editor="${GIT_WORKTREE_EDITOR:-cursor}"
    
    if [[ "$editor" == "code" ]] && command -v code >/dev/null 2>&1; then
        code "$worktree_path" &
        echo "🚀 Opened in VS Code"
    elif [[ "$editor" == "cursor" ]] && command -v cursor >/dev/null 2>&1; then
        cursor "$worktree_path" &
        echo "🚀 Opened in Cursor"
    elif command -v cursor >/dev/null 2>&1; then
        cursor "$worktree_path" &
        echo "🚀 Opened in Cursor (fallback)"
    elif command -v code >/dev/null 2>&1; then
        code "$worktree_path" &
        echo "🚀 Opened in VS Code (fallback)"
    else
        echo "💡 No supported editor found. You can open the worktree manually at: $worktree_path"
    fi

    # Confirm success
    echo "✅ Worktree '$feature_name' created at $worktree_path and checked out."
}

# List all worktrees
wt-list() {
    echo "📂 Git Worktrees:"
    git worktree list
}

# Remove a worktree
wt-remove() {
    local worktree_name="$1"
    
    if [[ -z "$worktree_name" ]]; then
        echo "❌ Usage: wt-remove <worktree-path-or-name>"
        echo "📖 Use 'wt-list' to see available worktrees"
        return 1
    fi
    
    echo "🗑️  Removing worktree: $worktree_name"
    git worktree remove "$worktree_name"
    echo "✅ Worktree removed successfully"
}

# Prune stale worktree entries
wt-prune() {
    echo "🧹 Pruning stale worktree entries..."
    git worktree prune
    echo "✅ Worktree pruning complete"
}

# Switch to a worktree directory
wt-switch() {
    local worktree_name="$1"
    
    if [[ -z "$worktree_name" ]]; then
        echo "❌ Usage: wt-switch <feature-name>"
        echo "📖 Example: wt-switch feature/user-auth"
        return 1
    fi
    
    # Get current project info
    local project_dir=$(git rev-parse --show-toplevel 2>/dev/null)
    if [[ $? -ne 0 ]]; then
        echo "❌ Error: Not inside a Git repository"
        return 1
    fi
    
    local project_name=$(basename "$project_dir")
    local worktree_parent="${GIT_WORKTREE_PATH:-/Users/zaher/Developer/worktrees}/${project_name}"
    local worktree_path="${worktree_parent}/${worktree_name}"
    
    if [[ -d "$worktree_path" ]]; then
        cd "$worktree_path"
        echo "🔄 Switched to worktree: $worktree_name"
    else
        echo "❌ Worktree not found: $worktree_path"
        echo "📖 Use 'wt-list' to see available worktrees"
        return 1
    fi
}

# Show help
wt-help() {
    echo "🌳 Git Worktree Plugin Commands:"
    echo ""
    echo "  wt <feature-name>           Create new worktree with branch"
    echo "  wt-list                     List all worktrees"
    echo "  wt-remove <path>            Remove a worktree"
    echo "  wt-switch <feature-name>    Switch to existing worktree"
    echo "  wt-prune                    Prune stale worktree entries"
    echo "  wt-help                     Show this help"
    echo ""
    echo "📖 Examples:"
    echo "  wt feature/user-auth        # Create worktree for feature/user-auth"
    echo "  wt-switch feature/user-auth # Switch to that worktree"
    echo "  wt-remove ../feature-auth   # Remove worktree by path"
}

# Aliases for convenience
alias wtl='wt-list'
alias wtr='wt-remove'
alias wts='wt-switch'
alias wtp='wt-prune'
alias wth='wt-help'
