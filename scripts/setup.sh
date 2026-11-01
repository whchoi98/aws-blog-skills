#!/bin/bash
# Project setup script for new developers.
# Usage: bash scripts/setup.sh
# The plugin needs no build. This prepares the dev harness and checks what the bundled scripts need.

set -e

cd "$(dirname "$0")/.."

echo "=== Project Setup ==="

# Check prerequisites
command -v git >/dev/null 2>&1 || { echo "ERROR: git is required"; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "ERROR: jq is required (hooks parse event JSON with it)"; exit 1; }
command -v python3 >/dev/null 2>&1 || { echo "ERROR: python3 is required (bundled scripts and tests)"; exit 1; }
command -v zip >/dev/null 2>&1 || { echo "ERROR: zip is required (package_blog.sh)"; exit 1; }
[ "${BASH_VERSINFO[0]}" -ge 4 ] || { echo "ERROR: Bash 4+ is required (found $BASH_VERSION)"; exit 1; }
if ! command -v claude >/dev/null 2>&1; then
    echo "WARNING: Claude Code CLI not found; 'claude plugin validate .' tests will be skipped"
fi
if ! command -v uv >/dev/null 2>&1 && ! python3 -c "import playwright" >/dev/null 2>&1; then
    echo "WARNING: neither uv nor the playwright module found; render_diagrams.py cannot render PNGs"
fi
if ! ls ~/.claude/plugins/cache/*/aws-diagrams/*/skills/aws-diagram-design/assets >/dev/null 2>&1; then
    echo "WARNING: aws-diagrams plugin not installed; diagram tests will be skipped (claude plugin install aws-diagrams@aws-diagrams)"
fi

# Claude hooks
chmod +x .claude/hooks/*.sh scripts/*.sh tests/run-all.sh tests/*/*.sh
chmod +x skills/aws-blog-skills/scripts/{check_structure.py,check_urls.py,lint_prose.py,package_blog.sh}
echo "Claude hooks and scripts are executable"

# Git hooks (commit-msg, pre-commit)
if [ -d ".git" ]; then
    bash scripts/install-hooks.sh
fi

# Validate the plugin manifests when the CLI is available
if command -v claude >/dev/null 2>&1; then
    claude plugin validate . >/dev/null && echo "claude plugin validate: passed"
fi

echo "=== Setup Complete ==="
echo "Next steps:"
echo "  1. Run the tests: bash tests/run-all.sh"
echo "  2. Read CLAUDE.md, skills/CLAUDE.md and docs/onboarding.md"
echo "  3. Try unreleased skill changes: claude --plugin-dir ."
