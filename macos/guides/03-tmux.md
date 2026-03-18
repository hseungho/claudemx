# tmux 설치 및 설정

## 설치

```bash
brew install tmux
```

## 기본 사용법

```bash
# 새 세션 시작
tmux new-session -s my-session

# 세션 목록 확인
tmux ls

# 세션 연결
tmux attach -t my-session

# 세션 종료
tmux kill-session -t my-session
```

## 주요 단축키

> prefix 키: `Ctrl+B` (기본값)

| 단축키 | 동작 |
|--------|------|
| `prefix + %` | 수직 분할 |
| `prefix + "` | 수평 분할 |
| `prefix + 방향키` | 패널 이동 |
| `prefix + z` | 현재 패널 전체화면 토글 |
| `prefix + d` | 세션 분리 (백그라운드 유지) |
| `prefix + [` | 스크롤 모드 진입 (q로 종료) |

## Claude Code Agent Teams 관련

Claude Code Agent Teams는 tmux 세션 안에서 실행될 때 자동으로 split-pane 모드를 사용합니다.

- `Shift+Down` — teammate 패널 순환
- `Ctrl+T` — 공유 task list 토글

> **참고:** Ghostty에서 직접 split-pane 모드는 지원되지 않습니다. 반드시 tmux 세션 안에서 claude를 실행해야 합니다. claudemx가 이를 자동으로 처리합니다.

## 추천 설정 (~/.tmux.conf)

```bash
# ~/.tmux.conf

# 마우스 지원
set -g mouse on

# 256 색상 지원
set -g default-terminal "screen-256color"

# 패널 번호를 1부터 시작
set -g base-index 1
setw -g pane-base-index 1

# 상태바 스타일 (취향에 맞게 수정)
set -g status-style bg=black,fg=white
```

적용:
```bash
tmux source-file ~/.tmux.conf
```
