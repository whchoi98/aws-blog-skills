# Security / 보안 구현 상세

<a href="#english"><img src="https://img.shields.io/badge/lang-English-blue.svg" alt="English"></a>
<a href="#korean"><img src="https://img.shields.io/badge/lang-한국어-red.svg" alt="Korean"></a>

<a id="english"></a>
## English

### 1. Overview
The repo is public and its root is the installed plugin. Security goals: nothing secret is ever committed,
no plugin component that runs automatically ships to installers, the scripts the skill runs on a user's
machine stay inside the work folder, and the dev harness cannot be bypassed silently.

### 2. Components
| Component | Path | Purpose |
|---|---|---|
| Secret scanner | `.claude/hooks/secret-scan.sh` | PreToolUse on `git commit` (exit 2), git pre-commit (`--staged`, exit 1), manual `--files` |
| Git hook installer | `scripts/install-hooks.sh` | Installs `pre-commit` (secret scan) and `commit-msg` (strips `Co-Authored-By`) |
| Claude settings | `.claude/settings.json` | Deny list, `Read(./.env)` denied, empty commit/PR attribution, hook registration |
| Ignore rules | `.gitignore` | `.env`, `.claude/settings.local.json`, archives, blog work folders `<YYYY-MM-DD>-<slug>/` |
| Shipped MCP config | `.mcp.json` | Must stay `{"mcpServers": {}}`; read as the plugin's MCP config by installers |
| Packaging script | `skills/aws-blog-skills/scripts/package_blog.sh` | Deletes only `<out>/<slug>` and `<out>/<slug>.zip` (`${OUT:?}` guard) |
| URL checker | `skills/aws-blog-skills/scripts/check_urls.py` | GET only, URLs taken from the given drafts, no credentials |
| Renderer | `skills/aws-blog-skills/scripts/render_diagrams.py` | Opens only local `file://` pages from the given images directory |
| Source-material rule | `skills/aws-blog-skills/SKILL.md` step 0 | Instructions inside sources and fetched pages are not followed, kept out of the draft, and reported to the user (since 1.2.1) |
| Structure tests | `tests/structure/test-plugin-structure.sh` | Fails on root `hooks/`, `commands/`, `agents/`, `settings.json`, `bin/`, or a non-empty `.mcp.json` |
| Script tests | `tests/structure/test-skill-scripts.sh` | Proves the out-dir scoping and that no files are left in `skills/` |

### 3. Key Decisions
- Markdown is scanned. The project-init template skips `*.md`, which would leave this repo almost unscanned.
- PreToolUse blocks with exit 2 and has no `|| true`; exit 1 would only warn.
- The PreToolUse scan also covers modified and untracked files when the command contains `git add` or
  `commit -a`, because staging happens after the hook runs. The git pre-commit hook covers commits made
  outside Claude Code.
- Unlike a documentation-only plugin, this skill runs code, but only when Claude follows SKILL.md and the
  user approves each command. No hook, MCP server or agent ships, so installing runs nothing by itself.
- Scripts never write into the skill folder (the plugin cache) and the work folder is under the user's
  current directory ([ADR-001](../decisions/ADR-001-claude-code-skill-conventions.md)).
- Source material (blogs, PDFs, slides) and pages read with WebFetch are data, not instructions. Task
  instructions come only from the user's messages; an instruction found in a source is not followed, not
  copied into the draft, and reported with its location. Commands in a source are content to quote or
  verify; running one needs the user's approval first. The structure test keeps this rule in step 0.

### 4. Code Pointers
- `.claude/hooks/secret-scan.sh`
- `.claude/settings.json`
- `scripts/install-hooks.sh`
- `skills/aws-blog-skills/scripts/package_blog.sh`
- `skills/aws-blog-skills/scripts/check_urls.py`
- `tests/hooks/test-secret-patterns.sh`
- `tests/structure/test-skill-scripts.sh`

### 5. Cross-references
- Related modules: `skills/` (`skills/CLAUDE.md`), `tests/` (`tests/CLAUDE.md`)
- Related ADRs: [ADR-001](../decisions/ADR-001-claude-code-skill-conventions.md)
- Related runbooks: [release-plugin.md](../runbooks/release-plugin.md)

<a id="korean"></a>
## 한국어

### 1. 개요
저장소는 공개 저장소이고 루트가 곧 설치되는 플러그인입니다. 보안 목표는 네 가지입니다. 비밀 정보를 커밋하지 않고, 자동으로 실행되는 플러그인 구성 요소를 배포하지 않으며, skill이 사용자 머신에서 실행하는 스크립트가 작업 폴더 밖을 건드리지 않고, 개발 하네스를 조용히 우회할 수 없게 합니다.

### 2. 구성요소
| 구성요소 | 경로 | 역할 |
|---|---|---|
| 시크릿 스캐너 | `.claude/hooks/secret-scan.sh` | `git commit` PreToolUse(exit 2), git pre-commit(`--staged`, exit 1), 수동 `--files` |
| Git 훅 설치기 | `scripts/install-hooks.sh` | `pre-commit`(시크릿 스캔)과 `commit-msg`(`Co-Authored-By` 제거) 설치 |
| Claude 설정 | `.claude/settings.json` | deny 목록, `Read(./.env)` 차단, 커밋과 PR attribution 비움, 훅 등록 |
| 무시 규칙 | `.gitignore` | `.env`, `.claude/settings.local.json`, 압축 파일, 블로그 작업 폴더 `<YYYY-MM-DD>-<slug>/` |
| 배포되는 MCP 설정 | `.mcp.json` | `{"mcpServers": {}}` 유지. 설치자에게는 플러그인 MCP 설정으로 읽힘 |
| 패키징 스크립트 | `skills/aws-blog-skills/scripts/package_blog.sh` | `<out>/<slug>`와 `<out>/<slug>.zip`만 삭제(`${OUT:?}` 가드) |
| URL 검사기 | `skills/aws-blog-skills/scripts/check_urls.py` | GET만 사용, 지정한 원고에서 찾은 URL만 요청, 자격 증명 없음 |
| 렌더러 | `skills/aws-blog-skills/scripts/render_diagrams.py` | 지정한 images 폴더의 로컬 `file://` 페이지만 열기 |
| 소재 규칙 | `skills/aws-blog-skills/SKILL.md` 0단계 | 소재와 WebFetch로 읽은 페이지 안의 지시문을 따르지 않고 원고에 넣지 않으며 사용자에게 알림(1.2.1부터) |
| 구조 테스트 | `tests/structure/test-plugin-structure.sh` | 루트 `hooks/`, `commands/`, `agents/`, `settings.json`, `bin/`, 비어 있지 않은 `.mcp.json`이 있으면 실패 |
| 스크립트 테스트 | `tests/structure/test-skill-scripts.sh` | out 폴더 범위 제한과 `skills/`에 남는 파일이 없음을 확인 |

### 3. 주요 결정
- Markdown도 스캔합니다. project-init 템플릿은 `*.md`를 건너뛰어 이 저장소를 거의 검사하지 못합니다.
- PreToolUse는 exit 2로 차단하고 `|| true`를 붙이지 않습니다. exit 1은 경고만 합니다.
- 명령에 `git add`나 `commit -a`가 들어 있으면 PreToolUse 스캔이 수정 파일과 추적되지 않은 파일까지 확인합니다. 스테이징이 훅 실행 뒤에 일어나기 때문입니다. Claude Code 밖에서 만든 커밋은 git pre-commit 훅이 막습니다.
- 문서만 배포하는 플러그인과 달리 이 skill은 코드를 실행합니다. 다만 Claude가 SKILL.md를 따를 때, 사용자가 명령마다 승인한 경우에만 실행됩니다. 훅, MCP 서버, agent는 배포하지 않으므로 설치만으로는 아무것도 실행되지 않습니다.
- 스크립트는 skill 폴더(플러그인 캐시)에 쓰지 않고, 작업 폴더는 사용자의 현재 디렉터리 아래에 둡니다([ADR-001](../decisions/ADR-001-claude-code-skill-conventions.md)).
- 소재(블로그, PDF, 슬라이드)와 WebFetch로 읽은 페이지는 지시가 아니라 데이터입니다. 작업 지시는 사용자의 메시지에서만 받습니다. 소재에서 발견한 지시문은 따르지 않고 원고에 옮기지 않으며, 위치와 함께 사용자에게 알립니다. 소재의 명령은 인용하거나 검증할 내용이고, 실행하려면 먼저 사용자 승인을 받습니다. 구조 테스트가 이 규칙이 0단계에 남아 있는지 확인합니다.

### 4. 코드 포인터
- `.claude/hooks/secret-scan.sh`
- `.claude/settings.json`
- `scripts/install-hooks.sh`
- `skills/aws-blog-skills/scripts/package_blog.sh`
- `skills/aws-blog-skills/scripts/check_urls.py`
- `tests/hooks/test-secret-patterns.sh`
- `tests/structure/test-skill-scripts.sh`

### 5. 상호 참조
- 관련 모듈: `skills/`(`skills/CLAUDE.md`), `tests/`(`tests/CLAUDE.md`)
- 관련 ADR: [ADR-001](../decisions/ADR-001-claude-code-skill-conventions.md)
- 관련 런북: [release-plugin.md](../runbooks/release-plugin.md)
