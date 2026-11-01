#!/bin/bash
# Detect documentation sync needs after file changes.
# Triggered by PostToolUse (Write|Edit). Claude Code passes the event as JSON on
# stdin; a path argument is accepted for manual runs and tests.
# Walks parent directories (module root included) to find CLAUDE.md before warning.

if [ "$#" -ge 1 ]; then
    FILE_PATH="$1"
    FROM_HOOK=false
else
    FILE_PATH=$(jq -r '.tool_input.file_path // empty' 2>/dev/null)
    FROM_HOOK=true
fi
[ -z "$FILE_PATH" ] && exit 0

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
cd "$PROJECT_DIR" 2>/dev/null || exit 0
FILE_PATH="${FILE_PATH#"$PROJECT_DIR"/}"
FILE_PATH="${FILE_PATH#./}"

# Top-level source directories. skills/ is the shipped plugin content; its module
# doc is skills/CLAUDE.md (never inside skills/<name>/, which ships as the skill).
SOURCE_ROOTS="skills tests"

MESSAGES=()

IS_SOURCE=false
for ROOT in $SOURCE_ROOTS; do
    if [[ "$FILE_PATH" == ${ROOT}/* ]]; then
        IS_SOURCE=true
        DIR=$(dirname "$FILE_PATH")
        FOUND_CLAUDE=false
        CHECK_DIR="$DIR"
        while [ "$CHECK_DIR" != "." ] && [ -n "$CHECK_DIR" ]; do
            if [ -f "$CHECK_DIR/CLAUDE.md" ]; then
                FOUND_CLAUDE=true
                break
            fi
            [ "$CHECK_DIR" = "$ROOT" ] && break
            CHECK_DIR=$(dirname "$CHECK_DIR")
        done
        if ! $FOUND_CLAUDE; then
            MESSAGES+=("[doc-sync] $ROOT/CLAUDE.md is missing. Create module documentation.")
        fi
        break
    fi
done

# Alert if no ADRs exist when source or architecture files change
if $IS_SOURCE || [[ "$FILE_PATH" == docs/architecture.md ]]; then
    ADR_COUNT=$(find docs/decisions -name 'ADR-*.md' 2>/dev/null | wc -l)
    if [ "$ADR_COUNT" -eq 0 ]; then
        MESSAGES+=("[doc-sync] No ADRs found. Record architectural decisions with /add-adr.")
    fi
fi

# Shipped skill content changed: installed copies only update when the version changes
if [[ "$FILE_PATH" == skills/*/* ]]; then
    if git diff --quiet HEAD -- .claude-plugin/plugin.json 2>/dev/null; then
        MESSAGES+=("[doc-sync] Shipped skill changed: bump .claude-plugin/plugin.json version and add a CHANGELOG.md [Unreleased] entry in both languages (docs/runbooks/release-plugin.md).")
    fi
fi

if [[ "$FILE_PATH" == skills/*/references/style.md || "$FILE_PATH" == skills/*/references/humanize-checklist.md ]]; then
    MESSAGES+=("[doc-sync] Writing rules changed: mirror added or removed terms in scripts/lint_prose.py (HARD, HARD_RE, COUNT) and mark confirmed rules with (YYYY-MM-DD 확정).")
fi

if [[ "$FILE_PATH" == skills/*/references/structure.md || "$FILE_PATH" == skills/*/assets/templates/blog-template.md ]]; then
    MESSAGES+=("[doc-sync] Draft skeleton changed: keep the author bio identical in references/structure.md and assets/templates/blog-template.md, and BIO_HEAD in scripts/check_structure.py.")
fi

if [[ "$FILE_PATH" == skills/*/scripts/* ]]; then
    MESSAGES+=("[doc-sync] Bundled script changed: run 'bash tests/run-all.sh scripts'; if arguments or exit codes changed, update SKILL.md and README.md in both languages.")
fi

if [[ "$FILE_PATH" == skills/*/SKILL.md ]]; then
    MESSAGES+=("[doc-sync] SKILL.md changed: keep the frontmatter name equal to the directory name, call scripts as \${CLAUDE_SKILL_DIR}/scripts/..., list every references/*.md in the table, and re-check trigger phrases against README.md Usage.")
fi

if [[ "$FILE_PATH" == .claude-plugin/*.json || "$FILE_PATH" == .mcp.json ]]; then
    MESSAGES+=("[doc-sync] Plugin manifest changed: run 'claude plugin validate .' and 'bash tests/run-all.sh structure'.")
fi

[ "${#MESSAGES[@]}" -eq 0 ] && exit 0

if $FROM_HOOK; then
    # additionalContext reaches Claude without blocking the completed tool call
    printf '%s\n' "${MESSAGES[@]}" | jq -Rs '{hookSpecificOutput: {hookEventName: "PostToolUse", additionalContext: .}}'
else
    printf '%s\n' "${MESSAGES[@]}"
fi
exit 0
