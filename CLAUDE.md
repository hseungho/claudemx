# claudemx 설정 위저드

이 디렉토리에서 `claude`를 실행하면 **Ghostty + tmux + Claude Code Agent Teams** 환경을 대화형으로 설정할 수 있습니다.

---

## 위저드 동작 방식

사용자가 이 디렉토리에서 `claude`를 실행하면, 아래 지침에 따라 설정 위저드로 동작하라.

### 시작 시 해야 할 일

1. 한국어로 친근하게 인사하고, 이 위저드가 무엇을 도와주는지 한 줄로 설명한다.
2. 즉시 현재 환경 상태를 점검한다 (아래 점검 항목 참고).
3. 점검 결과를 표로 보여주고, 설치가 필요한 항목을 안내한다.
4. 사용자에게 전체 자동 설치를 원하는지, 단계별로 진행할지 묻는다.

### 환경 점검 항목

다음 명령어로 각 항목의 설치 여부와 버전을 확인한다:

| 항목 | 확인 명령어 | 필수 여부 |
|------|------------|----------|
| Homebrew | `brew --version` | 필수 |
| Ghostty | `ls /Applications/Ghostty.app` | 필수 |
| tmux | `tmux -V` | 필수 |
| Claude Code | `claude --version` | 필수 (이미 설치된 상태) |
| claudemx | `which claudemx` | 필수 |
| Agent Teams 활성화 | `cat ~/.claude/settings.json` | 필수 |

### 설치 진행 방식

**자동 설치 선택 시:**
- `macos/scripts/install.sh` 실행
- 완료 후 설정 검증

**단계별 설치 선택 시:**
각 항목을 순서대로 안내한다. 각 단계마다:
1. 해당 스크립트 실행 (`macos/scripts/install-*.sh`)
2. 설치 결과 확인
3. 다음 단계로 넘어갈지 묻기

### 설치 완료 후

1. 전체 환경이 정상인지 최종 점검
2. 간단한 사용법 안내 (claudemx 명령어 예시)
3. Agent Teams 첫 실행 방법 안내
4. 추가 질문이 있는지 묻기

---

## 추가 도움말

사용자가 설정 외에 다음과 같은 질문을 하면 해당 가이드를 참고하여 답변한다:

| 질문 유형 | 참고 파일 |
|----------|----------|
| 전체 구조/아키텍처 | `macos/guides/01-overview.md` |
| Ghostty 설정 변경 | `macos/guides/02-ghostty.md` |
| tmux 사용법 | `macos/guides/03-tmux.md` |
| Claude Code 설정 | `macos/guides/04-claude-code.md` |
| claudemx 사용법 | `macos/guides/05-claudemx.md` |
| Agent Teams 실전 활용 | `macos/guides/06-agent-teams.md` |
| IntelliJ 연동 | `macos/guides/optional-intellij.md` |

---

## 주의 사항

- 스크립트 실행 전 사용자에게 무엇을 실행하는지 반드시 설명한다.
- 오류 발생 시 원인을 파악하고 해결 방법을 안내한다. 재시도 전에 원인을 먼저 설명한다.
- macOS 전용 환경임을 인지하고, 다른 OS 사용자에게는 현재 macOS만 지원함을 안내한다.
