---
name: "aws-blog-skills"
description: "AWS Korea Tech Blog(aws.amazon.com/ko/blogs/tech) 게시용 한국어 원고를 처음부터 끝까지 만드는 통합 워크플로우 — 소재(개인 블로그, PDF 분석 리포트, 발표 자료, 고객 사례) 인입 → 구조 설계 → 한국어 초안 → 공식 문서 사실 검증(URL 전수 HTTP 200) → 프로그래밍 방식 다이어그램(SVG/PNG, Amazon Ember, 1280×720 블로그 프로필) → AI 티 제거 윤문 → 확정 규칙 등록 → Markdown + 이미지 + zip 패키징. 사용자가 \"블로그 작성\", \"원고 작성\", \"AWS 블로그 스타일로\", \"테크 블로그로 정리\", \"블로그 초안\", \"이 PDF/발표자료를 블로그로\", \"AWS Korea Tech Blog\", \"aws-blog\"라고 말하면 반드시 이 스킬을 사용한다. 기존 원고의 문장 교정(\"X → Y\"), 다이어그램 수정, 손익분기·비용 비교 그래프 추가, 바이라인/카테고리 확인, 참고 자료 링크 검증 같은 후속 요청도 모두 이 스킬이 담당한다. 공동 저자 원고의 섹션 분담, 코멘트, 협업 도구 이관 점검도 이 스킬이 담당한다. 개별 blog-writing, humanize-korean, kor-deslop 스킬보다 이 스킬을 우선하고, 그림은 aws-diagrams 플러그인의 aws-diagram, aws-diagram-design skill과 내부 diagram_lib을 나눠 사용한다."
---

# AWS Blog Skills — AWS Korea Tech Blog 원고 통합 워크플로우

한 세션의 결과물은 항상 세 가지다: **Markdown 원고 + 다이어그램(PNG와 SVG) + zip 번들**. 이 셋을 `present_files`로 함께 전달하지 않으면 세션은 끝나지 않는다. 세션 중 사용자가 확정한 규칙은 이 스킬의 references에 등록하고, 패치 파일로도 전달한다(컨테이너 사본 편집은 로컬 원본에 자동 반영되지 않기 때문).

참조 파일은 필요한 단계에서 읽는다.

| 파일 | 언제 읽는가 |
|---|---|
| [references/structure.md](references/structure.md) | 초안 골격을 잡을 때. 프론트매터, 바이라인, 리드, 헤딩, 표·그림 캡션, 저자 소개 원문 |
| [references/style.md](references/style.md) | 문장을 쓰거나 고치는 모든 단계. 금지어, 용어 표기, 권고 표현, 출처 서술 |
| [references/humanize-checklist.md](references/humanize-checklist.md) | 초안 완성 직후와 최종 패키징 직전. AI 티 패턴 점검 |
| [references/verification.md](references/verification.md) | 사실 검증 단계. URL 검증 절차, 바이라인 카테고리, 문서 상충 처리 |
| [references/diagrams.md](references/diagrams.md) | 다이어그램을 만들 때. 블로그 프로필 토큰, 타입 램프, 색 규칙, 렌더 파이프라인 |
| [references/exemplars.md](references/exemplars.md) | 톤·밀도 기준이 필요할 때 |
| [references/collaboration.md](references/collaboration.md) | 공동 저자가 있을 때. 시작 합의, 코멘트 형식, 협업 도구 이관 점검 |

## 0. 소재 파악과 범위 확정

소재는 세 종류 중 하나로 들어온다: 개인 블로그 글(whchoi98.github.io), 분석 리포트 PDF(비용 분석·구성 검토), 발표 자료. 소재를 읽고 다음을 한 문장씩 확정한다.

- 핵심 주장 하나 (예: "회선 용량의 5%만 써도 정액제가 유리하다")
- 예시 구성 (회선 수, 리전, 대역폭, 기간). 사용자가 "20G 예시로", "8월 가상 청구서로"처럼 바꾸면 **본문, 표, 그림, 마치며를 한 번에 재계산**한다. 절반만 고치면 표와 그림의 숫자가 어긋난다
- 제외할 것 (사용자가 "30G 예시 제거"라고 하면 그 예시가 등장하는 표·그림·문장을 전수 삭제)
- 그림 목록 (보통 3~4장: 기존 구성 아키텍처, 구성 비교, 핸심 개념 차트, 비용 비교)

소재 PDF의 주장이 공식 문서와 다르면 공식 문서를 따르고 차이를 사용자에게 먼저 보고한다(Direct Connect 정액제의 Transit 트래픽 포함 여부처럼 문서끼리도 다를 수 있다).

## 1. 사실 검증을 먼저 한다

초안을 쓰기 전에 본문에 넣을 모든 AWS 문서 URL을 `web_fetch`로 열어 200을 확인하고 원문을 읽는다. 숫자(단가, 한도, 횟수), 제약(연결 유형, 리전, 변경 횟수), 발표일은 원문 문장 단위로 대조한다. 절차는 [references/verification.md](references/verification.md).

bash 컨테이너에는 네트워크가 없을 수 있으므로 URL 검증은 항상 `web_fetch`/`web_search` 도구로 한다. `web_fetch`는 이전 검색·fetch 결과에 나온 URL만 열 수 있다. 기억으로 만든 URL은 먼저 `web_search`로 찾는다.

바이라인 카테고리는 tech 블로그 페이지에서 실제로 확인된 경로만 쓴다. 확인되지 않은 하위 카테고리는 넣지 않는다.

기능 이름은 세 층위(발표 기능명, 문서 페이지명, API 파라미터명)를 구분하고, 본문 첫 등장에서 세 이름의 관계를 한 문장으로 잇는다. 기준은 verification.md의 용어 3층위 항목이다(2026-11-01 추가).

## 2. 골격 → 초안

[references/structure.md](references/structure.md)의 골격을 그대로 따른다. 초안은 작업 폴더 `<YYYY-MM-DD>-<slug>/drafts/<YYYY-MM-DD>-<slug>.md`에 파일로 쓴다. 채팅에만 보여주지 않는다.

레벨 200~300 독자를 위해 리드 마지막 문장에 대상 독자와 선행 지식을 적고, 각 섹션은 원리 → 영향 → 행동 순서로, 추상 규칙에는 구체 수치나 명령을 짝지어 쓴다. 계산이 들어가면 계산식을 코드 블록으로 한 번 보여주고, 표 캡션에 단위와 전제(시간 수, TB 정의, 세전)를 적는다.

계산은 Python으로 검산한 뒤 표에 옮긴다. 비율은 합계 금액으로 계산하고 월별 비율의 평균을 쓰지 않는다.

## 3. 문장 규칙과 윤문

[references/style.md](references/style.md)의 금지어·표기 규칙을 쓰는 동시에 적용한다. 초안 완성 후 `scripts/lint_prose.py`로 금지어와 AI 티 패턴을 스윕하고, [references/humanize-checklist.md](references/humanize-checklist.md)로 리듬·접속사·종결어미를 점검한다. kor-writing 플러그인이 설치되어 있으면 `/kor-writing:kor-deslop`을 "점검만" 모드로 실행해 패턴 ID별 지적을 받고, 고칠 때는 humanize-checklist.md의 윤문 가드를 지킨다. humanize-korean 플러그인의 `metrics_v2.py`가 있으면 표와 코드 블록을 제거한 본문으로 실행해 risk_band를 확인한다(참고 지표이며 격식체 블로그의 종결어미 반복은 내용 보존을 우선한다).

영어 개념어를 직역한 "계약"(contract)과 "축"(axis)은 쓰지 않고 "요구 사항", "조건", "기준", "방식"으로 풀어 쓴다(예: "런타임 계약" → "런타임 요구 사항", "두 축으로 확장" → "두 가지 방식으로 용량을 늘림"). `lint_prose.py`가 두 표현을 HARD로 잡으며, 축소, 압축, 구축, 단축, 축적은 제외한다(2026-10-24 확정).

본문에서 글의 다른 위치를 "1.3절", "3.1절", "4장"처럼 섹션 번호로 가리키지 않는다. 독자는 번호를 기억하지 못하고, 섹션을 줄이거나 순서를 바꾸면 번호 참조가 조용히 어긋나기 때문이다. 대신 가리키는 내용이 드러나는 말로 쓴다(예: "1.3절의 세션 생성 요청" → "첫 세션 예제에서 본 세션 생성 요청", "4장의 도구와 IAM" → "뒤에서 설명할 도구 제한과 IAM 권한", "3.1절의 도구 6개" → "`allowed_tools`에 등록한 도구 6개"). 위치 표현은 "앞에서 본", "뒤에서 설명할"을 쓴다("앞서"는 금지어). 그림·표 번호("그림 2", "표 5")는 캡션과 짝이 맞으므로 그대로 쓴다. 헤딩 자체의 번호("## 3.", "### 3.1")는 유지한다. 초안 완성 후와 패키징 직전에 `grep -nE '[0-9]+(\.[0-9]+)*(절|장)' <md>`로 헤딩과 캡션을 뺀 본문을 스윕하고, 개수를 세는 "슬라이드 12장" 같은 표현은 예외로 둔다(2026-10-28 확정).

사용자의 "X → Y" 교정은 정확히 적용한 뒤 같은 패턴을 문서 전체에서 스윕한다. 교정이 세 번 이상 반복되는 패턴은 style.md에 규칙으로 등록한다.

Markdown 치환은 반드시 `assert s.count(old) == 1`을 확인한 뒤 `replace`한다. 다중 매치를 조용히 바꾸면 표와 캡션이 함께 깨진다.

## 4. 다이어그램

[references/diagrams.md](references/diagrams.md)를 읽고 그림마다 도구를 고른다. AWS 서비스 아키텍처는 `/aws-diagrams:aws-diagram`, 흐름도와 시퀀스 같은 구조 다이어그램은 `/aws-diagrams:aws-diagram-design`, 손익분기 차트와 비용 막대, 블로그 고유의 구성 비교는 내부 `scripts/diagram_lib.py`로 만든다. 어느 도구를 쓰든 diagrams.md의 블로그 프로필(1280×720, 색 토큰, 타입 램프)을 적용한다. 내부 도구를 쓸 때는 `scripts/diagram_lib.py`를 복사해 생성기를 쓴다. 그림마다 `<slug>-figNN-<name>.{html,svg,png}`을 만들고 `scripts/render_diagrams.py`로 렌더한다. 렌더 로그의 `fonts: True`와 `overflow: []`를 확인하고, PNG를 `view`로 직접 본 뒤 겹침·넘침·정렬을 고친다. 자동 검증이 통과했더라도 눈으로 보지 않은 그림은 전달하지 않는다.

아이콘과 Amazon Ember 폰트는 aws-diagrams 플러그인(github.com/whchoi98/aws-diagrams)의 aws-diagram-design skill `assets/`에서 가져온다. 경로는 `python3 scripts/diagram_lib.py --assets`로 확인하고, 폰트는 `/usr/local/share/fonts/ember/`에 복사한 뒤 `fc-cache -f`를 실행한다. 경로를 찾지 못하면 aws-diagrams 플러그인 설치를 사용자에게 알린다.

## 5. 구조 검사

`scripts/check_structure.py <md>`로 프론트매터, 바이라인 형식, 표·그림 캡션 위치(항상 아래), 캡션 번호 연속성, 이미지 경로 존재, 저자 소개 원문 일치를 확인한다.

## 6. 패키징과 전달

```
<slug>/
├── <slug>.md              # 이미지 경로는 images/ 상대 경로
└── images/
    ├── <slug>-fig01-*.png / .svg
    └── ...
<slug>.zip
```

`/mnt/user-data/outputs/`에 폴더와 zip을 두고 `present_files`로 **md, PNG 전부, SVG 전부, zip**을 한 번에 제시한다. 사용자가 "MD와 이미지 모두 제시"라고 하면 같은 목록을 다시 제시한다. 수정 후에는 바뀐 파일만이 아니라 zip도 다시 만든다.

## 7. 규칙 등록

세션에서 확정된 규칙을 references의 해당 파일 끝에 "(YYYY-MM-DD 확정)" 표시와 함께 추가하고, 추가한 블록만 모은 `skill-rule-updates-<날짜>.md`를 outputs에 함께 전달한다. 사용자가 "스킬 업데이트 되었나요"라고 물으면 컨테이너 사본과 로컬 원본의 차이를 설명하고 패치 파일을 다시 제시한다.

## 공동 저자 원고

공동 저자가 있으면 0단계에서 [references/collaboration.md](references/collaboration.md)의 합의 항목(섹션 분담, 헤딩 깊이, 코드 스타일, 용어 병기, 바이라인 순서)을 먼저 확정한다. 상대 섹션은 직접 고치지 않고 원문 인용, 수정안, 한 줄 근거로 된 코멘트로 전달한다. 원고를 협업 문서 도구로 옮긴 뒤에는 붙여넣기 오류 여섯 가지를 전수 점검하고, 합친 원고로 구조 검사와 lint를 다시 실행한다.

## 후속 요청 처리

- **예시 구성 변경**("20G로", "8월 청구서 기준으로"): 0단계로 돌아가 계산을 다시 하고, 본문·표·그림·마치며·말미 고지를 한 턴에 모두 갱신한다
- **문장 삭제/교정**: 적용 → 전수 스윕 → 관련 문장(예: 리드 질문을 지우면 마치며의 "글머리 질문" 언급도 수정) → md와 zip 갱신 → 제시
- **섹션 축소·재구성**: 섹션을 빼거나 순서를 바꾼 뒤에는 본문의 섹션 번호 참조("○절", "○장")가 남지 않았는지 스윕하고, 그림·표 번호와 파일명을 다시 맞춘다
- **그림 정렬**("하단 박스 수평 정렬"): 같은 흐름의 노드는 하단 변을 맞추고 화살표가 세로 중심선을 지나게 좌표를 바꾼 뒤, 밀려난 주석 위치와 sublabel 폭까지 확인
- **공식 문서 확인 요청**: 이미 fetch한 원문에서 해당 문장을 찾아 절 이름과 함께 답하고, 두 문서가 다르면 둘 다 인용한다