---
name: refactor
description: Restructure the aws-blog-skills skill files (SKILL.md, references/, scripts/) or the bash harness without changing behavior, verifying with tests/run-all.sh after each step. Use when asked to reorganize, deduplicate, shorten, or split the skill, its scripts, or the harness.
---

# Refactor Skill

Improve structure without changing what the skill does or what the harness checks.

## What "behavior" means here
- **Skill**: the workflow steps 0-7, the deliverable set (md + PNG + SVG + zip), the work-folder layout,
  the confirmed rules in `references/` and their dates, and the author bio text.
  Moving text between SKILL.md and a reference file is a refactor; changing any of the above is not.
- **Scripts**: which inputs each script accepts or rejects and its exit codes
  (`lint_prose.py` and `check_structure.py` exit 1 on findings, `check_urls.py` exit 1 on FAIL/REDIRECT,
  `package_blog.sh` writes no zip on failure).
- **Harness**: which inputs each hook and test accepts or rejects.

## Process

### 1. Analysis
- Read root `CLAUDE.md` and `skills/CLAUDE.md`
- Identify the target and the tests covering it (`tests/structure/test-plugin-structure.sh`,
  `tests/structure/test-skill-scripts.sh`, `tests/hooks/*.sh`)
- Record the baseline: `bash tests/run-all.sh` and `claude plugin details aws-blog-skills@aws-blog-skills`
  (always-on and on-invoke token cost)

### 2. Plan
Present the plan to the user:
- What will change
- What will NOT change (workflow steps, deliverables, confirmed rules, script exit codes)
- Expected effect on always-on cost (the SKILL.md `description` is loaded every session)
- Risk assessment (low/medium/high)

### 3. Execute
- Small steps; after each one run `bash tests/run-all.sh` and `claude plugin validate .`
- Keep rule dates `(YYYY-MM-DD 확정)` and the `lint_prose.py` term lists in sync
- Keep commits atomic

### 4. Verify
- All tests pass
- `git diff --stat` touches only the intended files
- A skill-text refactor still ships to users, so bump the PATCH version (see `release` skill)
