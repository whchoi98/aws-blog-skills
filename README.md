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
│   ├── diagram_lib.py           # SVG Canvas 라이브러리(4px 그리드, 겹침 assert)
│   ├── example_diagrams.py      # 그림 생성 예시(아키텍처, 구성 비교, 손익분기, 막대)
│   ├── render_diagrams.py       # Playwright 렌더(폰트, 오버플로 게이트)
│   └── package_blog.sh          # 검사 후 zip 패키징
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
| Python 3 | 모든 스크립트 | lint, 구조 검사, 다이어그램 생성 |
| Playwright(Chromium) | `render_diagrams.py` | HTML을 2배율 PNG로 렌더 |
| Noto Sans CJK KR | 다이어그램 | 한글 폴백 폰트 |
| zip | `package_blog.sh` | 원고 번들 |

## 실행 환경에 따른 차이

SKILL.md는 claude.ai 컨테이너를 기준으로 작성되어 `present_files`, `/mnt/user-data/outputs/`, `web_fetch`, `view` 같은 도구 이름과 경로를 사용합니다. Claude Code에서는 각각 작업 폴더의 출력 경로, WebFetch, Read(이미지 보기)로 대응해 실행합니다. `package_blog.sh`는 출력 경로를 `/mnt/user-data/outputs`로 고정하고 있으므로 Claude Code에서는 스크립트의 `OUT` 값을 바꾸거나 같은 단계를 직접 실행합니다.

## 갱신

수정 후 `.claude-plugin/plugin.json`의 `version`을 올리고 push합니다. 설치된 쪽은 `claude plugin marketplace update aws-blog-skills` 후 `/reload-plugins`로 반영합니다.
