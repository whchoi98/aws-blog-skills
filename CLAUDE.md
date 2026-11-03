# Project Context

## Overview
`aws-blog-skills` 1.2.2 is a Claude Code plugin for writing Korean drafts for the AWS Korea Tech Blog
(aws.amazon.com/ko/blogs/tech). Its only skill, `aws-blog-skills`, runs the whole workflow: source intake,
structure, Korean draft, official-doc fact check, blog-profile diagrams (SVG/PNG, 1280x720), AI-tell removal,
rule registration, and Markdown + images + zip packaging. It ships Python and Bash scripts that Claude runs
on the user's machine (lint, structure check, URL check, packaging, diagram generation and rendering).

The repo root **is** the shipped plugin and its marketplace (`.claude-plugin/marketplace.json`,
`"source": "./"`). Public repo `github.com/whchoi98/aws-blog-skills`, MIT; users install it as
`aws-blog-skills@aws-blog-skills` and invoke `/aws-blog-skills:aws-blog-skills`. Diagrams depend on the
`aws-diagrams` plugin (icons, Amazon Ember fonts); `kor-writing` (kor-deslop) is optional.

## Tech Stack
- **Content** — Markdown skill (`skills/aws-blog-skills/SKILL.md`, 한다체) with on-demand references
  (`references/*.md`) and a draft template (`assets/templates/blog-template.md`)
- **Shipped scripts** — Python 3 standard library (`lint_prose.py`, `check_structure.py`, `check_urls.py`,
  `diagram_lib.py`, `example_diagrams.py`), Playwright for Python (`render_diagrams.py`, run via
  `uv run --no-project --with playwright`), Bash + `zip` (`package_blog.sh`)
- **Packaging** — Claude Code plugin manifests (`.claude-plugin/plugin.json`, `marketplace.json`), JSON
- **Harness** — Bash 5 hooks and tests, `jq` 1.7, Python 3
- **Tooling** — Claude Code CLI (`claude plugin validate|details|marketplace|update`), git, GitHub

## Project Structure
```
.claude-plugin/   - plugin.json (name, version, license) + marketplace.json (source ./) [ships, loaded]
skills/           - Shipped skills; module doc skills/CLAUDE.md                        [ships, loaded]
  aws-blog-skills/  - SKILL.md, references/ (7 rule files), scripts/ (6), assets/templates/
LICENSE, README.md, CHANGELOG.md                                                       [ships, inert]
.mcp.json         - Must stay empty: it is also the plugin's MCP config                [ships, loaded]
.claude/          - Dev harness: settings, hooks, project skills, commands, agents     [ships, inert]
docs/             - architecture, onboarding, ADRs, runbooks, reference/               [ships, inert]
scripts/          - setup.sh, install-hooks.sh (git commit-msg + pre-commit)
tests/            - run-all.sh, hooks/, structure/, fixtures/; module doc tests/CLAUDE.md
```
"Ships" means it is copied into every installer's plugin cache. "Loaded" means Claude Code reads it as
a plugin component there. Everything under `.claude/` is only active when this repo is the working directory.

## Conventions
- **Never add plugin component paths at the root**: `hooks/`, `commands/`, `agents/`, `settings.json`,
  `bin/`, or entries in `.mcp.json`. They would run for every user. Dev-only tooling goes under `.claude/`.
  `tests/structure` enforces this.
- **Any change under `skills/` is a release**: installed copies update only when
  `.claude-plugin/plugin.json` `version` changes. Bump it, update the README badge and add a bilingual
  CHANGELOG entry (`docs/runbooks/release-plugin.md`). Users then need both
  `claude plugin marketplace update aws-blog-skills` and `claude plugin update aws-blog-skills@aws-blog-skills`.
- **SKILL.md targets Claude Code**: bundled scripts are called as `${CLAUDE_SKILL_DIR}/scripts/...`
  (substituted in SKILL.md only, not in references); outputs go to the work folder `<YYYY-MM-DD>-<slug>/`
  (`drafts`, `diagrams`, `images`, `out`, with `drafts/images -> ../images`); nothing is written into the
  skill folder, which is the plugin cache. claude.ai names (`present_files`, `/mnt/user-data`, `web_fetch`,
  `web_search`, `` `view` ``) must not come back; tests reject them.
- **Rules live in references**: a confirmed rule is appended to the matching reference file with
  `(YYYY-MM-DD 확정)`. A term added to `style.md` or `humanize-checklist.md` is mirrored in
  `scripts/lint_prose.py` (`HARD`, `HARD_RE`, `COUNT`). Every reference file has a row in the SKILL.md table.
- **Author bio is verbatim**: identical in `references/structure.md` and `assets/templates/blog-template.md`;
  `BIO_HEAD` in `scripts/check_structure.py` is its first sentence.
- **Script contracts**: `lint_prose.py`, `check_structure.py`, `check_urls.py` exit 1 on findings;
  `check_urls.py` treats a redirect to a different page as failure (docs.aws.amazon.com answers missing pages
  with a redirect and 200); `package_blog.sh <workdir> <slug> [outdir]` checks the assembled bundle and
  writes no zip on failure. Changing a contract means changing SKILL.md, README and tests together.
- **Skill text style**: SKILL.md and references are 한다체, terse, imperative. Keep the `description`
  trigger phrases ("블로그 작성", "블로그 초안", "aws-blog" and the rest) and the precedence sentence.
- **Module docs**: never put `CLAUDE.md` inside `skills/<name>/`; that directory ships as the skill.
- **Docs**: user-facing docs are bilingual (English first, `<a id="english">` / `<a id="korean">`),
  Korean sections in 합니다체, no emojis, Mermaid for diagrams.
- **Commits**: Conventional Commits (`feat:`, `fix:`, `docs:`, `chore:`). No `Co-Authored-By`
  (settings `attribution` is empty and the `commit-msg` hook strips it).

## Key Commands
```bash
bash scripts/setup.sh                     # check tools, chmod hooks and scripts, install git hooks
bash tests/run-all.sh                     # all harness tests (hooks, secret patterns, structure, scripts)
bash tests/run-all.sh structure           # structure and shipped-script tests
bash tests/run-all.sh scripts             # only the shipped scripts' behavior
claude plugin validate .                  # manifest + skill validation (ICON_MISSING warning is expected)
claude plugin details aws-blog-skills@aws-blog-skills   # components and always-on / on-invoke token cost
claude --plugin-dir .                     # session with this working tree loaded as a plugin
claude plugin marketplace update aws-blog-skills && claude plugin update aws-blog-skills@aws-blog-skills
```
Run a shipped script against a draft the way the skill does:
```bash
python3 skills/aws-blog-skills/scripts/lint_prose.py <workdir>/drafts/<slug>.md
python3 skills/aws-blog-skills/scripts/check_urls.py <workdir>/drafts/<slug>.md
bash skills/aws-blog-skills/scripts/package_blog.sh <workdir> <slug>
```

## Implementation References
<!-- AUTO-MANAGED:references -->
Layer-by-layer implementation guides in `docs/reference/`. See [INDEX](docs/reference/INDEX.md).
- [Security](docs/reference/security.md)
- [Agent · LLM](docs/reference/agent-llm.md)
<!-- /AUTO-MANAGED -->

---

## Auto-Sync Rules

Rules below are applied automatically after Plan mode exit and on major changes.

### Post-Plan Mode Actions
After exiting Plan mode (`/plan`), before starting implementation:

1. **Architecture decision made** -> Update `docs/architecture.md`
2. **Technical choice/trade-off made** -> Create `docs/decisions/ADR-NNN-title.md`
3. **New module added** -> Create `CLAUDE.md` in that module directory (not inside `skills/<name>/`)
4. **Operational procedure defined** -> Create runbook in `docs/runbooks/`
5. **Changes needed in this file** -> Update relevant sections above

### Change Sync Rules
- New skill under `skills/` -> Update `skills/CLAUDE.md`, README (both languages), `docs/reference/agent-llm.md`
- New reference file -> Add a row to the SKILL.md reference table and to `skills/CLAUDE.md`
- New or changed script -> Update SKILL.md, README script list (both languages), `tests/structure/test-skill-scripts.sh`
- Rule added to `style.md` / `humanize-checklist.md` -> Mirror it in `scripts/lint_prose.py`
- Anything under `skills/` changed -> Version bump + CHANGELOG `[Unreleased]` (both languages)
- Harness changed (`.claude/`, `tests/`, `scripts/`) -> Update `tests/CLAUDE.md` and `docs/reference/security.md`

### ADR Numbering
Find the highest number in `docs/decisions/ADR-*.md` and increment by 1.
Format: `ADR-NNN-concise-title.md`
