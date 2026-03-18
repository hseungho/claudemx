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
