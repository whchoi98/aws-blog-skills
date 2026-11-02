# Changelog

<a href="#english"><img src="https://img.shields.io/badge/lang-English-blue.svg" alt="English"></a>
<a href="#korean"><img src="https://img.shields.io/badge/lang-한국어-red.svg" alt="Korean"></a>

---

<a id="english"></a>

# English

All notable changes to this project will be documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.2.1] - 2026-11-02

### Added
- Add the MIT `LICENSE` file and declare `license` in `plugin.json`

### Changed
- Rewrite the README in English and Korean with configuration, work-folder layout, and update steps

### Fixed
- Remove the banned middle dot (·) from the table caption placeholder in `blog-template.md` and the disclaimer placeholder in the `structure.md` skeleton, so drafts no longer inherit it

### Security
- Treat source material and pages read with WebFetch as data in SKILL.md step 0: instructions inside them are not followed or copied into the draft, and are reported to the user; commands in a source are run only after the user approves

## [1.2.0] - 2026-11-01

### Added
- Add `check_urls.py`, which fails a link that is not HTTP 200 or that redirects to a different page

### Changed
- Target Claude Code in SKILL.md: call scripts as `${CLAUDE_SKILL_DIR}/scripts/...`, write to the work folder `<YYYY-MM-DD>-<slug>/`, and list absolute result paths instead of `present_files`
- Package into `<workdir>/out` by default; `package_blog.sh` takes an optional output folder as its third argument
- Read docs with WebFetch and WebSearch, view diagrams with the Read tool, and call companion skills through the Skill tool
- Render diagrams with `uv run --no-project --with playwright` and install Amazon Ember into the user font folder only when missing
- Register confirmed rules in a patch file and the repository clone instead of the installed copy

### Fixed
- Fix `package_blog.sh` failing every run because the structure check looked for images under `drafts/images/`; it now checks the assembled bundle and writes no zip on failure
- Fix `render_diagrams.py` writing into the skill folder when no images folder is given

## [1.1.0] - 2026-11-01

### Added
- Add the `aws-blog-skills` skill as a single-repo Claude Code marketplace and plugin
- Add `references/collaboration.md` for co-authored drafts
- Add the aws-diagrams plugin integration for icons and fonts, and the optional kor-deslop check mode

[Unreleased]: https://github.com/whchoi98/aws-blog-skills/compare/v1.2.1...HEAD
[1.2.1]: https://github.com/whchoi98/aws-blog-skills/compare/v1.2.0...v1.2.1
[1.2.0]: https://github.com/whchoi98/aws-blog-skills/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/whchoi98/aws-blog-skills/releases/tag/v1.1.0

---

<a id="korean"></a>

# 한국어

이 프로젝트의 모든 주요 변경 사항은 이 파일에 기록됩니다.
이 문서는 [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)를 기반으로 하며,
[Semantic Versioning](https://semver.org/spec/v2.0.0.html)을 따릅니다.

## [Unreleased]

## [1.2.1] - 2026-11-02

### Added
- MIT `LICENSE` 파일 추가와 `plugin.json`의 `license` 선언

### Changed
- 설정, 작업 폴더 구조, 갱신 절차를 담은 영어와 한국어 README로 재작성

### Fixed
- 원고가 금지 가운뎃점(·)을 물려받지 않도록 `blog-template.md`의 표 캡션 placeholder와 `structure.md` 골격의 고지 문장 placeholder에서 가운뎃점 제거

### Security
- SKILL.md 0단계에 소재와 WebFetch로 읽은 페이지를 데이터로만 다루는 규칙 추가. 그 안의 지시문은 따르거나 원고에 옮기지 않고 사용자에게 알리며, 소재의 명령은 사용자 승인 후에만 실행

## [1.2.0] - 2026-11-01

### Added
- HTTP 200이 아니거나 다른 페이지로 리디렉션되는 링크를 실패로 처리하는 `check_urls.py` 추가

### Changed
- SKILL.md의 대상을 Claude Code로 변경. 스크립트는 `${CLAUDE_SKILL_DIR}/scripts/...`로 호출, 결과는 작업 폴더 `<YYYY-MM-DD>-<slug>/`에 저장, `present_files` 대신 결과 절대 경로 나열
- 기본 패키징 위치를 `<workdir>/out`으로 변경, `package_blog.sh`의 세 번째 인자로 출력 폴더 지정 가능
- 문서 읽기는 WebFetch와 WebSearch, 그림 확인은 Read 도구, 함께 쓰는 skill 호출은 Skill 도구로 변경
- 다이어그램 렌더를 `uv run --no-project --with playwright`로 실행하고, Amazon Ember는 없을 때만 사용자 폰트 폴더에 설치
- 확정 규칙을 설치본 대신 패치 파일과 저장소 클론에 등록

### Fixed
- 구조 검사가 `drafts/images/`에서 그림을 찾아 `package_blog.sh`가 매번 실패하던 문제 수정. 조립한 번들을 검사하고 실패하면 zip을 만들지 않음
- images 폴더를 주지 않으면 `render_diagrams.py`가 skill 폴더에 쓰던 문제 수정

## [1.1.0] - 2026-11-01

### Added
- 저장소 하나로 된 Claude Code 마켓플레이스 겸 플러그인으로 `aws-blog-skills` skill 추가
- 공동 저자 원고용 `references/collaboration.md` 추가
- 아이콘과 폰트를 위한 aws-diagrams 플러그인 연동과 선택적인 kor-deslop 점검 모드 추가

[Unreleased]: https://github.com/whchoi98/aws-blog-skills/compare/v1.2.1...HEAD
[1.2.1]: https://github.com/whchoi98/aws-blog-skills/compare/v1.2.0...v1.2.1
[1.2.0]: https://github.com/whchoi98/aws-blog-skills/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/whchoi98/aws-blog-skills/releases/tag/v1.1.0
