# Claude Code 설치 및 Agent Teams 설정

## 설치

```bash
npm install -g @anthropic-ai/claude-code
```

> Node.js가 없다면 먼저 설치: `brew install node`

## 로그인

```bash
claude
# 최초 실행 시 브라우저를 통한 인증 진행
```

## Agent Teams 활성화

Claude Code 설정 파일(`~/.claude/settings.json`)에 다음을 추가합니다:

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

> **참고:** Agent Teams는 실험적 기능이며 Claude Code v2.1.32 이상에서 지원됩니다.

버전 확인:
```bash
claude --version
```

## 설정 파일 전체 예시

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

> 기타 설정(모델, 권한 등)은 팀원 개인 환경에 맞게 구성하세요.

## 동작 확인

```bash
# tmux 세션 안에서 실행
tmux new-session -s test
claude

# claude 프롬프트에서:
# > create an agent team with 2 teammates for a test task
```

teammate 패널이 tmux에서 자동으로 분리되면 정상입니다.
