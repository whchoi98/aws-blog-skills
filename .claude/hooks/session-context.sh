#!/bin/bash
# Load project context at Claude Code session start.
# SessionStart stdout is added to Claude's context, so keep it short and factual.

cd "${CLAUDE_PROJECT_DIR:-$(pwd)}" 2>/dev/null || exit 0

echo "=== Project Context ==="

NAME=$(jq -r '.name // empty' .claude-plugin/plugin.json 2>/dev/null)
VERSION=$(jq -r '.version // empty' .claude-plugin/plugin.json 2>/dev/null)
MARKET=$(jq -r '.name // empty' .claude-plugin/marketplace.json 2>/dev/null)
echo "Plugin: ${NAME:-$(basename "$(pwd)")} ${VERSION} (Claude Code plugin, install id ${NAME}@${MARKET})"

SKILL_DIR=skills/aws-blog-skills
if [ -f "$SKILL_DIR/SKILL.md" ]; then
    REFS=$(find "$SKILL_DIR/references" -name '*.md' 2>/dev/null | wc -l | tr -d ' ')
    SCRIPTS=$(find "$SKILL_DIR/scripts" -type f \( -name '*.py' -o -name '*.sh' \) 2>/dev/null | wc -l | tr -d ' ')
    echo "Skill aws-blog-skills: $REFS reference files, $SCRIPTS scripts (run as \${CLAUDE_SKILL_DIR}/scripts/...)"
fi

# Version drift between the manifest and the latest released CHANGELOG entry
RELEASED=$(grep -m1 -oP '^## \[\K[0-9]+\.[0-9]+\.[0-9]+' CHANGELOG.md 2>/dev/null)
if [ -n "$VERSION" ] && [ -n "$RELEASED" ] && [ "$VERSION" != "$RELEASED" ]; then
    echo "Note: plugin.json is $VERSION but the latest CHANGELOG release is $RELEASED"
fi

LAST_COMMIT=$(git log -1 --format="%h %s (%cr)" 2>/dev/null)
[ -n "$LAST_COMMIT" ] && echo "Last commit: $LAST_COMMIT"

BRANCH=$(git branch --show-current 2>/dev/null)
[ -n "$BRANCH" ] && echo "Branch: $BRANCH"

CHANGES=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
[ "${CHANGES:-0}" -gt 0 ] && echo "Uncommitted changes: $CHANGES file(s)"

[ -x .git/hooks/pre-commit ] || echo "Warning: git hooks not installed - run: bash scripts/install-hooks.sh"

CLAUDE_COUNT=$(find . -name "CLAUDE.md" -not -path "./.git/*" 2>/dev/null | wc -l | tr -d ' ')
ADR_COUNT=$(find docs/decisions -name 'ADR-*.md' 2>/dev/null | wc -l | tr -d ' ')
echo "CLAUDE.md files: $CLAUDE_COUNT, ADRs: $ADR_COUNT"

echo "======================"
