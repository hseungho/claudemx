# claudemx 세션 관리 기능 설계

## 개요

claudemx에 세션 목록 조회(`--list`), 세션 종료(`--kill`), 전체 세션 정리(`--prune`) 기능을 추가한다.

## 접근 방식

기존 `bin/claudemx` 스크립트에 함수로 직접 추가한다. 현재 `--flag` 패턴을 유지하며 단일 파일 구조를 보존한다.

## claudemx 세션 식별

claudemx가 생성한 세션과 사용자가 직접 만든 tmux 세션을 구분하기 위해, 세션 생성 시 tmux 환경변수를 설정한다.

```bash
tmux set-environment -t "$SESSION_NAME" CLAUDEMX "true"
```

기존 세션 생성 코드(`--new`, `--agent`, `--orchestration`)에 이 환경변수 설정을 추가한다. 모드 정보도 함께 저장한다:

```bash
tmux set-environment -t "$SESSION_NAME" CLAUDEMX_MODE "orchestration"  # 또는 "agent"
```

## 기능 1: `--list`

### 명령어

```bash
claudemx --list
```

### 데이터 수집

- `tmux list-sessions` — 세션 이름, 생성 시간
- `tmux show-environment -t 세션 CLAUDEMX` — claudemx 세션 필터링
- `tmux show-environment -t 세션 CLAUDEMX_MODE` — 모드 판별
- `tmux list-panes -t 세션` — pane 수 (팀메이트 수 계산)
- `pane_current_path` — 작업 디렉토리

### 출력 형식

docker ps 스타일 테이블. 세션이 없으면 헤더만 출력한다.

```
SESSION         MODE            TEAMMATES   UPTIME    DIRECTORY
my-refactor     orchestration   3           47m       ~/project-a
api-work        agent(2)        -           1h 2m     ~/project-b
```

### 모드/팀메이트 표시 규칙

| 모드 | MODE 컬럼 | TEAMMATES 컬럼 |
|------|-----------|----------------|
| orchestration | `orchestration` | pane 수 - 1 (리더 제외) |
| agent | `agent(N)` (N = pane 수) | `-` |

### UPTIME 형식

- 60분 미만: `12m`
- 1시간 이상: `1h 2m`
- 24시간 이상: `1d 2h`

### DIRECTORY 형식

`$HOME`으로 시작하면 `~`로 치환하여 표시한다.

## 기능 2: `--kill`

### 명령어

```bash
claudemx --kill <세션이름> [세션이름...]
```

### 동작

1. 인자로 받은 각 세션에 대해 순차 처리
2. 세션 존재 여부 확인
3. `CLAUDEMX` 환경변수 확인 (claudemx 세션인지 검증)
4. `tmux kill-session -t 세션이름` 실행
5. 결과 출력

### 출력

```bash
# 성공
세션 'my-refactor' 종료됨

# 세션 없음
세션 'no-exist'을(를) 찾을 수 없습니다

# claudemx 세션이 아님
세션 'my-tmux'은(는) claudemx 세션이 아닙니다
```

### 에러 처리

- 존재하지 않는 세션: 에러 메시지 출력 후 다음 세션 계속 처리
- claudemx 세션이 아닌 경우: 에러 메시지 출력 후 다음 세션 계속 처리
- 인자 없이 호출: 사용법 출력

## 기능 3: `--prune`

### 명령어

```bash
claudemx --prune        # 확인 프롬프트
claudemx --prune -f     # 즉시 종료
```

### 동작

1. `CLAUDEMX` 환경변수가 있는 모든 세션을 수집
2. 세션이 없으면 "종료할 세션이 없습니다" 출력 후 종료
3. `-f` 플래그 없으면 확인 프롬프트 표시
4. 확인 시 모든 세션을 `tmux kill-session`으로 종료

### 출력

```bash
# 확인 프롬프트
3개 세션을 모두 종료하시겠습니까? (y/N) y
3개 세션 종료됨

# -f 플래그
3개 세션 종료됨

# 세션 없음
종료할 세션이 없습니다
```

## zsh 자동완성

`bin/_claudemx` 파일을 수정하여 다음을 추가한다:

- `--list`, `--kill`, `--prune` 옵션을 완성 목록에 추가
- `--kill` 뒤에 tab 입력 시 `CLAUDEMX` 환경변수가 있는 활성 세션 이름을 동적으로 조회하여 제시
- 이미 입력된 세션 이름은 완성 목록에서 제외
- `--prune` 뒤에는 `-f` 옵션만 제시

## 수정 대상 파일

| 파일 | 변경 내용 |
|------|----------|
| `bin/claudemx` | `--list`, `--kill`, `--prune` 함수 추가, 기존 세션 생성 시 `CLAUDEMX`/`CLAUDEMX_MODE` 환경변수 설정 |
| `bin/_claudemx` | 새 옵션 자동완성 및 `--kill` 세션 이름 동적 완성 추가 |
