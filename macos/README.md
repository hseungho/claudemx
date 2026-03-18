# macOS 빠른 시작 가이드

## 요구 사항

- macOS 12 Monterey 이상
- [Homebrew](https://brew.sh) 설치 필요
- Claude Code 계정 (Claude Pro/Max 또는 Console)

## 대화형 설치 (권장)

레포를 클론한 디렉토리에서 `claude`를 실행하면 AI 위저드가 환경 점검부터 설치까지 대화로 안내합니다.

```bash
git clone https://github.com/hseungho/claudemx
cd claudemx
claude
```

Claude가 자동으로 현재 설치 상태를 점검하고 필요한 항목을 안내합니다.

## 원클릭 설치

대화 없이 바로 설치하려면:

```bash
bash macos/scripts/install.sh
```

설치 항목:
- Ghostty (터미널)
- tmux (터미널 멀티플렉서)
- Claude Code (AI CLI)
- claudemx (멀티 에이전트 런처)
- zsh 자동완성

---

## 단계별 설치

각 도구를 개별적으로 설치하려면 아래 가이드를 순서대로 따라주세요.

| 단계 | 가이드 | 설명 |
|------|--------|------|
| 1 | [전체 아키텍처](guides/01-overview.md) | 전체 구성 이해 |
| 2 | [Ghostty 설치](guides/02-ghostty.md) | 터미널 설치 및 설정 |
| 3 | [tmux 설치](guides/03-tmux.md) | 터미널 멀티플렉서 설치 |
| 4 | [Claude Code 설치](guides/04-claude-code.md) | Claude Code 및 Agent Teams 설정 |
| 5 | [claudemx 설치](guides/05-claudemx.md) | 멀티 에이전트 런처 설치 |
| 6 | [Agent Teams 사용법](guides/06-agent-teams.md) | 실전 사용 가이드 |

### 선택 설정

- [IntelliJ 연동](guides/optional-intellij.md) — IntelliJ에서 프로젝트 디렉토리로 Ghostty 열기

---

## 빠른 사용법

설치 완료 후:

```bash
# 오케스트레이션 모드 (Agent Teams) — 3명의 teammate
claudemx --orchestration --teammates 3

# 독립 세션 모드 — 4개의 독립적인 claude 세션
claudemx --agent 4

# 도움말
claudemx --help
```

### Agent Teams 사용 예시

```
# claude 프롬프트에서:
> create an agent team with 3 teammates to review PR #42
> 3명의 teammate로 이 기능을 레이어별로 병렬로 구현해줘
```

조작 단축키:

| 단축키 | 동작 |
|--------|------|
| `Shift+Down` | teammate 패널 순환 |
| `Ctrl+T` | 공유 task list 토글 |
| `Ctrl+B 방향키` | tmux 패널 이동 |
