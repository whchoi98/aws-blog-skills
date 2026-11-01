# Onboarding

<a href="#english"><img src="https://img.shields.io/badge/lang-English-blue.svg" alt="English"></a>
<a href="#korean"><img src="https://img.shields.io/badge/lang-한국어-red.svg" alt="Korean"></a>

---

<a id="english"></a>

# English

## Prerequisites
- git, Bash 4+, `jq`, Python 3, `zip`
- Claude Code CLI (for `claude plugin validate` and `--plugin-dir`)
- For diagrams: the `aws-diagrams` plugin, and `uv` or the `playwright` Python module with Chromium
- Fonts: Noto Sans CJK KR; Amazon Ember is copied from the aws-diagrams assets on first use

## Setup
```bash
git clone https://github.com/whchoi98/aws-blog-skills.git
cd aws-blog-skills
bash scripts/setup.sh        # checks tools, chmod hooks and scripts, installs git hooks
bash tests/run-all.sh        # all harness tests
```

## Try a working-tree change
```bash
claude --plugin-dir .        # loads this checkout as a plugin for one session
```
Inside the session, call `/aws-blog-skills:aws-blog-skills` explicitly. If you also have the installed
`aws-blog-skills@aws-blog-skills` or the claude.ai-synced `anthropic-skills:aws-blog-skills`, disable them for
the test so the right copy fires.

## Where things live
| Need | File |
|---|---|
| Workflow and Claude Code paths | `skills/aws-blog-skills/SKILL.md` |
| A writing rule | `skills/aws-blog-skills/references/style.md` (mirror it in `scripts/lint_prose.py`) |
| Draft skeleton and author bio | `skills/aws-blog-skills/references/structure.md` and `assets/templates/blog-template.md` |
| Diagram profile | `skills/aws-blog-skills/references/diagrams.md` |
| Harness rules | `CLAUDE.md`, `tests/CLAUDE.md`, `skills/CLAUDE.md` |

## First tasks
1. Read `CLAUDE.md` and [architecture.md](architecture.md)
2. Run `bash tests/run-all.sh scripts` and read `tests/structure/test-skill-scripts.sh`
3. Make a small rule change, run the tests, and follow [release-plugin.md](runbooks/release-plugin.md) to ship it

---

<a id="korean"></a>

# 한국어

## 사전 요구 사항
- git, Bash 4 이상, `jq`, Python 3, `zip`
- Claude Code CLI(`claude plugin validate`와 `--plugin-dir`용)
- 다이어그램용: `aws-diagrams` 플러그인, 그리고 `uv`나 Chromium이 설치된 `playwright` Python 모듈
- 폰트: Noto Sans CJK KR. Amazon Ember는 처음 사용할 때 aws-diagrams 자산에서 복사합니다

## 설정
```bash
git clone https://github.com/whchoi98/aws-blog-skills.git
cd aws-blog-skills
bash scripts/setup.sh        # checks tools, chmod hooks and scripts, installs git hooks
bash tests/run-all.sh        # all harness tests
```

## 작업 트리 변경 시험
```bash
claude --plugin-dir .        # loads this checkout as a plugin for one session
```
세션 안에서는 `/aws-blog-skills:aws-blog-skills`를 직접 호출합니다. 설치된 `aws-blog-skills@aws-blog-skills`나 claude.ai에서 동기화된 `anthropic-skills:aws-blog-skills`가 있으면, 원하는 사본이 실행되도록 시험하는 동안 비활성화합니다.

## 파일 위치
| 필요한 것 | 파일 |
|---|---|
| 워크플로와 Claude Code 경로 | `skills/aws-blog-skills/SKILL.md` |
| 문장 규칙 | `skills/aws-blog-skills/references/style.md`(`scripts/lint_prose.py`에도 반영) |
| 원고 골격과 저자 소개 | `skills/aws-blog-skills/references/structure.md`와 `assets/templates/blog-template.md` |
| 다이어그램 프로필 | `skills/aws-blog-skills/references/diagrams.md` |
| 하네스 규칙 | `CLAUDE.md`, `tests/CLAUDE.md`, `skills/CLAUDE.md` |

## 첫 작업
1. `CLAUDE.md`와 [architecture.md](architecture.md)를 읽습니다
2. `bash tests/run-all.sh scripts`를 실행하고 `tests/structure/test-skill-scripts.sh`를 읽습니다
3. 작은 규칙 하나를 고치고 테스트를 실행한 뒤, [release-plugin.md](runbooks/release-plugin.md)를 따라 배포합니다
