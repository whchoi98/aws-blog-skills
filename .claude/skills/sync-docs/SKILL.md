---
name: sync-docs
description: Synchronize aws-blog-skills documentation (root and module CLAUDE.md, docs/architecture.md, docs/reference/, runbooks, README, CHANGELOG) with the current skill files, scripts and manifests, and score CLAUDE.md quality. Use after changing skills/ or the harness, or when asked to update or audit docs.
---

# Sync Docs Skill

Synchronize project documentation with the current repository state.

## Actions

### 1. Quality Assessment
Score each CLAUDE.md file (0-100) across:
- Commands/workflows (20 pts)
- Architecture clarity (20 pts)
- Non-obvious patterns (15 pts)
- Conciseness (15 pts)
- Currency (15 pts)
- Actionability (15 pts)

Apply anti-pattern deductions:
- Over 500 lines (-15)
- Vague instructions (-10)
- Duplicated docs (-10)
- No test guidance (-10)
- Contains secrets (-20)

Output a quality report with grades (A-F) before making changes.

### 2. Root CLAUDE.md Sync
- Update Overview, Tech Stack, Conventions, Key Commands
- Keep inventories current: reference files under `skills/aws-blog-skills/references/`, scripts under
  `skills/aws-blog-skills/scripts/`, skills under `skills/*/SKILL.md`
- Verify commands are copy-paste ready

### 3. Architecture Doc Sync
- Update `docs/architecture.md` (English and Korean sections identically)
- Keep the Packaging table accurate: which files ship, which are loaded, which are inert
- Keep the workflow diagram in step with SKILL.md steps 0-7

### 4. Module CLAUDE.md Audit
- Source roots: `skills/ tests/`
- Module docs live at `skills/CLAUDE.md` and `tests/CLAUDE.md`; never add one inside `skills/<name>/`
  (that directory ships as the skill)
- Score each module CLAUDE.md

### 5. Reference, ADR and Runbook Audit
- Check every Code Pointer path (and line range) in `docs/reference/*.md` exists; refresh
  `docs/reference/INDEX.md` and the root `<!-- AUTO-MANAGED:references -->` block
- Check recent commits for undocumented decisions (`docs/decisions/ADR-*.md`)
- Verify `docs/runbooks/release-plugin.md` matches the README update commands

### 6. README.md and CHANGELOG.md Sync
- Project structure, script list, install id and version badge in both language sections
- CHANGELOG `[Unreleased]` covers every user-facing change since the last tag

### 7. Report
Output before/after quality scores, anti-patterns detected, and the list of changes.
Finish with `bash tests/run-all.sh`.
