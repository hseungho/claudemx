# 태그 기반 버전 관리 + check-update Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** claudemx의 업데이트 시스템을 main 브랜치 기반에서 GitHub Release 태그 기반으로 전환하고, check-update 및 자동 체크 기능을 추가한다.

**Architecture:** 스크립트 상단에 VERSION 변수를 두고, GitHub API(`/releases/latest`)로 최신 태그를 조회하여 비교한다. 자동 체크는 백그라운드 서브셸로 실행하여 UI를 차단하지 않는다.

**Tech Stack:** zsh, curl, GitHub REST API

---

### Task 1: VERSION 변수 및 `--version` 플래그 추가

**Files:**
- Modify: `bin/claudemx:1-15` (상단에 VERSION 추가, 인자 파싱에 --version 추가)
- Modify: `bin/_claudemx:7-13` (자동완성에 --version 추가)

- [ ] **Step 1: bin/claudemx 상단에 VERSION 변수 추가**

`set -e` 바로 아래에 추가:

```bash
VERSION="v0.0.2"
```

- [ ] **Step 2: 인자 파싱에 --version 케이스 추가**

`--update|-u)` 케이스 위에 추가:

```bash
    --version|-v)
      echo "claudemx $VERSION"
      exit 0
      ;;
```

- [ ] **Step 3: --help 출력에 --version 추가**

옵션 섹션에 추가:

```bash
      echo "  --version, -v            버전 출력"
```

- [ ] **Step 4: bin/_claudemx에 --version 자동완성 추가**

`_arguments` 블록에 추가:

```bash
    '(--version -v)'{--version,-v}'[버전 출력]' \
```

- [ ] **Step 5: 동작 확인**

Run: `zsh bin/claudemx --version`
Expected: `claudemx v0.0.2`

- [ ] **Step 6: Commit**

```bash
git add bin/claudemx bin/_claudemx
git commit -m "feat: VERSION 변수 및 --version 플래그 추가"
```

---

### Task 2: `--update`를 태그 기반으로 변경

**Files:**
- Modify: `bin/claudemx:79-116` (업데이트 모드 전체 교체)

- [ ] **Step 1: 버전 비교 유틸리티 함수 추가**

VERSION 변수 아래에 함수 추가:

```bash
# 최신 릴리스 태그 조회
get_latest_version() {
  curl -fsSL --max-time 5 \
    "https://api.github.com/repos/hseungho/claudemx/releases/latest" 2>/dev/null \
    | grep -o '"tag_name": *"[^"]*"' | head -1 | cut -d'"' -f4
}
```

- [ ] **Step 2: 업데이트 모드를 태그 기반으로 교체**

기존 `if [[ "$MODE" == "update" ]]` 블록 전체를 교체:

```bash
if [[ "$MODE" == "update" ]]; then
  BIN_DIR="$HOME/.local/bin"
  COMPLETION_DIR="$HOME/.local/share/zsh/completions"
  TMPDIR_UPDATE=$(mktemp -d)
  trap "rm -rf $TMPDIR_UPDATE" EXIT

  echo "▶ claudemx 업데이트 확인 중..."

  LATEST=$(get_latest_version)
  if [[ -z "$LATEST" ]]; then
    echo "오류: GitHub에서 최신 버전을 확인할 수 없습니다."
    exit 1
  fi

  if [[ "$VERSION" == "$LATEST" ]]; then
    echo "  이미 최신 버전입니다. ($VERSION)"
    exit 0
  fi

  echo "  새 버전: $VERSION → $LATEST"

  GITHUB_RAW="https://raw.githubusercontent.com/hseungho/claudemx/$LATEST"

  if ! curl -fsSL "$GITHUB_RAW/bin/claudemx" -o "$TMPDIR_UPDATE/claudemx"; then
    echo "오류: 최신 버전을 다운로드할 수 없습니다."
    exit 1
  fi

  cp "$TMPDIR_UPDATE/claudemx" "$BIN_DIR/claudemx"
  chmod +x "$BIN_DIR/claudemx"
  echo "  ✓ claudemx $LATEST 업데이트 완료"

  if curl -fsSL "$GITHUB_RAW/bin/_claudemx" -o "$TMPDIR_UPDATE/_claudemx" 2>/dev/null; then
    mkdir -p "$COMPLETION_DIR"
    cp "$TMPDIR_UPDATE/_claudemx" "$COMPLETION_DIR/_claudemx"
    echo "  ✓ zsh 자동완성 업데이트 완료"
  fi

  echo ""
  echo "  업데이트가 적용되었습니다."
  exit 0
fi
```

- [ ] **Step 3: 동작 확인**

Run: `zsh bin/claudemx --update`
Expected: 최신 태그를 조회하고 버전 비교 결과 출력

- [ ] **Step 4: Commit**

```bash
git add bin/claudemx
git commit -m "feat: --update를 GitHub Release 태그 기반으로 변경"
```

---

### Task 3: `--check-update` 플래그 추가

**Files:**
- Modify: `bin/claudemx` (인자 파싱 + check-update 모드 블록)
- Modify: `bin/_claudemx` (자동완성)

- [ ] **Step 1: 인자 파싱에 --check-update 추가**

`--update|-u)` 케이스 아래에 추가:

```bash
    --check-update)
      MODE="check-update"
      shift
      ;;
```

- [ ] **Step 2: check-update 모드 블록 추가**

`if [[ "$MODE" == "update" ]]` 블록 위에 추가:

```bash
if [[ "$MODE" == "check-update" ]]; then
  LATEST=$(get_latest_version)
  if [[ -z "$LATEST" ]]; then
    echo "오류: GitHub에서 최신 버전을 확인할 수 없습니다."
    exit 1
  fi

  if [[ "$VERSION" == "$LATEST" ]]; then
    echo "이미 최신 버전입니다. ($VERSION)"
  else
    echo "새 버전 ${LATEST}이 있습니다. claudemx --update로 업데이트하세요"
  fi
  exit 0
fi
```

- [ ] **Step 3: --help 출력에 --check-update 추가**

```bash
      echo "  --check-update           새 버전 확인만 (업데이트하지 않음)"
```

- [ ] **Step 4: bin/_claudemx에 --check-update 자동완성 추가**

```bash
    '--check-update[새 버전 확인만]' \
```

- [ ] **Step 5: 동작 확인**

Run: `zsh bin/claudemx --check-update`
Expected: 현재 버전과 최신 버전 비교 결과 출력

- [ ] **Step 6: Commit**

```bash
git add bin/claudemx bin/_claudemx
git commit -m "feat: --check-update 플래그 추가"
```

---

### Task 4: 실행 시 백그라운드 자동 체크

**Files:**
- Modify: `bin/claudemx` (세션 이름 기본값 설정 후, tmux attach 전에 백그라운드 체크 로직 추가)

- [ ] **Step 1: 백그라운드 체크 함수 추가**

`get_latest_version()` 함수 아래에 추가:

```bash
# 백그라운드 업데이트 체크
background_update_check() {
  local tmpfile="$1"
  local latest
  latest=$(get_latest_version)
  if [[ -n "$latest" && "$latest" != "$VERSION" ]]; then
    echo "$latest" > "$tmpfile"
  fi
}
```

- [ ] **Step 2: agent/orchestration 모드 진입 시 백그라운드 체크 시작**

세션 이름 기본값 설정(`if [[ -z "$SESSION_NAME" ]]`) 바로 아래에 추가:

```bash
# 백그라운드 업데이트 체크 시작
UPDATE_CHECK_TMP=$(mktemp /tmp/claudemx-update-check.XXXXXX)
background_update_check "$UPDATE_CHECK_TMP" &
UPDATE_CHECK_PID=$!
```

- [ ] **Step 3: tmux attach 직전에 결과 확인 및 출력**

각 모드의 `tmux attach` 호출 직전에 추가 (orchestration 모드와 agent 모드 양쪽):

```bash
# 백그라운드 업데이트 체크 결과 확인
if [[ -n "${UPDATE_CHECK_PID:-}" ]]; then
  wait "$UPDATE_CHECK_PID" 2>/dev/null || true
  if [[ -s "$UPDATE_CHECK_TMP" ]]; then
    LATEST_VER=$(cat "$UPDATE_CHECK_TMP")
    echo "새 버전 ${LATEST_VER}이 있습니다. claudemx --update로 업데이트하세요"
    echo ""
  fi
  rm -f "$UPDATE_CHECK_TMP"
fi
```

- [ ] **Step 4: 동작 확인**

Run: `zsh bin/claudemx --agent 2` (tmux 사용 가능한 환경에서)
Expected: 새 버전이 있으면 attach 전에 한 줄 알림 출력

- [ ] **Step 5: Commit**

```bash
git add bin/claudemx
git commit -m "feat: 실행 시 백그라운드 업데이트 자동 체크"
```

---

### Task 5: `/release` 스킬에 VERSION 자동 업데이트 추가

**Files:**
- Modify: `skills/release.md` (4단계에 VERSION 변수 업데이트 스텝 추가)

- [ ] **Step 1: 릴리스 스킬 4단계에 VERSION 업데이트 추가**

태그 생성 전에 VERSION 변수를 업데이트하는 단계 추가:

```markdown
### 3.5단계: VERSION 변수 업데이트

`bin/claudemx`의 VERSION 변수를 새 버전으로 업데이트하고 커밋한다:

\`\`\`bash
# bin/claudemx의 VERSION 변수 업데이트
sed -i '' "s/^VERSION=\"v[0-9]*\.[0-9]*\.[0-9]*\"/VERSION=\"<version>\"/" bin/claudemx

# 변경 커밋
git add bin/claudemx
git commit -m "chore: bump VERSION to <version>"
\`\`\`
```

- [ ] **Step 2: Commit**

```bash
git add skills/release.md
git commit -m "feat: /release 스킬에 VERSION 자동 업데이트 단계 추가"
```
