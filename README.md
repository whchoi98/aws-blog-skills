# aws-blog-skills

[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Version](https://img.shields.io/badge/Version-1.2.0-green.svg)](CHANGELOG.md)
<a href="#english"><img src="https://img.shields.io/badge/lang-English-blue.svg" alt="English"></a>
<a href="#korean"><img src="https://img.shields.io/badge/lang-한국어-red.svg" alt="Korean"></a>

A Claude Code plugin that writes Korean drafts for the AWS Korea Tech Blog from source to zip | 소재부터 zip 패키징까지 AWS Korea Tech Blog 한국어 원고를 만드는 Claude Code 플러그인

---

<a id="english"></a>

# English

## Overview

`aws-blog-skills` adds one skill to Claude Code that turns a personal blog post, an analysis PDF, slides or a
customer case into a Korean draft for the [AWS Korea Tech Blog](https://aws.amazon.com/ko/blogs/tech/). It
fixes the scope, checks every fact and URL against official AWS documentation, draws diagrams in the blog
profile (1280x720 SVG/PNG), removes AI tells, and delivers Markdown, images and a zip. Mechanical rules run as
bundled scripts with exit codes, so the result does not depend on the model's judgment alone.

## Features

- **End-to-end workflow** — Scope, fact check, structure, draft, 윤문, diagrams, structure check, packaging, rule registration (steps 0-7)
- **URL check that catches soft 404s** — `check_urls.py` requires HTTP 200 and the same final URL; docs.aws.amazon.com redirects missing pages with 200
- **Writing rules as code** — `lint_prose.py` enforces banned words, AI-tell counts and the 140-character sentence limit from `references/style.md`
- **Structure check** — `check_structure.py` validates frontmatter, byline categories, caption placement and numbering, image paths and the author bio
- **Blog-profile diagrams** — `diagram_lib.py` asserts a 4px grid and no overlaps; `render_diagrams.py` renders 2x PNGs with font and overflow gates
- **Safe packaging** — `package_blog.sh` checks the assembled bundle and writes no zip when a check fails
- **Co-author support** — Section split, comment format and paste-error checks for collaborative documents
- **Rule registration** — Rules confirmed in a session are appended to the references with a date and saved as a patch file

## Prerequisites

- [Claude Code](https://code.claude.com) with plugin support
- Python 3 and `zip`
- [aws-diagrams](https://github.com/whchoi98/aws-diagrams) plugin for AWS icons and Amazon Ember fonts
- Playwright with Chromium for PNG rendering: [uv](https://docs.astral.sh/uv/) (`uv run --with playwright`, no install) or `pip install playwright && python -m playwright install chromium`
- Noto Sans CJK KR font
- Optional: [kor-writing](https://github.com/whchoi98/kor-writing) (`kor-deslop` check mode), humanize-korean (`metrics_v2.py`)

## Installation

```bash
# Add the marketplace and install the plugin
claude plugin marketplace add whchoi98/aws-blog-skills
claude plugin install aws-blog-skills@aws-blog-skills

# Diagram dependency
claude plugin marketplace add whchoi98/aws-diagrams
claude plugin install aws-diagrams@aws-diagrams
```

### Update

```bash
# Fetch the latest catalog, then move the installed copy to the new version
claude plugin marketplace update aws-blog-skills
claude plugin update aws-blog-skills@aws-blog-skills
```

Run `/reload-plugins` in open sessions afterwards.

## Usage

Ask in Korean, for example "이 PDF를 AWS 블로그 스타일로 블로그 초안 작성해줘", or call the skill explicitly:

```text
/aws-blog-skills:aws-blog-skills
```

The skill creates a work folder under the current directory and delivers the absolute paths of the results:

```text
<YYYY-MM-DD>-<slug>/
├── drafts/<slug>.md      # draft; drafts/images -> ../images
├── diagrams/             # copied diagram_lib.py and diagrams.py
├── images/               # <slug>-figNN-<name>.{html,svg,png}
└── out/
    ├── <slug>/           # <slug>.md + images/
    └── <slug>.zip
```

Follow-up requests go to the same skill: sentence fixes ("X → Y"), changing the example setup, diagram
alignment, adding a break-even or cost chart, byline and category checks, and reference link checks.

### Trigger overlap

The claude.ai-synced `anthropic-skills:aws-blog-skills` and `blog-writing` react to the same requests. Disable
the synced copy (`"skillOverrides": {"anthropic-skills:aws-blog-skills": "off"}` in `~/.claude/settings.json`)
or call `/aws-blog-skills:aws-blog-skills` explicitly.

## Configuration

| Variable | Description | Default |
|---|---|---|
| `AWS_DIAGRAM_ASSETS` | Path to the aws-diagram-design skill `assets` folder when it is not in the plugin cache | Auto-detected from `~/.claude/plugins/cache/*/aws-diagrams/` |
| `BLOG_IMAGES` | Output folder for the diagram generator and `render_diagrams.py` | None (required) |
| `CLAUDE_NOTIFY_WEBHOOK` | Dev harness only: webhook for Claude Code notifications | Unset |

## Project Structure

```text
.claude-plugin/              # plugin.json and marketplace.json (source ./)
skills/aws-blog-skills/
├── SKILL.md                 # workflow steps 0-7, Claude Code paths, follow-ups
├── references/              # rule files read per step
│   ├── structure.md         # skeleton, byline, captions, author bio
│   ├── style.md             # banned words, notation, sentence rules
│   ├── humanize-checklist.md  # AI-tell checklist and 윤문 guard
│   ├── verification.md      # fact, URL and category checks
│   ├── diagrams.md          # blog diagram profile and tool choice
│   ├── exemplars.md         # reference posts
│   └── collaboration.md     # co-authored drafts
├── scripts/
│   ├── lint_prose.py        # banned words, AI-tell patterns, long sentences
│   ├── check_structure.py   # frontmatter, byline, captions, image paths
│   ├── check_urls.py        # HTTP 200 and same final URL for every link
│   ├── diagram_lib.py       # SVG canvas with 4px grid and overlap asserts
│   ├── example_diagrams.py  # four example figures to copy and adapt
│   ├── render_diagrams.py   # Playwright render with font and overflow gates
│   └── package_blog.sh      # assemble, check, zip
└── assets/templates/blog-template.md
.claude/                     # dev harness (hooks, project skills, agents)
docs/                        # architecture, onboarding, ADRs, runbooks, reference
tests/                       # harness tests
```

## Testing

```bash
# Hooks, secret patterns, plugin structure, and the shipped scripts' behavior
bash tests/run-all.sh

# Claude Code manifest and skill validation
claude plugin validate .
```

The script tests run on fixtures in a temporary folder and use a local HTTP server on 127.0.0.1 for the URL checker.

## Contributing

1. Fork the repository
2. Create your branch (`git checkout -b feat/new-rule`)
3. Commit changes (`git commit -m 'feat: add banned word to style.md and lint_prose.py'`)
4. Push to the branch (`git push origin feat/new-rule`)
5. Open a Pull Request

Run `bash scripts/setup.sh` once after cloning. Changes under `skills/` need a version bump in `.claude-plugin/plugin.json` and a `CHANGELOG.md` entry; see [docs/runbooks/release-plugin.md](docs/runbooks/release-plugin.md).

## License

Released under the [MIT License](LICENSE).

## Contact

- Maintainer: [WooHyung Choi (@whchoi98)](https://github.com/whchoi98)
- Issues: [github.com/whchoi98/aws-blog-skills/issues](https://github.com/whchoi98/aws-blog-skills/issues)

---

<a id="korean"></a>

# 한국어

## 개요

`aws-blog-skills`는 개인 블로그 글, 분석 PDF, 발표 자료, 고객 사례를 [AWS Korea Tech Blog](https://aws.amazon.com/ko/blogs/tech/)용 한국어 원고로 만드는 skill 하나를 Claude Code에 추가합니다. 범위를 확정하고, 모든 사실과 URL을 AWS 공식 문서로 확인하며, 블로그 프로필(1280x720 SVG/PNG)로 다이어그램을 그리고, AI 티를 걷어낸 뒤 Markdown, 이미지, zip을 전달합니다. 기계적인 규칙은 종료 코드가 있는 스크립트로 실행하므로 결과가 모델의 판단에만 기대지 않습니다.

## 주요 기능

- **처음부터 끝까지 이어지는 워크플로** — 범위 확정, 사실 검증, 구조, 초안, 윤문, 다이어그램, 구조 검사, 패키징, 규칙 등록(0~7단계)
- **soft 404까지 잡는 URL 검사** — `check_urls.py`는 HTTP 200과 같은 최종 URL을 요구합니다. docs.aws.amazon.com은 없는 페이지를 200으로 리디렉션합니다
- **코드로 강제하는 문장 규칙** — `lint_prose.py`가 `references/style.md`의 금지어, AI 티 패턴 횟수, 140자 문장 상한을 검사합니다
- **구조 검사** — `check_structure.py`가 프론트매터, 바이라인 카테고리, 캡션 위치와 번호, 이미지 경로, 저자 소개를 확인합니다
- **블로그 프로필 다이어그램** — `diagram_lib.py`가 4px 그리드와 겹침 금지를 assert로 강제하고, `render_diagrams.py`가 폰트와 오버플로 게이트를 거쳐 2배율 PNG를 만듭니다
- **안전한 패키징** — `package_blog.sh`는 조립한 번들을 검사하고, 검사가 실패하면 zip을 만들지 않습니다
- **공동 저자 지원** — 섹션 분담, 코멘트 형식, 협업 문서 붙여넣기 오류 점검
- **규칙 등록** — 세션에서 확정한 규칙을 날짜와 함께 references에 추가하고 패치 파일로 남깁니다

## 사전 요구 사항

- 플러그인을 지원하는 [Claude Code](https://code.claude.com)
- Python 3와 `zip`
- AWS 아이콘과 Amazon Ember 폰트를 제공하는 [aws-diagrams](https://github.com/whchoi98/aws-diagrams) 플러그인
- PNG 렌더용 Playwright와 Chromium: [uv](https://docs.astral.sh/uv/)(`uv run --with playwright`, 설치 불필요) 또는 `pip install playwright && python -m playwright install chromium`
- Noto Sans CJK KR 폰트
- 선택: [kor-writing](https://github.com/whchoi98/kor-writing)(`kor-deslop` 점검 모드), humanize-korean(`metrics_v2.py`)

## 설치 방법

```bash
# Add the marketplace and install the plugin
claude plugin marketplace add whchoi98/aws-blog-skills
claude plugin install aws-blog-skills@aws-blog-skills

# Diagram dependency
claude plugin marketplace add whchoi98/aws-diagrams
claude plugin install aws-diagrams@aws-diagrams
```

### 갱신

```bash
# Fetch the latest catalog, then move the installed copy to the new version
claude plugin marketplace update aws-blog-skills
claude plugin update aws-blog-skills@aws-blog-skills
```

그다음 열려 있는 세션에서 `/reload-plugins`를 실행합니다.

## 사용법

"이 PDF를 AWS 블로그 스타일로 블로그 초안 작성해줘"처럼 요청하거나 skill을 직접 호출합니다.

```text
/aws-blog-skills:aws-blog-skills
```

skill은 현재 디렉터리 아래에 작업 폴더를 만들고, 결과물의 절대 경로를 알려 줍니다.

```text
<YYYY-MM-DD>-<slug>/
├── drafts/<slug>.md      # 원고, drafts/images -> ../images
├── diagrams/             # 복사한 diagram_lib.py와 diagrams.py
├── images/               # <slug>-figNN-<name>.{html,svg,png}
└── out/
    ├── <slug>/           # <slug>.md + images/
    └── <slug>.zip
```

후속 요청도 같은 skill이 처리합니다. 문장 교정("X → Y"), 예시 구성 변경, 다이어그램 정렬, 손익분기나 비용 비교 그래프 추가, 바이라인과 카테고리 확인, 참고 자료 링크 검증이 여기에 해당합니다.

### 트리거 중복

claude.ai에서 동기화되는 `anthropic-skills:aws-blog-skills`와 `blog-writing`도 같은 요청에 반응합니다. 동기화 사본을 끄거나(`~/.claude/settings.json`의 `"skillOverrides": {"anthropic-skills:aws-blog-skills": "off"}`) `/aws-blog-skills:aws-blog-skills`를 직접 호출합니다.

## 설정

| 변수 | 설명 | 기본값 |
|---|---|---|
| `AWS_DIAGRAM_ASSETS` | 플러그인 캐시에 없을 때 지정하는 aws-diagram-design skill의 `assets` 폴더 경로 | `~/.claude/plugins/cache/*/aws-diagrams/`에서 자동 탐색 |
| `BLOG_IMAGES` | 다이어그램 생성기와 `render_diagrams.py`의 출력 폴더 | 없음(필수) |
| `CLAUDE_NOTIFY_WEBHOOK` | 개발 하네스 전용: Claude Code 알림을 받을 webhook | 설정 안 함 |

## 프로젝트 구조

```text
.claude-plugin/              # plugin.json과 marketplace.json(source ./)
skills/aws-blog-skills/
├── SKILL.md                 # 워크플로 0~7단계, Claude Code 경로, 후속 요청
├── references/              # 단계별로 읽는 규칙 파일
│   ├── structure.md         # 골격, 바이라인, 캡션, 저자 소개
│   ├── style.md             # 금지어, 표기, 문장 원칙
│   ├── humanize-checklist.md  # AI 티 점검표와 윤문 가드
│   ├── verification.md      # 사실, URL, 카테고리 검증
│   ├── diagrams.md          # 블로그 다이어그램 프로필과 도구 선택
│   ├── exemplars.md         # 참고용 모범 글
│   └── collaboration.md     # 공동 저자 원고
├── scripts/
│   ├── lint_prose.py        # 금지어, AI 티 패턴, 긴 문장
│   ├── check_structure.py   # 프론트매터, 바이라인, 캡션, 이미지 경로
│   ├── check_urls.py        # 모든 링크의 HTTP 200과 최종 URL 일치
│   ├── diagram_lib.py       # 4px 그리드와 겹침 assert가 있는 SVG 캔버스
│   ├── example_diagrams.py  # 복사해서 고쳐 쓰는 예시 그림 4장
│   ├── render_diagrams.py   # 폰트와 오버플로 게이트가 있는 Playwright 렌더
│   └── package_blog.sh      # 조립, 검사, zip
└── assets/templates/blog-template.md
.claude/                     # 개발 하네스(훅, 프로젝트 skill, agent)
docs/                        # 아키텍처, 온보딩, ADR, 런북, 구현 참조
tests/                       # 하네스 테스트
```

## 테스트

```bash
# Hooks, secret patterns, plugin structure, and the shipped scripts' behavior
bash tests/run-all.sh

# Claude Code manifest and skill validation
claude plugin validate .
```

스크립트 테스트는 임시 폴더의 픽스처로 실행하며, URL 검사기 테스트에는 127.0.0.1의 로컬 HTTP 서버를 씁니다.

## 기여 방법

1. 저장소를 Fork합니다
2. 브랜치를 만듭니다(`git checkout -b feat/new-rule`)
3. 변경 사항을 커밋합니다(`git commit -m 'feat: add banned word to style.md and lint_prose.py'`)
4. 브랜치에 push합니다(`git push origin feat/new-rule`)
5. Pull Request를 엽니다

clone한 뒤 `bash scripts/setup.sh`를 한 번 실행합니다. `skills/` 아래를 바꾸면 `.claude-plugin/plugin.json`의 버전을 올리고 `CHANGELOG.md`에 항목을 추가해야 합니다. 자세한 절차는 [docs/runbooks/release-plugin.md](docs/runbooks/release-plugin.md)에 있습니다.

## 라이선스

[MIT License](LICENSE)로 배포합니다.

## 연락처

- 관리자: [WooHyung Choi (@whchoi98)](https://github.com/whchoi98)
- 이슈: [github.com/whchoi98/aws-blog-skills/issues](https://github.com/whchoi98/aws-blog-skills/issues)
