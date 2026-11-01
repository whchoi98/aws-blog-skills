# aws-blog-skills

[AWS Korea Tech Blog](https://aws.amazon.com/ko/blogs/tech/)에 게시할 한국어 원고를 처음부터 끝까지 만드는 Claude Code 플러그인입니다.

| skill | 하는 일 |
|---|---|
| `aws-blog-skills` | 소재(개인 블로그, PDF 분석 리포트, 발표 자료, 고객 사례) 인입, 구조 설계, 한국어 초안, 공식 문서 사실 검증(URL 전수 HTTP 200), 블로그 프로필 다이어그램(1280×720 SVG/PNG), AI 티 제거 윤문, 공동 저자 협업, 확정 규칙 등록, Markdown + 이미지 + zip 패키징 |

"블로그 작성", "블로그 초안", "AWS 블로그 스타일로", "이 PDF를 블로그로" 같은 요청에서 자동으로 실행됩니다. 기존 원고의 문장 교정, 다이어그램 수정, 참고 자료 링크 검증 같은 후속 요청도 같은 skill이 처리합니다.

## 설치

```bash
claude plugin marketplace add whchoi98/aws-blog-skills
claude plugin install aws-blog-skills@aws-blog-skills
```

skill 호출 이름은 `/aws-blog-skills:aws-blog-skills`입니다.

## 구성

```
skills/aws-blog-skills/
├── SKILL.md                     # 워크플로우 0~7단계, 후속 요청 처리
├── references/                  # 단계별로 읽는 규칙 파일
│   ├── structure.md             # 골격, 바이라인, 캡션, 저자 소개
│   ├── style.md                 # 금지어, 용어 표기, 문장 원칙
│   ├── humanize-checklist.md    # AI 티 점검표, 윤문 가드
│   ├── verification.md          # 사실 검증, 카테고리 검증, 문서 상충
│   ├── diagrams.md              # 블로그 다이어그램 프로필, 도구 선택
│   ├── exemplars.md             # 참고용 모범 글
│   └── collaboration.md         # 공동 저자 원고
├── scripts/
│   ├── lint_prose.py            # 금지어, AI 티 패턴, 140자 초과 문장 스윕
│   ├── check_structure.py       # 프론트매터, 바이라인, 캡션, 이미지 경로 검사
│   ├── check_urls.py            # 원고 URL 전수 확인(HTTP 200, 다른 페이지로 리디렉션 여부)
│   ├── diagram_lib.py           # SVG Canvas 라이브러리(4px 그리드, 겹침 assert)
│   ├── example_diagrams.py      # 그림 생성 예시(아키텍처, 구성 비교, 손익분기, 막대)
│   ├── render_diagrams.py       # Playwright 렌더(폰트, 오버플로 게이트)
│   └── package_blog.sh          # 번들 조립 → 구조 검사, lint → zip
└── assets/templates/blog-template.md
```

## 함께 쓰는 플러그인

| 플러그인 | 필수 여부 | 용도 |
|---|---|---|
| [aws-diagrams](https://github.com/whchoi98/aws-diagrams) | 필수(다이어그램) | `aws-diagram`, `aws-diagram-design` skill과 AWS 아이콘, Amazon Ember 폰트. `diagram_lib.py`가 플러그인 캐시에서 자산 경로를 찾습니다 |
| [kor-writing](https://github.com/whchoi98/kor-writing) | 선택 | `kor-deslop` 점검 모드로 패턴 ID별 AI 티 지적 |
| humanize-korean | 선택 | `metrics_v2.py`로 risk_band 참고 지표 |

```bash
claude plugin marketplace add whchoi98/aws-diagrams
claude plugin install aws-diagrams@aws-diagrams
```

자산 경로를 직접 지정하려면 `AWS_DIAGRAM_ASSETS` 환경 변수에 aws-diagram-design skill의 `assets` 폴더를 넣습니다. 현재 경로는 `python3 skills/aws-blog-skills/scripts/diagram_lib.py --assets`로 확인합니다.

## 실행 환경 요구사항

| 도구 | 쓰는 곳 | 용도 |
|---|---|---|
| Python 3 | 모든 스크립트 | lint, 구조 검사, URL 확인, 다이어그램 생성 |
| Playwright(Chromium) | `render_diagrams.py` | HTML을 2배율 PNG로 렌더. [uv](https://docs.astral.sh/uv/)가 있으면 설치 없이 `uv run --no-project --with playwright`로 실행 |
| Noto Sans CJK KR | 다이어그램 | 한글 폴백 폰트 |
| zip | `package_blog.sh` | 원고 번들 |

## 실행 환경

SKILL.md는 Claude Code 기준입니다(1.2.0부터).

- skill 스크립트는 `${CLAUDE_SKILL_DIR}`로 부르고, 원고와 그림은 현재 프로젝트 아래 작업 폴더 `<YYYY-MM-DD>-<slug>/`(drafts, diagrams, images, out)에 만듭니다. 설치된 skill 폴더는 플러그인 캐시라서 아무것도 쓰지 않습니다
- 결과물은 `<작업 폴더>/out/`에 만들어지고, 마지막 응답에 md, PNG, SVG, zip의 절대 경로가 나열됩니다
- URL 확인은 `check_urls.py`, 원문 읽기는 WebFetch, 그림 확인은 Read 도구를 씁니다
- Amazon Ember 폰트는 사용자 폰트 폴더(Linux `~/.local/share/fonts/ember/`, macOS `~/Library/Fonts/`)에 설치합니다

claude.ai에서 쓰던 1.1.0 이전 SKILL.md는 `present_files`, `/mnt/user-data/outputs/`, `web_fetch` 기준이었습니다.

## 갱신

수정 후 `.claude-plugin/plugin.json`의 `version`을 올리고 push합니다. 설치된 쪽은 `claude plugin marketplace update aws-blog-skills` 후 `/reload-plugins`로 반영합니다.
