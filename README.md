# claudemx

Ghostty + tmux + Claude Code Agent Teams 환경 설정 가이드 및 도구 모음입니다.

## 개요

이 레포지토리는 Claude Code의 **Agent Teams** 기능을 팀에서 효율적으로 활용하기 위한 환경 설정을 빠르게 구성할 수 있도록 도와줍니다.

### 핵심 구성 요소

| 도구 | 역할 |
|------|------|
| **Ghostty** | 터미널 에뮬레이터 |
| **tmux** | 터미널 멀티플렉서 (에이전트 패널 분할) |
| **Claude Code** | AI 코딩 어시스턴트 CLI |
| **claudemx** | tmux 기반 Claude Code 멀티 에이전트 런처 |

### Agent Teams vs Subagents

```
[Subagents]                        [Agent Teams]
리드 Claude                         리드 Claude
  └── 내부 서브에이전트 A               ├── 독립 Claude 인스턴스 A (별도 패널)
  └── 내부 서브에이전트 B               ├── 독립 Claude 인스턴스 B (별도 패널)
  └── 내부 서브에이전트 C               └── 독립 Claude 인스턴스 C (별도 패널)

결과만 리드에게 보고                  teammate끼리 직접 통신 가능
```

## 빠른 시작

```bash
git clone https://github.com/hseungho/claudemx
cd claudemx
claude   # AI 위저드가 환경 점검 및 설치를 대화로 안내
```

## 설치

```bash
curl -fsSL https://raw.githubusercontent.com/hseungho/claudemx/main/macos/scripts/install-claudemx.sh | bash
```

또는 수동으로:

```bash
mkdir -p ~/.local/bin
curl -fsSL https://raw.githubusercontent.com/hseungho/claudemx/v0.0.3/bin/claudemx -o ~/.local/bin/claudemx
chmod +x ~/.local/bin/claudemx
```

> `~/.local/bin`이 `$PATH`에 포함되어 있어야 합니다.

## 업데이트

```bash
claudemx --update
```

새 버전 확인만 하려면:

```bash
claudemx --check-update
```

> `--update`는 v0.0.2에서 추가되었습니다. v0.0.1 사용자는 위 설치 명령으로 재설치하세요.

## 사용법

```bash
claudemx [옵션]
```

### 모드

| 옵션 | 설명 |
|------|------|
| `--agent, -a N` | 독립적인 Claude 세션 N개 생성 (기본: 2, 최대: 9) |
| `--orchestration, -o` | Agent Teams 오케스트레이션 모드 |

### 옵션

| 옵션 | 설명 |
|------|------|
| `--teammates, -t N` | 오케스트레이션 모드에서 teammate 수 힌트 (1~9) |
| `--session, -s NAME` | tmux 세션 이름 지정 |
| `--version, -v` | 버전 출력 |
| `--update, -u` | GitHub Release에서 최신 버전으로 업데이트 |
| `--check-update` | 새 버전 확인만 (업데이트하지 않음) |
| `--help, -h` | 도움말 |

### 예시

```bash
claudemx --agent 4                          # 4개 독립 에이전트
claudemx --orchestration                    # Agent Teams 모드
claudemx --orchestration --teammates 3      # teammate 3개로 시작
claudemx --orchestration --session my-proj  # 세션 이름 지정
```

### 오케스트레이션 모드 조작

| 키 | 동작 |
|----|------|
| `Shift+Down` | teammate 패널 순환 |
| `Ctrl+T` | 공유 task list 토글 |
| `Ctrl+B 방향키` | tmux 패널 이동 |

## 가이드

| 언어 | 링크 |
|------|------|
| 🇰🇷 한국어 | [macos/README.md](macos/README.md) |
| 🇺🇸 English | 준비 중 |

## 디렉토리 구조

```
claudemx/
├── README.md                  # 이 파일
├── bin/
│   ├── claudemx               # claudemx 스크립트
│   └── _claudemx              # zsh 자동완성
└── macos/
    ├── README.md              # macOS 빠른 시작 가이드
    ├── guides/
    │   ├── 01-overview.md     # 전체 아키텍처 개요
    │   ├── 02-ghostty.md      # Ghostty 설치 및 설정
    │   ├── 03-tmux.md         # tmux 설치 및 설정
    │   ├── 04-claude-code.md  # Claude Code 설치 및 Agent Teams 설정
    │   ├── 05-claudemx.md     # claudemx 사용법
    │   ├── 06-agent-teams.md  # Agent Teams 실전 가이드
    │   └── optional-intellij.md  # (선택) IntelliJ 연동
    └── scripts/
        ├── install.sh         # 원클릭 전체 설치
        ├── install-ghostty.sh
        ├── install-tmux.sh
        ├── install-claude-code.sh
        └── install-claudemx.sh
```
