#!/bin/zsh
# claude-artifact-bridge 1.0.1 - login.command
# Double-click once in Finder: installs Claude Code if it's missing, then signs it in to your claude.ai account
# (a browser window opens - pick the account that owns the artifacts).
export PATH="$HOME/.local/bin:$PATH"
command -v claude >/dev/null || { echo "Installing Claude Code..."; curl -fsSL https://claude.ai/install.sh | bash; }
claude auth login || claude
claude auth status
echo; echo "Done. You can close this window."
