# Agent · LLM / 에이전트 · LLM 구현 상세

<a href="#english"><img src="https://img.shields.io/badge/lang-English-blue.svg" alt="English"></a>
<a href="#korean"><img src="https://img.shields.io/badge/lang-한국어-red.svg" alt="Korean"></a>

<a id="english"></a>
## English

### 1. Overview
The plugin's "model logic" is one skill: Markdown instructions Claude follows inside the user's Claude Code
session. There is no SDK call, prompt template file or model configuration. Cost is the always-on
`description` (~640 tokens) plus the SKILL.md body when the skill fires (~7.4k tokens), and each reference
file read on demand by workflow step.

### 2. Components
| Component | Path | Purpose |
|---|---|---|
| Skill entry | `skills/aws-blog-skills/SKILL.md` | Trigger `description`, reference table, Claude Code 실행 환경, workflow steps 0-7 |
| Draft skeleton | `skills/aws-blog-skills/references/structure.md` | Frontmatter, byline, captions, verified category paths, author bio |
| Writing rules | `skills/aws-blog-skills/references/style.md` | Banned words, notation, sentence length, source wording |
| AI-tell checklist | `skills/aws-blog-skills/references/humanize-checklist.md` | Patterns with kor-deslop IDs and the 윤문 guard |
| Fact checks | `skills/aws-blog-skills/references/verification.md` | URL and category checks, term layers, conflicting docs |
| Diagram profile | `skills/aws-blog-skills/references/diagrams.md` | Tool choice, tokens, type ramp, geometry rules, render pipeline |
| Tool contracts | `skills/aws-blog-skills/scripts/` | Deterministic checks the model must run instead of judging by eye |

### 3. Key Decisions
- Rules that can be checked mechanically are scripts (`lint_prose.py`, `check_structure.py`, `check_urls.py`,
  geometry asserts in `diagram_lib.py`); SKILL.md keeps only judgment and order of work.
- References load per step, so a sentence fix does not pull in the diagram profile.
- The skill defers to other skills through the Skill tool (`aws-diagrams:aws-diagram`,
  `aws-diagrams:aws-diagram-design`, `kor-writing:kor-deslop`) instead of copying their rules.
- `${CLAUDE_SKILL_DIR}` is substituted in SKILL.md only; references that show commands say so, and the model
  must use absolute paths because Bash state does not persist between calls
  ([ADR-001](../decisions/ADR-001-claude-code-skill-conventions.md)).
- Confirmed rules are appended with a date so later sessions can tell rule age from the text.

### 4. Code Pointers
- `skills/aws-blog-skills/SKILL.md`
- `skills/aws-blog-skills/references/style.md`
- `skills/aws-blog-skills/references/verification.md`
- `skills/aws-blog-skills/scripts/lint_prose.py`
- `skills/aws-blog-skills/scripts/check_urls.py`
- `skills/CLAUDE.md`

### 5. Cross-references
- Related modules: `skills/` (`skills/CLAUDE.md`)
- Related ADRs: [ADR-001](../decisions/ADR-001-claude-code-skill-conventions.md)
- Related runbooks: [release-plugin.md](../runbooks/release-plugin.md)

<a id="korean"></a>
## 한국어

### 1. 개요
이 플러그인의 "모델 로직"은 skill 하나입니다. 사용자의 Claude Code 세션 안에서 Claude가 따르는 Markdown 지침이며, SDK 호출, 프롬프트 템플릿 파일, 모델 설정은 없습니다. 비용은 항상 로드되는 `description`(약 640 토큰)과 skill이 실행될 때 읽는 SKILL.md 본문(약 7.4k 토큰), 그리고 워크플로 단계마다 필요할 때 읽는 참조 파일입니다.

### 2. 구성요소
| 구성요소 | 경로 | 역할 |
|---|---|---|
| Skill 진입점 | `skills/aws-blog-skills/SKILL.md` | 트리거 `description`, 참조 표, Claude Code 실행 환경, 워크플로 0~7단계 |
| 원고 골격 | `skills/aws-blog-skills/references/structure.md` | 프론트매터, 바이라인, 캡션, 확인된 카테고리 경로, 저자 소개 |
| 문장 규칙 | `skills/aws-blog-skills/references/style.md` | 금지어, 표기, 문장 길이, 출처 서술 |
| AI 티 점검표 | `skills/aws-blog-skills/references/humanize-checklist.md` | kor-deslop ID가 붙은 패턴과 윤문 가드 |
| 사실 검증 | `skills/aws-blog-skills/references/verification.md` | URL과 카테고리 확인, 용어 3층위, 문서 상충 |
| 다이어그램 프로필 | `skills/aws-blog-skills/references/diagrams.md` | 도구 선택, 토큰, 타입 램프, 기하 규칙, 렌더 파이프라인 |
| 도구 계약 | `skills/aws-blog-skills/scripts/` | 모델이 눈으로 판단하는 대신 실행해야 하는 결정적 검사 |

### 3. 주요 결정
- 기계적으로 확인할 수 있는 규칙은 스크립트(`lint_prose.py`, `check_structure.py`, `check_urls.py`, `diagram_lib.py`의 기하 assert)로 두고, SKILL.md에는 판단과 작업 순서만 남깁니다.
- 참조 파일은 단계마다 읽으므로 문장 교정 때 다이어그램 프로필까지 불러오지 않습니다.
- 다른 skill의 규칙을 복사하지 않고 Skill 도구로 위임합니다(`aws-diagrams:aws-diagram`, `aws-diagrams:aws-diagram-design`, `kor-writing:kor-deslop`).
- `${CLAUDE_SKILL_DIR}`는 SKILL.md에서만 치환됩니다. 명령이 적힌 참조 파일도 같은 경로로 바꿔 쓰라고 안내하며, Bash 호출 사이에 셸 상태가 남지 않으므로 모델은 절대 경로를 씁니다([ADR-001](../decisions/ADR-001-claude-code-skill-conventions.md)).
- 확정한 규칙은 날짜와 함께 덧붙여, 이후 세션이 본문만 보고도 규칙이 언제 생겼는지 알 수 있게 합니다.

### 4. 코드 포인터
- `skills/aws-blog-skills/SKILL.md`
- `skills/aws-blog-skills/references/style.md`
- `skills/aws-blog-skills/references/verification.md`
- `skills/aws-blog-skills/scripts/lint_prose.py`
- `skills/aws-blog-skills/scripts/check_urls.py`
- `skills/CLAUDE.md`

### 5. 상호 참조
- 관련 모듈: `skills/`(`skills/CLAUDE.md`)
- 관련 ADR: [ADR-001](../decisions/ADR-001-claude-code-skill-conventions.md)
- 관련 런북: [release-plugin.md](../runbooks/release-plugin.md)
