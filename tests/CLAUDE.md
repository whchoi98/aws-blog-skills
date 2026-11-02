# Tests Module

## Role
Harness tests for the dev hooks, for invariants of the shipped plugin, and for the behavior of the
scripts the skill ships. Bash + `jq` + Python 3; no model calls. The only network use is a local HTTP
server on 127.0.0.1 for the URL checker. Run with `bash tests/run-all.sh [filter]`.

## Key Files
- `run-all.sh` — runner. Defines `pass`/`fail`/`skip` and `assert_*`, `cd`s to the repo root, exports
  `CLAUDE_PROJECT_DIR` and a scratch dir `$TEST_TMP`, then **sources** every `tests/**/test-*.sh`.
  Uses `set -uo pipefail` without `-e`, so a `grep` that finds nothing cannot abort the run.
- `hooks/test-hooks.sh` — hook files, settings registration, stdin-JSON behavior, exit codes
  (PreToolUse exit 2, `--staged` exit 1), commit-msg trailer removal, all in throwaway git repos.
- `hooks/test-secret-patterns.sh` — true/false positives against the real scanner, skip and
  forbidden-path rules, PCRE compile regression.
- `structure/test-plugin-structure.sh` — manifests, version sync (plugin.json, README badge, CHANGELOG),
  SKILL.md frontmatter and Claude Code conventions (`${CLAUDE_SKILL_DIR}`, no claude.ai-only names),
  the step 0 rule that instructions inside source material are not followed, reference table
  completeness, author bio sync, draft skeletons free of banned notation (`blog-template.md` passes
  `lint_prose.py`, no `·` in the `structure.md` skeleton), no root plugin components, `.mcp.json` empty, docs and
  bilingual anchors, reference Code Pointers, and `claude plugin validate .` (skipped without the CLI).
- `structure/test-skill-scripts.sh` — runs the shipped scripts on fixture drafts in `$TEST_TMP`:
  `lint_prose.py` and `check_structure.py` exit codes, `package_blog.sh` bundle and no-zip-on-failure,
  `check_urls.py` OK/FAIL/REDIRECT against a local server, `render_diagrams.py` argument guard, and the
  diagram generator (skipped when the aws-diagrams plugin assets are absent).
- `fixtures/secret-samples.txt` — TAB-separated `name / prefix / body`; joined at runtime so no full
  token is stored. `fixtures/false-positives.txt` — one non-secret per line.

## Rules
- Test files are sourced, not executed: do not `exit`, do not `set -e`, guard commands that may return
  non-zero (`|| true`, or capture `$?`).
- Sourcing shares the runner's scope. Never assign `TOTAL`, `PASSED`, `FAILED`, `SKIPPED`, `FAILURES`,
  `FILTER`, `TEST_TMP`, `PROJECT_ROOT` or `SCRIPT_DIR`; a structure test rejects it. Prefix test-local
  names, e.g. `SCR_OUT`.
- Never write a complete secret literal anywhere; split it into prefix and body.
- Use `$TEST_TMP` for scratch files and repos; it is removed on exit. Never write into `skills/`.
- A background process (the local HTTP server) must be killed in the same test file.
- A new invariant needs a test that fails when the invariant is broken. Prove it once by breaking the
  file (mutation) and watching the test go red.
