# 세션 관리 기능 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** claudemx에 세션 목록 조회(`--list`), 세션 종료(`--kill`), 전체 정리(`--prune`) 기능을 추가한다.

**Architecture:** 기존 `bin/claudemx` 단일 스크립트에 함수로 추가. 세션 생성 시 tmux 환경변수(`CLAUDEMX`, `CLAUDEMX_MODE`)를 설정하여 claudemx 세션을 식별. `bin/_claudemx` 자동완성도 함께 업데이트.

**Tech Stack:** zsh, tmux

---

## File Structure

| 파일 | 변경 유형 | 역할 |
|------|----------|------|
| `bin/claudemx` | Modify | `--list`, `--kill`, `--prune` 로직 추가 + 기존 세션 생성에 환경변수 설정 |
| `bin/_claudemx` | Modify | 새 옵션 자동완성 + `--kill` 동적 세션 완성 |

---

### Task 1: 세션 생성 시 tmux 환경변수 설정

**Files:**
- Modify: `bin/claudemx:250` (orchestration 모드 세션 생성 직후)
- Modify: `bin/claudemx:325` (agent 모드 세션 생성 직후)

- [ ] **Step 1: orchestration 모드에 환경변수 설정 추가**

`bin/claudemx:250`의 `tmux new-session -d -s "$SESSION_NAME"` 직후에 환경변수 설정을 추가한다:

```bash
# 세션 생성 (기존 코드)
tmux new-session -d -s "$SESSION_NAME"

# claudemx 세션 식별용 환경변수 설정
tmux set-environment -t "$SESSION_NAME" CLAUDEMX "true"
tmux set-environment -t "$SESSION_NAME" CLAUDEMX_MODE "orchestration"
```

- [ ] **Step 2: agent 모드에 환경변수 설정 추가**

`bin/claudemx:325`의 `tmux new-session -d -s "$SESSION_NAME"` 직후에 환경변수 설정을 추가한다:

```bash
# 세션 생성 (기존 코드)
tmux new-session -d -s "$SESSION_NAME"

# claudemx 세션 식별용 환경변수 설정
tmux set-environment -t "$SESSION_NAME" CLAUDEMX "true"
tmux set-environment -t "$SESSION_NAME" CLAUDEMX_MODE "agent"
```

- [ ] **Step 3: 동작 확인**

```bash
# tmux 세션을 만들고 환경변수가 설정되는지 확인
tmux new-session -d -s test-env
tmux set-environment -t test-env CLAUDEMX "true"
tmux set-environment -t test-env CLAUDEMX_MODE "agent"
tmux show-environment -t test-env CLAUDEMX
# 기대 출력: CLAUDEMX=true
tmux show-environment -t test-env CLAUDEMX_MODE
# 기대 출력: CLAUDEMX_MODE=agent
tmux kill-session -t test-env
```

- [ ] **Step 4: 커밋**

```bash
git add bin/claudemx
git commit -m "feat: 세션 생성 시 CLAUDEMX/CLAUDEMX_MODE 환경변수 설정"
```

---

### Task 2: `--list` 기능 구현

**Files:**
- Modify: `bin/claudemx:38-109` (인자 파싱 + 모드 처리)

- [ ] **Step 1: 인자 파싱에 `--list` 추가**

`bin/claudemx`의 `while [[ $# -gt 0 ]]` 블록 안, `--check-update)` case 앞에 추가:

```bash
    --list|-l)
      MODE="list"
      shift
      ;;
```

- [ ] **Step 2: uptime 포맷 헬퍼 함수 추가**

`background_update_check()` 함수 아래에 추가:

```bash
# 초를 사람이 읽을 수 있는 형식으로 변환
format_uptime() {
  local seconds=$1
  local days=$((seconds / 86400))
  local hours=$(( (seconds % 86400) / 3600 ))
  local minutes=$(( (seconds % 3600) / 60 ))

  if [[ $days -gt 0 ]]; then
    echo "${days}d ${hours}h"
  elif [[ $hours -gt 0 ]]; then
    echo "${hours}h ${minutes}m"
  else
    echo "${minutes}m"
  fi
}
```

- [ ] **Step 3: `--list` 모드 처리 로직 추가**

`if [[ "$MODE" == "check-update" ]]` 블록 앞에 추가:

```bash
if [[ "$MODE" == "list" ]]; then
  printf "%-20s %-18s %-12s %-10s %s\n" "SESSION" "MODE" "TEAMMATES" "UPTIME" "DIRECTORY"

  tmux list-sessions -F '#{session_name} #{session_created}' 2>/dev/null | while read -r session_name session_created; do
    # claudemx 세션인지 확인
    local cmx_env
    cmx_env=$(tmux show-environment -t "$session_name" CLAUDEMX 2>/dev/null) || continue
    [[ "$cmx_env" == "CLAUDEMX=true" ]] || continue

    # 모드 확인
    local mode_env mode_display teammates
    mode_env=$(tmux show-environment -t "$session_name" CLAUDEMX_MODE 2>/dev/null)
    local mode_value="${mode_env#CLAUDEMX_MODE=}"

    # pane 수 조회
    local pane_count
    pane_count=$(tmux list-panes -t "$session_name" 2>/dev/null | wc -l | tr -d ' ')

    if [[ "$mode_value" == "orchestration" ]]; then
      mode_display="orchestration"
      teammates=$((pane_count - 1))
    else
      mode_display="agent(${pane_count})"
      teammates="-"
    fi

    # uptime 계산
    local now uptime_seconds uptime_display
    now=$(date +%s)
    uptime_seconds=$((now - session_created))
    uptime_display=$(format_uptime "$uptime_seconds")

    # 작업 디렉토리 (첫 번째 pane 기준)
    local directory
    directory=$(tmux display-message -t "$session_name:0.0" -p '#{pane_current_path}' 2>/dev/null)
    directory="${directory/#$HOME/~}"

    printf "%-20s %-18s %-12s %-10s %s\n" "$session_name" "$mode_display" "$teammates" "$uptime_display" "$directory"
  done

  exit 0
fi
```

- [ ] **Step 4: 도움말에 `--list` 추가**

`--help` 출력 블록의 "옵션:" 섹션에 추가:

```bash
echo "  --list, -l               실행 중인 claudemx 세션 목록 표시"
```

- [ ] **Step 5: 동작 확인**

```bash
# 세션이 없을 때 헤더만 출력되는지 확인
claudemx --list
# 기대 출력:
# SESSION              MODE               TEAMMATES    UPTIME     DIRECTORY
```

- [ ] **Step 6: 커밋**

```bash
git add bin/claudemx
git commit -m "feat: --list 옵션으로 실행 중인 claudemx 세션 목록 표시"
```

---

### Task 3: `--kill` 기능 구현

**Files:**
- Modify: `bin/claudemx:38-109` (인자 파싱 + 모드 처리)

- [ ] **Step 1: 인자 파싱에 `--kill` 추가**

`--list` case 아래에 추가. `--kill` 뒤의 모든 인자를 세션 이름 배열로 수집한다:

```bash
    --kill|-k)
      MODE="kill"
      shift
      KILL_SESSIONS=()
      while [[ $# -gt 0 && ! "$1" == --* ]]; do
        KILL_SESSIONS+=("$1")
        shift
      done
      if [[ ${#KILL_SESSIONS[@]} -eq 0 ]]; then
        echo "사용법: claudemx --kill <세션이름> [세션이름...]"
        exit 1
      fi
      ;;
```

- [ ] **Step 2: 기본값에 KILL_SESSIONS 배열 추가**

기존 기본값 블록(`# 기본값` 주석 아래)에 추가:

```bash
KILL_SESSIONS=()
```

- [ ] **Step 3: `--kill` 모드 처리 로직 추가**

`--list` 모드 처리 블록 아래에 추가:

```bash
if [[ "$MODE" == "kill" ]]; then
  for session_name in "${KILL_SESSIONS[@]}"; do
    # 세션 존재 확인
    if ! tmux has-session -t "$session_name" 2>/dev/null; then
      echo "세션 '${session_name}'을(를) 찾을 수 없습니다"
      continue
    fi

    # claudemx 세션인지 확인
    local cmx_env
    cmx_env=$(tmux show-environment -t "$session_name" CLAUDEMX 2>/dev/null) || true
    if [[ "$cmx_env" != "CLAUDEMX=true" ]]; then
      echo "세션 '${session_name}'은(는) claudemx 세션이 아닙니다"
      continue
    fi

    tmux kill-session -t "$session_name"
    echo "세션 '${session_name}' 종료됨"
  done
  exit 0
fi
```

- [ ] **Step 4: 도움말에 `--kill` 추가**

`--help` 출력 블록에 추가:

```bash
echo "  --kill, -k NAME...       지정한 claudemx 세션 종료"
```

- [ ] **Step 5: 커밋**

```bash
git add bin/claudemx
git commit -m "feat: --kill 옵션으로 claudemx 세션 종료"
```

---

### Task 4: `--prune` 기능 구현

**Files:**
- Modify: `bin/claudemx:38-109` (인자 파싱 + 모드 처리)

- [ ] **Step 1: 인자 파싱에 `--prune` 추가**

`--kill` case 아래에 추가:

```bash
    --prune)
      MODE="prune"
      shift
      ;;
    -f)
      FORCE=true
      shift
      ;;
```

- [ ] **Step 2: 기본값에 FORCE 추가**

기존 기본값 블록에 추가:

```bash
FORCE=false
```

- [ ] **Step 3: `--prune` 모드 처리 로직 추가**

`--kill` 모드 처리 블록 아래에 추가:

```bash
if [[ "$MODE" == "prune" ]]; then
  # claudemx 세션 수집
  PRUNE_SESSIONS=()
  while IFS= read -r session_name; do
    [[ -z "$session_name" ]] && continue
    local cmx_env
    cmx_env=$(tmux show-environment -t "$session_name" CLAUDEMX 2>/dev/null) || continue
    [[ "$cmx_env" == "CLAUDEMX=true" ]] || continue
    PRUNE_SESSIONS+=("$session_name")
  done < <(tmux list-sessions -F '#{session_name}' 2>/dev/null)

  local count=${#PRUNE_SESSIONS[@]}

  if [[ $count -eq 0 ]]; then
    echo "종료할 세션이 없습니다"
    exit 0
  fi

  # 확인 프롬프트 (-f가 아닐 때)
  if [[ "$FORCE" == "false" ]]; then
    printf "%d개 세션을 모두 종료하시겠습니까? (y/N) " "$count"
    read -r answer
    if [[ "$answer" != "y" && "$answer" != "Y" ]]; then
      echo "취소됨"
      exit 0
    fi
  fi

  for session_name in "${PRUNE_SESSIONS[@]}"; do
    tmux kill-session -t "$session_name"
  done
  echo "${count}개 세션 종료됨"
  exit 0
fi
```

- [ ] **Step 4: 도움말에 `--prune` 추가**

`--help` 출력 블록에 추가:

```bash
echo "  --prune                  모든 claudemx 세션 종료 (확인 프롬프트)"
echo "  -f                       --prune 시 확인 없이 즉시 종료"
```

- [ ] **Step 5: 커밋**

```bash
git add bin/claudemx
git commit -m "feat: --prune 옵션으로 모든 claudemx 세션 일괄 종료"
```

---

### Task 5: zsh 자동완성 업데이트

**Files:**
- Modify: `bin/_claudemx`

- [ ] **Step 1: `_claudemx` 완전 교체**

`bin/_claudemx`를 다음 내용으로 교체한다:

```bash
#compdef claudemx

_claudemx() {
  local context state line
  typeset -A opt_args

  _arguments -C \
    '(--agent -a)'{--agent,-a}'[독립적인 claude 세션 N개 생성]:에이전트 수:(1 2 3 4 5 6 7 8 9)' \
    '(--orchestration -o)'{--orchestration,-o}'[Agent Teams 오케스트레이션 모드]' \
    '(--version -v)'{--version,-v}'[버전 출력]' \
    '(--update -u)'{--update,-u}'[GitHub에서 최신 버전으로 업데이트]' \
    '--check-update[새 버전 확인만]' \
    '(--teammates -t)'{--teammates,-t}'[오케스트레이션 teammate 수]:teammate 수:(1 2 3 4 5 6 7 8 9)' \
    '(--session -s)'{--session,-s}'[기존 tmux 세션에 연결]:세션 이름:_claudemx_sessions' \
    '(--new -n)'{--new,-n}'[새 세션 강제 생성]' \
    '(--list -l)'{--list,-l}'[실행 중인 claudemx 세션 목록]' \
    '(--kill -k)'{--kill,-k}'[지정한 claudemx 세션 종료]:*:세션 이름:_claudemx_managed_sessions' \
    '--prune[모든 claudemx 세션 종료]' \
    '-f[--prune 시 확인 없이 즉시 종료]' \
    '(--help -h)'{--help,-h}'[도움말 표시]'
}

# 기존 tmux 세션 목록 자동완성
_claudemx_sessions() {
  local sessions
  sessions=(${(f)"$(tmux list-sessions -F '#{session_name}' 2>/dev/null)"})
  if [[ ${#sessions} -gt 0 ]]; then
    _describe '기존 tmux 세션' sessions
  fi
}

# claudemx가 관리하는 세션만 자동완성
_claudemx_managed_sessions() {
  local sessions=()
  local session_name
  for session_name in ${(f)"$(tmux list-sessions -F '#{session_name}' 2>/dev/null)"}; do
    local cmx_env
    cmx_env=$(tmux show-environment -t "$session_name" CLAUDEMX 2>/dev/null) || continue
    [[ "$cmx_env" == "CLAUDEMX=true" ]] && sessions+=("$session_name")
  done
  if [[ ${#sessions} -gt 0 ]]; then
    _describe 'claudemx 세션' sessions
  fi
}

_claudemx "$@"
```

- [ ] **Step 2: 자동완성 리로드 테스트**

```bash
# 완성 캐시 초기화 후 확인
unfunction _claudemx 2>/dev/null; autoload -Uz _claudemx
claudemx --<TAB>
# 기대: --list, --kill, --prune이 목록에 나타남
```

- [ ] **Step 3: 커밋**

```bash
git add bin/_claudemx
git commit -m "feat: --list, --kill, --prune zsh 자동완성 추가"
```

---

### Task 6: 정리 및 최종 확인

**Files:**
- Modify: `bin/claudemx` (사용법 주석 업데이트)

- [ ] **Step 1: 파일 상단 사용법 주석 업데이트**

`bin/claudemx:3-7`의 주석을 업데이트한다:

```bash
# claudemx - tmux 기반 Claude Code 멀티 에이전트 런처
# 사용법:
#   claudemx --agent N                      N개의 독립적인 claude 세션 생성
#   claudemx --orchestration [--teammates N] Agent Teams 오케스트레이션 모드
#   claudemx --list                         실행 중인 claudemx 세션 목록 표시
#   claudemx --kill NAME [NAME...]          지정한 claudemx 세션 종료
#   claudemx --prune [-f]                   모든 claudemx 세션 종료
#   claudemx --update                       GitHub에서 최신 버전으로 업데이트
```

- [ ] **Step 2: `docs/superpowers` 디렉토리 삭제**

```bash
rm -rf docs/superpowers
git add -A docs/superpowers
git commit -m "chore: docs/superpowers 임시 디렉토리 삭제"
```

- [ ] **Step 3: 전체 기능 수동 테스트**

```bash
# 1. 세션 없을 때 --list
claudemx --list
# 기대: 헤더만 출력

# 2. agent 세션 생성 후 --list
claudemx --agent 2
# (다른 터미널에서)
claudemx --list
# 기대: 세션 1개, agent(2), UPTIME, DIRECTORY 표시

# 3. --kill로 종료
claudemx --kill claude-agents
# 기대: "세션 'claude-agents' 종료됨"

# 4. --list 재확인
claudemx --list
# 기대: 헤더만 출력

# 5. 여러 세션 생성 후 --prune
claudemx --agent 1
claudemx --agent 1
claudemx --prune
# 기대: "2개 세션을 모두 종료하시겠습니까? (y/N)"

# 6. --prune -f
claudemx --agent 1
claudemx --prune -f
# 기대: "1개 세션 종료됨" (즉시)
```

- [ ] **Step 4: 최종 커밋**

```bash
git add bin/claudemx
git commit -m "docs: claudemx 파일 상단 사용법 주석 업데이트"
```
