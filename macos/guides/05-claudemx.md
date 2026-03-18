# claudemx 설치 및 사용법

## 설치

```bash
# bin/claudemx를 PATH에 복사
cp bin/claudemx ~/.local/bin/claudemx
chmod +x ~/.local/bin/claudemx

# zsh 자동완성 설정
mkdir -p ~/.local/share/zsh/completions
cp bin/_claudemx ~/.local/share/zsh/completions/_claudemx
```

`~/.zshrc`에 fpath 추가 (`source $ZSH/oh-my-zsh.sh` 또는 `compinit` 전에):

```zsh
fpath=(~/.local/share/zsh/completions $fpath)
```

적용:
```bash
source ~/.zshrc
```

> `~/.local/bin`이 PATH에 없다면 `~/.zshrc`에 추가:
> ```zsh
> export PATH="$HOME/.local/bin:$PATH"
> ```

## 사용법

### 오케스트레이션 모드 (Agent Teams)

```bash
# 기본 실행 — claude에서 직접 팀 구성 요청
claudemx --orchestration

# teammate 수 지정 — claude 시작 시 자동으로 팀 생성 트리거
claudemx --orchestration --teammates 3

# 세션 이름 지정
claudemx --orchestration --teammates 3 --session my-project
```

### 에이전트 모드 (독립 세션)

```bash
# 4개의 독립적인 claude 세션 생성
claudemx --agent 4

# 세션 이름 지정
claudemx --agent 2 --session review-session
```

### 도움말

```bash
claudemx --help
```

## 옵션 전체 목록

| 옵션 | 단축 | 설명 |
|------|------|------|
| `--orchestration` | `-o` | Agent Teams 오케스트레이션 모드 |
| `--agent N` | `-a N` | 독립 세션 N개 생성 (1~9) |
| `--teammates N` | `-t N` | teammate 수 힌트 (오케스트레이션 모드) |
| `--session NAME` | `-s NAME` | tmux 세션 이름 지정 |
| `--help` | `-h` | 도움말 |

## 자동완성

설치 후 Tab으로 옵션 자동완성이 지원됩니다:

```bash
claudemx --<Tab>            # 모든 옵션 목록
claudemx --agent <Tab>      # 1~9 숫자 추천
claudemx --teammates <Tab>  # 1~9 숫자 추천
claudemx --session <Tab>    # 기존 tmux 세션 이름 목록
```

## 기존 세션 재연결

같은 세션 이름으로 실행하면 기존 세션에 자동으로 재연결됩니다:

```bash
claudemx --orchestration --session my-project
# → 이미 존재하면 재연결, 없으면 새로 생성
```
