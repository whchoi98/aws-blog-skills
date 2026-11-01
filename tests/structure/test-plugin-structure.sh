#!/bin/bash
# Plugin structure and shipped-content invariants (sourced by tests/run-all.sh)

PJ=.claude-plugin/plugin.json
MJ=.claude-plugin/marketplace.json
SKILL_DIR=skills/aws-blog-skills
SKILL=$SKILL_DIR/SKILL.md

# --- Manifests ---
for f in "$PJ" "$MJ" .claude/settings.json .mcp.json; do
    assert_json_valid "$f is valid JSON" "$f"
done
NAME=$(jq -r '.name' "$PJ")
VER=$(jq -r '.version' "$PJ")
MKT=$(jq -r '.name' "$MJ")
assert_eq "plugin.json name" "aws-blog-skills" "$NAME"
assert_eq "marketplace name" "aws-blog-skills" "$MKT"
assert_eq "marketplace has exactly one plugin" "1" "$(jq '.plugins | length' "$MJ")"
assert_eq "marketplace entry name == plugin.json name" "$NAME" "$(jq -r '.plugins[0].name' "$MJ")"
assert_eq "marketplace entry source is the repo root" "./" "$(jq -r '.plugins[0].source' "$MJ")"
[[ "$VER" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] && pass "plugin.json version is semver ($VER)" \
    || fail "plugin.json version is semver" "got '$VER'"
assert_eq "plugin.json license is MIT" "MIT" "$(jq -r '.license' "$PJ")"
grep -qF "MIT License" LICENSE 2>/dev/null && pass "LICENSE is MIT" || fail "LICENSE is MIT" "LICENSE missing or not MIT"

# --- Version consistency (plugin.json, README badge, CHANGELOG both languages) ---
grep -qF "Version-${VER}-" README.md && pass "README version badge matches $VER" \
    || fail "README version badge matches $VER" "badge not found"
CL_EN=$(sed -n '/<a id="english"><\/a>/,/<a id="korean"><\/a>/p' CHANGELOG.md)
CL_KO=$(sed -n '/<a id="korean"><\/a>/,$p' CHANGELOG.md)
assert_eq "CHANGELOG (English) latest release == plugin.json" "$VER" \
    "$(printf '%s\n' "$CL_EN" | grep -m1 -oP '^## \[\K[0-9]+\.[0-9]+\.[0-9]+' || true)"
assert_eq "CHANGELOG (Korean) latest release == plugin.json" "$VER" \
    "$(printf '%s\n' "$CL_KO" | grep -m1 -oP '^## \[\K[0-9]+\.[0-9]+\.[0-9]+' || true)"
assert_eq "CHANGELOG: both languages list the same versions" \
    "$(printf '%s\n' "$CL_EN" | grep -oP '^## \[\K[^]]+' | tr '\n' ' ')" \
    "$(printf '%s\n' "$CL_KO" | grep -oP '^## \[\K[^]]+' | tr '\n' ' ')"
assert_contains "CHANGELOG: English has [Unreleased]" "$CL_EN" "## [Unreleased]"
assert_contains "CHANGELOG: Korean has [Unreleased]" "$CL_KO" "## [Unreleased]"

# --- Shipped skill: frontmatter ---
for dir in skills/*/; do
    skill=$(basename "$dir")
    assert_file_exists "skill $skill: SKILL.md" "$dir/SKILL.md"
    head -1 "$dir/SKILL.md" | grep -qx -- '---' && pass "skill $skill: frontmatter opens" \
        || fail "skill $skill: frontmatter opens" "first line is not ---"
    assert_eq "skill $skill: name matches directory" "$skill" \
        "$(sed -n '2,/^---$/s/^name: //p' "$dir/SKILL.md" | head -1 | tr -d '"')"
done
DESC=$(sed -n '2,/^---$/s/^description: //p' "$SKILL" | head -1)
[ "${#DESC}" -ge 50 ] && [ "${#DESC}" -le 1536 ] && pass "aws-blog-skills: description length ${#DESC} (50-1536)" \
    || fail "aws-blog-skills: description length (50-1536)" "${#DESC} chars; the skill listing truncates at 1536"
for phrase in '블로그 작성' '블로그 초안' 'aws-blog' 'AWS Korea Tech Blog'; do
    assert_contains "aws-blog-skills: description keeps trigger '$phrase'" "$DESC" "$phrase"
done
assert_contains "aws-blog-skills: description keeps precedence over kor-deslop" "$DESC" "kor-deslop 스킬보다 이 스킬을 우선"
SKILL_BODY=$(cat "$SKILL")
for section in "실행 환경 (Claude Code)" "0. 소재 파악과 범위 확정" "1. 사실 검증을 먼저 한다" "2. 골격 → 초안" \
               "3. 문장 규칙과 윤문" "4. 다이어그램" "5. 구조 검사" "6. 패키징과 전달" "7. 규칙 등록" "후속 요청 처리"; do
    assert_contains "aws-blog-skills: section '$section'" "$SKILL_BODY" "## $section"
done

# --- Shipped skill: Claude Code conventions (no claude.ai container leftovers) ---
for legacy in 'present_files' '/mnt/user-data' 'web_fetch' 'web_search' '`view`'; do
    HITS=$(grep -rlF -- "$legacy" "$SKILL_DIR" --include='*.md' | tr '\n' ' ')
    assert_eq "no claude.ai-only name '$legacy' in skill text" "" "$HITS"
done
BARE=$(grep -nE '(^|[ `"(])(python3|bash) "?scripts/' "$SKILL" | tr '\n' ' ')
assert_eq "SKILL.md calls bundled scripts via \${CLAUDE_SKILL_DIR}, not relative paths" "" "$BARE"
for script in $(grep -oP '\$\{CLAUDE_SKILL_DIR\}/scripts/\K[A-Za-z0-9_.-]+' "$SKILL" | sort -u); do
    assert_file_exists "SKILL.md script exists: $script" "$SKILL_DIR/scripts/$script"
done
assert_contains "SKILL.md: forbids writing into the skill folder" "$SKILL_BODY" "어떤 파일도 여기에 쓰지 않는다"
assert_contains "SKILL.md: work folder links drafts/images" "$SKILL_BODY" 'ln -sfn ../images'

# --- Shipped skill: reference table is complete and every link resolves ---
# Only table rows count: SKILL.md also links some references from body text
REF_TABLE=$(grep -E '^\| \[references/' "$SKILL" || true)
for ref in "$SKILL_DIR"/references/*.md; do
    base=$(basename "$ref")
    assert_contains "SKILL.md reference table lists $base" "$REF_TABLE" "| [references/$base](references/$base) |"
done
for link in $(grep -oP '\]\(\K(references|assets|scripts)/[^)#]+' "$SKILL" | sort -u); do
    assert_file_exists "SKILL.md link resolves: $link" "$SKILL_DIR/$link"
done

# --- Shipped skill: author bio is identical everywhere ---
# The last "## 저자 소개" section (structure.md also shows the heading inside its skeleton code block)
bio() { awk '/^## 저자 소개/{buf=""; on=1; next} on && /^## /{on=0} on && NF{buf=buf $0 "\n"} END{printf "%s", buf}' "$1"; }
BIO_STRUCT=$(bio "$SKILL_DIR/references/structure.md")
BIO_TEMPLATE=$(bio "$SKILL_DIR/assets/templates/blog-template.md")
[ -n "$BIO_STRUCT" ] && pass "structure.md: author bio present" || fail "structure.md: author bio present" "section empty"
assert_eq "author bio: structure.md == blog-template.md" "$BIO_STRUCT" "$BIO_TEMPLATE"
BIO_HEAD=$(grep -oP '^BIO_HEAD = "\K[^"]+' "$SKILL_DIR/scripts/check_structure.py" || true)
[ -n "$BIO_HEAD" ] && printf '%s\n' "$BIO_STRUCT" | grep -qF -- "$BIO_HEAD" \
    && pass "check_structure.py BIO_HEAD matches the bio" || fail "check_structure.py BIO_HEAD matches the bio" "'$BIO_HEAD'"

# --- Shipped skill: lint_prose.py mirrors style.md ---
STYLE=$(cat "$SKILL_DIR/references/style.md")
for term in '레버' '낭비 절감' '암시적 캐싱' '미국 본토' '다음과 같습니다'; do
    assert_contains "style.md bans '$term'" "$STYLE" "$term"
    grep -qF -- "(\"$term\"" "$SKILL_DIR/scripts/lint_prose.py" && pass "lint_prose.py HARD has '$term'" \
        || fail "lint_prose.py HARD has '$term'" "style.md bans it but lint_prose.py does not"
done
assert_eq "no CLAUDE.md inside shipped skill directories" "" \
    "$(find skills -mindepth 2 -name CLAUDE.md | tr '\n' ' ')"

# --- Shipped scripts: syntax and permissions ---
for py in "$SKILL_DIR"/scripts/*.py; do
    python3 -I -c 'import ast,sys; ast.parse(open(sys.argv[1], encoding="utf-8").read())' "$py" 2>/dev/null \
        && pass "$(basename "$py") parses" || fail "$(basename "$py") parses" "syntax error"
done
assert_bash_syntax "package_blog.sh valid bash" "$SKILL_DIR/scripts/package_blog.sh"
for f in "$SKILL_DIR"/scripts/*; do
    if head -1 "$f" | grep -q '^#!'; then
        assert_file_executable "$(basename "$f") with shebang is executable" "$f"
    fi
done

# --- Nothing executable ships at the root: no plugin component paths ---
for p in hooks commands agents bin output-styles settings.json; do
    [ ! -e "$p" ] && pass "root has no '$p' (would ship to every user)" \
        || fail "root has no '$p'" "'$p' is a plugin component path; move dev tooling under .claude/"
done
assert_eq ".mcp.json has only the mcpServers key" '["mcpServers"]' "$(jq -c 'keys' .mcp.json)"
assert_eq ".mcp.json declares no servers (it ships as plugin MCP config)" "0" "$(jq '.mcpServers | length' .mcp.json)"

# --- README install commands match the manifests and the remote ---
README=$(cat README.md)
assert_contains "README: install id" "$README" "claude plugin install ${NAME}@${MKT}"
assert_contains "README: marketplace update command" "$README" "claude plugin marketplace update ${MKT}"
assert_contains "README: plugin update command" "$README" "claude plugin update ${NAME}@${MKT}"
REMOTE=$(git remote get-url origin 2>/dev/null | sed -E 's#(\.git)?$##; s#.*github\.com[:/]##' || true)
if [ -n "$REMOTE" ]; then
    assert_contains "README: marketplace add uses the origin repo" "$README" "claude plugin marketplace add $REMOTE"
else
    skip "README: marketplace add uses the origin repo" "no origin remote"
fi
for script in $(find "$SKILL_DIR/scripts" -maxdepth 1 -type f -printf '%f\n' | sort); do
    assert_contains "README lists script $script" "$README" "$script"
done
for heading in Overview Features Prerequisites Installation Usage "Project Structure" Testing Contributing License Contact \
               "개요" "주요 기능" "사전 요구 사항" "설치 방법" "사용법" "프로젝트 구조" "테스트" "기여 방법" "라이선스" "연락처"; do
    grep -qx "## $heading" README.md && pass "README: section '$heading'" || fail "README: section '$heading'" "missing"
done

# --- File existence ---
for f in CLAUDE.md README.md CHANGELOG.md LICENSE .editorconfig .env.example .gitignore .mcp.json \
         docs/architecture.md docs/onboarding.md docs/decisions/.template.md docs/runbooks/.template.md \
         docs/runbooks/release-plugin.md docs/reference/INDEX.md; do
    assert_file_exists "$f" "$f"
done
for module in skills tests; do
    assert_file_exists "Module doc: $module/CLAUDE.md" "$module/CLAUDE.md"
done

# --- .gitignore keeps secrets and work folders out ---
GITIGNORE=$(cat .gitignore)
for pattern in ".env" ".claude/settings.local.json" "*.zip"; do
    assert_contains ".gitignore has $pattern" "$GITIGNORE" "$pattern"
done
git check-ignore -q .env && pass ".env is ignored by git" || fail ".env is ignored by git" "not ignored"
git check-ignore -q .env.example && fail ".env.example is tracked" "ignored" || pass ".env.example is tracked"
git check-ignore -q 2026-01-01-sample/x.md && pass "blog work folders are ignored" \
    || fail "blog work folders are ignored" "<YYYY-MM-DD>-<slug>/ not ignored"

# --- Harness script validation ---
for script in scripts/setup.sh scripts/install-hooks.sh tests/run-all.sh tests/hooks/*.sh tests/structure/*.sh; do
    assert_file_executable "$script is executable" "$script"
    assert_bash_syntax "$script valid bash" "$script"
done
# Test files are sourced into run-all.sh; assigning its counters corrupts the totals
CLOBBER=$(grep -nE '^\s*(TOTAL|PASSED|FAILED|SKIPPED|FAILURES|FILTER|TEST_TMP|PROJECT_ROOT|SCRIPT_DIR)\+?=' \
    tests/hooks/*.sh tests/structure/*.sh 2>/dev/null | tr '\n' ' ')
assert_eq "test files do not assign run-all.sh variables" "" "$CLOBBER"

# --- Commands, project skills, agents ---
for cmd in review test-all deploy; do
    CMD_CONTENT=$(cat ".claude/commands/$cmd.md")
    assert_contains "Command $cmd: has description" "$CMD_CONTENT" "description:"
    assert_contains "Command $cmd: has allowed-tools" "$CMD_CONTENT" "allowed-tools:"
done
DEPLOY_TOOLS=$(sed -n 's/^allowed-tools: //p' .claude/commands/deploy.md)
assert_not_contains "Command deploy: git push is not pre-allowed" "$DEPLOY_TOOLS" "git push"
assert_not_contains "Command deploy: git commit is not pre-allowed" "$DEPLOY_TOOLS" "git commit"
for skill in plugin-review refactor release sync-docs; do
    assert_eq "Project skill $skill: name matches directory" "$skill" \
        "$(sed -n '2,/^---$/s/^name: //p' ".claude/skills/$skill/SKILL.md" | head -1)"
    grep -q '^description: .\{20,\}' ".claude/skills/$skill/SKILL.md" \
        && pass "Project skill $skill: has description" || fail "Project skill $skill: has description" "missing"
done
[ ! -e .claude/skills/code-review ] && pass "no project skill shadows built-in /code-review" \
    || fail "no project skill shadows built-in /code-review" ".claude/skills/code-review exists"
for agent in code-reviewer security-auditor; do
    assert_file_exists "Agent $agent.md exists" ".claude/agents/$agent.md"
    assert_eq "Agent $agent: name matches file" "$agent" \
        "$(sed -n '2,/^---$/s/^name: //p' ".claude/agents/$agent.md" | head -1)"
done
assert_eq "no .yml agents (not loaded by Claude Code)" "" "$(find .claude/agents -name '*.yml' | tr '\n' ' ')"
# kor-writing and kor-deslop are legitimate companions here; these terms only belonged to that repo's harness
LEFTOVER=$(grep -rlE 'kor-writing@kor-writing|NOTICE\.md|A-17|patterns\.md|79 patterns|패턴 79' \
    .claude tests/CLAUDE.md skills/CLAUDE.md CLAUDE.md docs 2>/dev/null | tr '\n' ' ')
assert_eq "no leftovers from the kor-writing harness this was adapted from" "" "$LEFTOVER"

# --- CLAUDE.md content ---
for section in "Overview" "Tech Stack" "Project Structure" "Conventions" "Key Commands" "Auto-Sync Rules"; do
    grep -qF "## $section" CLAUDE.md && pass "CLAUDE.md: has $section" || fail "CLAUDE.md: has $section" "not found"
done
LINES=$(wc -l < CLAUDE.md | tr -d ' ')
[ "$LINES" -le 500 ] && pass "CLAUDE.md under 500 lines ($LINES)" || fail "CLAUDE.md under 500 lines" "$LINES lines"
grep -qF "<!-- AUTO-MANAGED:references -->" CLAUDE.md \
    && pass "CLAUDE.md: has references AUTO-MANAGED block" || fail "CLAUDE.md: has references AUTO-MANAGED block" "missing"

# --- Reference docs: every linked layer exists and every Code Pointer resolves ---
for layer in $(grep -oP 'docs/reference/\K[a-z-]+(?=\.md\))' CLAUDE.md | grep -v '^INDEX$'); do
    assert_file_exists "Reference layer: $layer" "docs/reference/$layer.md"
done
BAD_POINTERS=""
for ref in docs/reference/*.md; do
    [ "$(basename "$ref")" = "INDEX.md" ] && continue
    while IFS= read -r pointer; do
        path="${pointer%%:*}"
        range="${pointer#"$path"}"; range="${range#:}"
        if [ ! -e "$path" ]; then
            BAD_POINTERS+=" $ref->$pointer"
        elif [ -n "$range" ] && [ "$(wc -l < "$path")" -lt "${range##*-}" ]; then
            BAD_POINTERS+=" $ref->$pointer(line)"
        fi
    done < <(sed -n '/^### 4\./,/^### 5\./p' "$ref" | grep -oP '^- `\K[^`]+(?=`)' | grep -E '^[A-Za-z0-9_./-]+(:[0-9-]+)?$' || true)
done
assert_eq "Reference Code Pointers resolve to existing paths and lines" "" "${BAD_POINTERS# }"

# --- Bilingual documents use ASCII anchors with sentinels ---
for doc in README.md CHANGELOG.md docs/architecture.md docs/onboarding.md docs/runbooks/release-plugin.md \
           docs/decisions/ADR-*.md docs/reference/*.md; do
    if grep -qF '<a id="english"></a>' "$doc" && grep -qF '<a id="korean"></a>' "$doc"; then
        pass "Bilingual anchors: $doc"
    else
        fail "Bilingual anchors: $doc" "missing <a id=\"english\"> or <a id=\"korean\">"
    fi
done
EMOJI=$(LC_ALL=C.UTF-8 grep -lP '[\x{1F300}-\x{1FAFF}\x{2600}-\x{27BF}]' README.md CHANGELOG.md docs/*.md docs/*/*.md 2>/dev/null | tr '\n' ' ')
assert_eq "No emojis in user-facing docs" "" "$EMOJI"

# --- Claude Code's own validation ---
if command -v claude >/dev/null 2>&1; then
    VALIDATE=$(claude plugin validate . 2>&1 || true)
    assert_contains "claude plugin validate . passes" "$VALIDATE" "Validation passed"
else
    skip "claude plugin validate . passes" "Claude Code CLI not installed"
fi
