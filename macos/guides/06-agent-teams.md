# Agent Teams 실전 가이드

## 시작하기

```bash
claudemx --orchestration --teammates 3
```

claude가 준비되면 자동으로 팀 생성이 트리거됩니다. tmux 패널이 분리되며 각 teammate가 독립적으로 실행됩니다.

---

## 팀 구성 예시 프롬프트

### 코드 리뷰

```
create an agent team with 3 teammates to review PR #42:
- Teammate 1: security vulnerabilities
- Teammate 2: performance and scalability
- Teammate 3: test coverage and edge cases
```

### 병렬 기능 구현

```
3명의 teammate로 사용자 인증 기능을 레이어별로 병렬 구현해줘:
- Teammate 1: Repository / DB 레이어
- Teammate 2: Service / Application 레이어
- Teammate 3: Controller / API 레이어
```

### 버그 조사 (경쟁 가설)

```
사용자가 로그인 후 세션이 1분 만에 끊긴다는 버그가 있어.
4명의 teammate가 각자 다른 가설로 원인을 조사하고
서로의 가설을 반박하면서 실제 원인을 찾아줘.
```

### 기술 조사

```
새 캐싱 전략을 도입하려 해. 3명의 teammate가 각각
Redis, Caffeine, EhCache를 조사해서 우리 서비스에 맞는
최적 솔루션을 추천해줘.
```

---

## 조작법

| 동작 | 방법 |
|------|------|
| teammate 패널 순환 | `Shift+Down` |
| 특정 teammate에게 직접 메시지 | 해당 패널로 이동 후 입력 |
| 공유 task list 확인 | `Ctrl+T` |
| tmux 패널 이동 | `Ctrl+B + 방향키` |
| teammate 종료 요청 | 리드에게 "researcher teammate를 종료해줘" |
| 팀 정리 | 리드에게 "clean up the team" |

---

## 팀 사이즈 가이드

| teammate 수 | 적합한 상황 |
|------------|------------|
| 2~3명 | 일반적인 리뷰, 소규모 기능 |
| 3~5명 | 복잡한 기능 구현, 다각도 조사 |
| 5명 이상 | 대규모 리팩토링, 경쟁 가설 검증 |

> 각 teammate는 독립적인 컨텍스트 윈도우를 사용하므로 teammate가 많을수록 토큰 비용이 증가합니다.

---

## 주의 사항

- **파일 충돌 방지**: 같은 파일을 여러 teammate가 동시에 수정하면 충돌 발생. 작업 범위를 명확히 분리하세요.
- **실험적 기능**: Agent Teams는 아직 experimental 기능입니다. 간혹 task 상태 업데이트 지연이 발생할 수 있습니다.
- **세션 재개 제한**: `/resume`으로 세션 재개 시 teammate가 복원되지 않습니다. 새 teammate를 생성해야 합니다.
- **중첩 팀 불가**: teammate는 자신만의 팀을 생성할 수 없습니다.

---

## 트러블슈팅

### teammate 패널이 열리지 않는 경우

```bash
# tmux 설치 확인
which tmux

# Agent Teams 활성화 여부 확인
cat ~/.claude/settings.json | grep AGENT_TEAMS
```

### Subagents로 동작하는 경우

프롬프트에 "agent team"을 명시적으로 포함시키세요:

```
# ❌ 이렇게 하면 subagents로 동작할 수 있음
> 3명이서 이 코드를 리뷰해줘

# ✅ 이렇게 명시하면 Agent Teams 트리거
> create an agent team with 3 teammates to review this code
```

### 고아 tmux 세션 정리

```bash
tmux ls
tmux kill-session -t <세션이름>
```
