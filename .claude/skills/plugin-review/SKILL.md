---
name: plugin-review
description: Review changes to the aws-blog-skills plugin (skills/aws-blog-skills SKILL.md, references, scripts, .claude-plugin manifests, README) with confidence-based scoring, reporting only issues >= 75. Use when asked to review a diff or changes before commit or release. Named plugin-review so it does not shadow the built-in /code-review.
---

# Plugin Review Skill

Review changed files with confidence-based scoring to filter false positives.

## Review Scope

By default, review unstaged changes from `git diff`, then staged changes from `git diff --cached`.
The user may specify different files or a git ref.

## Review Criteria

### Shipped-Content Invariants (highest priority)
Everything in the repo root ships to users (`marketplace.json` has `"source": "./"`).
- `skills/aws-blog-skills/SKILL.md` frontmatter `name` equals the directory name; `description` keeps its
  trigger phrases ("블로그 작성", "블로그 초안", "aws-blog") and its precedence over blog-writing,
  humanize-korean and kor-deslop
- Claude Code conventions hold: bundled scripts are called as `${CLAUDE_SKILL_DIR}/scripts/...`; nothing is
  written into the skill folder (it is the plugin cache); no claude.ai-only names come back
  (`present_files`, `/mnt/user-data`, `web_fetch`, `web_search`, `` `view` ``)
- Every `references/*.md` file is listed in the SKILL.md reference table, and every script SKILL.md names exists
- Rule sync: a term added to or removed from `references/style.md` or `humanize-checklist.md` is mirrored in
  `scripts/lint_prose.py` (`HARD`, `HARD_RE`, `COUNT`); confirmed rules carry `(YYYY-MM-DD 확정)`
- The author bio is identical in `references/structure.md` and `assets/templates/blog-template.md`, and its first
  sentence matches `BIO_HEAD` in `scripts/check_structure.py`
- Script behavior: `package_blog.sh` checks the assembled bundle and writes no zip on failure;
  `check_urls.py` treats a redirect to a different page as a failure; `render_diagrams.py` refuses to run
  without an images directory
- No new executable component at the root: `hooks/`, `commands/`, `agents/`, `settings.json`; `.mcp.json` stays empty

### Release Hygiene
- Any change under `skills/` comes with a `plugin.json` version bump and a CHANGELOG `[Unreleased]` entry in both languages
- README version badge equals `plugin.json` version

### Korean Writing Quality
- New rules follow the skill's own style rules (no 가운데점, no em/en dash in prose, 140자 sentence limit)
- Prescriptions are concrete (before/after example or command), not vague
- New rules do not contradict another rule in `style.md`, `humanize-checklist.md` or `structure.md`

### Harness
- Hooks read event JSON from stdin; PreToolUse blocks with exit 2; no `|| true` on PreToolUse
- Tests are not vacuous (a broken invariant must fail `bash tests/run-all.sh`)

## Confidence Scoring

Rate each issue 0-100:
- **0-24**: Likely false positive or pre-existing issue. Do not report.
- **25-49**: Might be real but possibly a nitpick. Do not report.
- **50-74**: Real issue but minor. Report only if critical.
- **75-89**: Verified real issue, important. Report with fix suggestion.
- **90-100**: Confirmed critical issue. Must report.

**Only report issues with confidence >= 75.**

## Output Format

For each issue:
### [CRITICAL|IMPORTANT] <issue title> (confidence: XX)
**File:** `path/to/file.ext:line`
**Issue:** Clear description of the problem
**Guideline:** Reference to CLAUDE.md rule or the invariant above
**Fix:** Concrete suggestion

If no high-confidence issues are found, confirm the change meets standards with a brief summary.
