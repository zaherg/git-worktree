# Oh My Zsh Git Worktree Plugin
# 
# Installation:
# 1. Create directory: ~/.oh-my-zsh/custom/plugins/git-worktree
# 2. Save this file as: ~/.oh-my-zsh/custom/plugins/git-worktree/git-worktree.plugin.zsh
# 3. Add 'git-worktree' to plugins array in ~/.zshrc: plugins=(git git-worktree)
# 4. Reload: source ~/.zshrc
#
# Usage: wt <feature-name> [from-branch]

# Configuration defaults
: ${GIT_WORKTREE_PATH:="/Users/zaher/Developer/worktrees"}
: ${GIT_WORKTREE_EDITOR:="cursor"}
: ${GIT_WORKTREE_COPY_FILES:="true"}
: ${GIT_WORKTREE_COPY_PATTERNS:=".env* .claude .cursor .vscode .idea"}
: ${GIT_WORKTREE_EXCLUDE_PATTERNS:=".DS_Store .cache node_modules"}

# Helper function to get worktree path
_get_worktree_path() {
    local project_dir=$(git rev-parse --show-toplevel 2>/dev/null)
    if [[ $? -ne 0 ]]; then
        echo "❌ Error: Not inside a Git repository" >&2
        return 1
    fi
    
    local project_name=$(basename "$project_dir")
    local worktree_parent="${GIT_WORKTREE_PATH}/${project_name}"
    echo "$worktree_parent"
}

# Helper function to check if branch exists
_branch_exists() {
    local branch_name="$1"
    git show-ref --verify --quiet "refs/heads/$branch_name" 2>/dev/null
}

# Improved file copying with configuration
_copy_untracked_files() {
    local source_dir="$1"
    local target_dir="$2"
    
    if [[ "${GIT_WORKTREE_COPY_FILES}" == "false" ]]; then
        echo "📋 File copying disabled"
        return 0
    fi
    
    echo "📋 Copying untracked files and directories..."
    
    local copied_count=0
    for pattern in ${=GIT_WORKTREE_COPY_PATTERNS}; do
        for item in ${source_dir}/${~pattern}(N); do
            if [[ -e "$item" ]]; then
                local should_exclude=false
                for exclude in ${=GIT_WORKTREE_EXCLUDE_PATTERNS}; do
                    if [[ "$item" == *"$exclude"* ]]; then
                        should_exclude=true
                        break
                    fi
                done
                
                if [[ "$should_exclude" == "false" ]]; then
                    cp -R "$item" "$target_dir/" 2>/dev/null && {
                        echo "📋 Copied $(basename "$item")"
                        ((copied_count++))
                    }
                fi
            fi
        done
    done
    
    echo "✅ Copied $copied_count files/directories"
}

# Main worktree creation function
wt() {
    set -e
    
    local feature_name="$1"
    local from_branch="$2"
    
    # Validation
    if [[ -z "$feature_name" ]]; then
        echo "❌ Usage: wt <feature-name> [from-branch]"
        echo "📖 Example: wt feature/user-auth main"
        return 1
    fi
    
    # Get worktree path
    local worktree_parent=$(_get_worktree_path) || return 1
    local worktree_path="${worktree_parent}/${feature_name}"
    
    # Check if worktree already exists
    if [[ -d "$worktree_path" ]]; then
        echo "❌ Worktree already exists at: $worktree_path"
        echo "💡 Use 'wt-switch $feature_name' to switch to it"
        return 1
    fi
    
    # Create the parent worktrees folder if it doesn't exist
    mkdir -p "$worktree_parent"
    
    # Get project directory for copying files
    local project_dir=$(git rev-parse --show-toplevel)
    
    # Check if branch exists and handle accordingly
    if _branch_exists "$feature_name"; then
        echo "📋 Branch '$feature_name' already exists, creating worktree from existing branch..."
        git worktree add "$worktree_path" "$feature_name"
    else
        echo "🌱 Creating new branch '$feature_name' from ${from_branch:-main}..."
        git worktree add -b "$feature_name" "$worktree_path" "${from_branch:-main}"
    fi

    # Copy untracked files using the improved function
    _copy_untracked_files "$project_dir" "$worktree_path"

    # cd into the new worktree
    cd "$worktree_path"

    # Open the worktree in preferred editor
    local editor="${GIT_WORKTREE_EDITOR}"
    
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
    local force="$2"
    
    if [[ -z "$worktree_name" ]]; then
        echo "❌ Usage: wt-remove <worktree-path-or-name> [--force]"
        echo "📖 Use 'wt-list' to see available worktrees"
        return 1
    fi
    
    # Check if worktree exists
    if ! git worktree list | grep -q "$worktree_name"; then
        echo "❌ Worktree not found: $worktree_name"
        echo "📖 Use 'wt-list' to see available worktrees"
        return 1
    fi
    
    # Confirmation unless --force
    if [[ "$force" != "--force" ]]; then
        read "?⚠️  Remove worktree '$worktree_name'? (y/N): " confirm
        if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
            echo "❌ Cancelled"
            return 1
        fi
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
    
    # Get worktree path using helper function
    local worktree_parent=$(_get_worktree_path) || return 1
    local worktree_path="${worktree_parent}/${worktree_name}"
    
    if [[ -d "$worktree_path" ]]; then
        cd "$worktree_path"
        echo "🔄 Switched to worktree: $worktree_name"
        echo "📂 Path: $worktree_path"
    else
        echo "❌ Worktree not found: $worktree_path"
        echo "📖 Use 'wt-list' to see available worktrees"
        return 1
    fi
}

# Show current worktree status
wt-status() {
    local current_worktree=$(git worktree list --porcelain | grep "^worktree" | grep "$(pwd)" | head -1)
    if [[ -n "$current_worktree" ]]; then
        echo "📍 Current worktree: $(basename "$(pwd)")"
        echo "📂 Path: $(pwd)"
        echo "🌿 Branch: $(git branch --show-current)"
        echo "🔗 Remote tracking: $(git rev-parse --abbrev-ref @{u} 2>/dev/null || echo 'None')"
    else
        echo "❌ Not in a worktree directory"
    fi
}

# Clean up worktree and delete branch
wt-clean() {
    local worktree_name="$1"
    local force="$2"
    
    if [[ -z "$worktree_name" ]]; then
        echo "❌ Usage: wt-clean <worktree-name> [--force]"
        echo "📖 This removes the worktree AND deletes the branch"
        return 1
    fi
    
    local worktree_parent=$(_get_worktree_path) || return 1
    local worktree_path="${worktree_parent}/${worktree_name}"
    
    if [[ ! -d "$worktree_path" ]]; then
        echo "❌ Worktree not found: $worktree_path"
        echo "📖 Use 'wt-list' to see available worktrees"
        return 1
    fi
    
    # Confirmation unless --force
    if [[ "$force" != "--force" ]]; then
        echo "⚠️  This will remove the worktree AND delete the branch '$worktree_name'"
        read "?Continue? (y/N): " confirm
        if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
            echo "❌ Cancelled"
            return 1
        fi
    fi
    
    echo "🗑️  Removing worktree and branch: $worktree_name"
    git worktree remove "$worktree_path"
    git branch -d "$worktree_name" 2>/dev/null || git branch -D "$worktree_name"
    echo "✅ Worktree and branch '$worktree_name' removed"
}

# Show help
wt-help() {
    echo "🌳 Git Worktree Plugin Commands:"
    echo ""
    echo "  wt <feature-name> [from-branch]  Create new worktree with branch"
    echo "  wt-list                          List all worktrees"
    echo "  wt-remove <path> [--force]       Remove a worktree"
    echo "  wt-switch <feature-name>         Switch to existing worktree"
    echo "  wt-status                        Show current worktree status"
    echo "  wt-clean <name> [--force]        Remove worktree AND delete branch"
    echo "  wt-prune                         Prune stale worktree entries"
    echo "  wt-help                          Show this help"
    echo ""
    echo "📖 Examples:"
    echo "  wt feature/user-auth             # Create worktree for feature/user-auth"
    echo "  wt hotfix/bug-123 develop        # Create from develop branch"
    echo "  wt-switch feature/user-auth      # Switch to that worktree"
    echo "  wt-remove ../feature-auth        # Remove worktree by path"
    echo "  wt-clean feature/user-auth       # Remove worktree and delete branch"
    echo ""
    echo "🔧 Configuration (set in ~/.zshrc):"
    echo "  GIT_WORKTREE_PATH               # Base path for worktrees"
    echo "  GIT_WORKTREE_EDITOR             # Preferred editor (cursor/code)"
    echo "  GIT_WORKTREE_COPY_FILES         # Copy files (true/false)"
    echo "  GIT_WORKTREE_COPY_PATTERNS      # Patterns to copy"
    echo "  GIT_WORKTREE_EXCLUDE_PATTERNS   # Patterns to exclude"
}

# Aliases for convenience
alias wtl='wt-list'
alias wtr='wt-remove'
alias wts='wt-switch'
alias wtp='wt-prune'
alias wth='wt-help'
alias wtst='wt-status'
alias wtc='wt-clean'
