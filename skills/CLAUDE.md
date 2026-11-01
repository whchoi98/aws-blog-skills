# Skills Module

## Role
Shipped plugin skills. Claude Code discovers `skills/<name>/SKILL.md` and registers each as
`/aws-blog-skills:<name>`. This file sits directly in `skills/`, so it is not part of any skill.

## Key Files
- `aws-blog-skills/SKILL.md` — frontmatter (`name`, `description`) is loaded in every session (~640 tokens,
  `claude plugin details`); the body loads when the skill fires (~7.4k tokens on invoke). Sections:
  reference table, 실행 환경 (Claude Code), workflow steps 0-7, 공동 저자 원고, 후속 요청 처리.
- `aws-blog-skills/references/` — read on demand per step: `structure.md` (draft skeleton, byline, author
  bio), `style.md` (banned words, notation), `humanize-checklist.md` (AI-tell checks with kor-deslop IDs),
  `verification.md` (fact and URL checks), `diagrams.md` (blog diagram profile), `exemplars.md`,
  `collaboration.md`.
- `aws-blog-skills/scripts/` — run by Claude on the user's machine: `lint_prose.py`, `check_structure.py`,
  `check_urls.py`, `package_blog.sh`, `render_diagrams.py`, `diagram_lib.py` (+ `example_diagrams.py`,
  copied into the work folder, never run in place).
- `aws-blog-skills/assets/templates/blog-template.md` — draft template.

## Rules
- Do not add `CLAUDE.md` or dev-only files inside `aws-blog-skills/`; everything there ships.
- SKILL.md targets Claude Code: call scripts as `${CLAUDE_SKILL_DIR}/scripts/...`, write only to the work
  folder `<YYYY-MM-DD>-<slug>/`, never to the skill folder (it is the plugin cache). Do not bring back
  claude.ai names (`present_files`, `/mnt/user-data`, `web_fetch`, `web_search`, `` `view` ``).
- `${CLAUDE_SKILL_DIR}` is substituted only in SKILL.md, not in references; SKILL.md says so.
- `description` is the trigger: keep the quoted request phrases ("블로그 작성", "블로그 초안", "aws-blog" and
  the rest) and the precedence sentence. Longer text raises the always-on cost for every user.
- A confirmed rule is appended to the matching reference file with `(YYYY-MM-DD 확정)`. A term added to
  `style.md` or `humanize-checklist.md` is mirrored in `scripts/lint_prose.py`.
- The author bio is identical in `references/structure.md` and `assets/templates/blog-template.md`;
  `BIO_HEAD` in `check_structure.py` is its first sentence.
- New reference files need a row in the SKILL.md reference table; `bash tests/run-all.sh structure` checks it.
- Every change here ships: bump the version and add a CHANGELOG entry (see `docs/runbooks/release-plugin.md`).
- Trigger phrases overlap with `blog-writing@synced` and the claude.ai-synced `anthropic-skills:aws-blog-skills`
  (disabled on the maintainer's machine via `skillOverrides`). When testing, call
  `/aws-blog-skills:aws-blog-skills` explicitly.
