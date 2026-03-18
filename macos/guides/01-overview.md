# 전체 아키텍처 개요

## 구성 요소

```
┌─────────────────────────────────────────────────┐
│  Ghostty (터미널 에뮬레이터)                      │
│                                                 │
│  ┌─────────────────────────────────────────┐   │
│  │  tmux (터미널 멀티플렉서)                 │   │
│  │                                         │   │
│  │  ┌─────────┐  ┌─────────┐  ┌─────────┐ │   │
│  │  │ Claude  │  │ Claude  │  │ Claude  │ │   │
│  │  │  Lead   │  │  팀원 1  │  │  팀원 2  │ │   │
│  │  └────┬────┘  └────┬────┘  └────┬────┘ │   │
│  │       │             │             │      │   │
│  │       └─────────────┴─────────────┘      │   │
│  │              Agent Teams 통신             │   │
│  └─────────────────────────────────────────┘   │
└─────────────────────────────────────────────────┘
```

## 각 도구의 역할

### Ghostty
- 터미널 에뮬레이터
- GPU 가속 렌더링으로 빠른 화면 출력
- tmux split-pane 모드 지원 (tmux를 통해)

### tmux
- 터미널 멀티플렉서
- Claude Code Agent Teams가 teammate를 별도 패널로 분리할 때 사용
- 세션이 유지되어 연결이 끊겨도 작업 보존

### Claude Code
- Anthropic의 AI 코딩 어시스턴트 CLI
- Agent Teams 기능으로 여러 독립 인스턴스가 협업

### claudemx
- tmux 세션 생성 및 Claude Code 실행을 자동화하는 래퍼 스크립트
- `--orchestration` 모드로 Agent Teams를 빠르게 시작

## Agent Teams 동작 방식

1. `claudemx --orchestration` 실행 → tmux 세션 생성 + 리드 Claude 시작
2. 리드 Claude에게 팀 구성 요청
3. Claude Code가 tmux 패널을 자동으로 분할하며 teammate 인스턴스 생성
4. 각 teammate는 독립적인 컨텍스트 윈도우를 가지며 작업 수행
5. 공유 task list와 mailbox를 통해 teammate 간 직접 통신
6. 리드가 결과를 취합하여 최종 응답 생성

## Subagents vs Agent Teams

| | Subagents | Agent Teams |
|---|---|---|
| 실행 방식 | 같은 세션 내부 | 독립 Claude 인스턴스 |
| tmux 패널 | 생성 안 됨 | 각자 별도 패널 |
| teammate 간 통신 | 불가 | 직접 메시지 가능 |
| 토큰 비용 | 낮음 | 높음 (인스턴스별 과금) |
| 적합한 작업 | 단순 병렬 처리 | 복잡한 협업, 토론 필요 작업 |
