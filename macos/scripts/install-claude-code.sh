#!/bin/bash
# Claude Code 설치 및 Agent Teams 설정 스크립트
# 사용법:
#   bash macos/scripts/install-claude-code.sh
#   bash macos/scripts/install-claude-code.sh --dry-run

set -e

DRY_RUN=false
for arg in "$@"; do
  case $arg in
    --dry-run) DRY_RUN=true ;;
  esac
done

run() {
  if $DRY_RUN; then
    echo "  [DRY-RUN] $*"
  else
    "$@"
  fi
}

echo "▶ Claude Code 설치 중..."

# Node.js 확인
if ! command -v node &>/dev/null; then
  echo "  Node.js가 없습니다. Homebrew로 설치합니다..."
  if ! command -v brew &>/dev/null; then
    echo "  ✗ Homebrew가 설치되어 있지 않습니다. 먼저 Homebrew를 설치해주세요."
    echo "    https://brew.sh"
    exit 1
  fi
  run brew install node
fi

# Claude Code 설치
if command -v claude &>/dev/null; then
  echo "  ✓ Claude Code가 이미 설치되어 있습니다. ($(claude --version))"
else
  run npm install -g @anthropic-ai/claude-code
  $DRY_RUN || echo "  ✓ Claude Code 설치 완료"
fi

# 버전 확인 (v2.1.32 이상 필요)
if command -v claude &>/dev/null; then
  CLAUDE_VERSION=$(claude --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
  REQUIRED_VERSION="2.1.32"

  version_gte() {
    [ "$(printf '%s\n' "$2" "$1" | sort -V | head -n1)" = "$2" ]
  }

  if ! version_gte "$CLAUDE_VERSION" "$REQUIRED_VERSION"; then
    echo "  ⚠ Claude Code v$REQUIRED_VERSION 이상이 필요합니다. (현재: v$CLAUDE_VERSION)"
    echo "  업데이트: npm update -g @anthropic-ai/claude-code"
  fi
fi

# Agent Teams 설정
echo ""
echo "▶ Agent Teams 설정 중..."

SETTINGS_FILE="$HOME/.claude/settings.json"

if $DRY_RUN; then
  echo "  [DRY-RUN] mkdir -p $HOME/.claude"
  echo "  [DRY-RUN] $SETTINGS_FILE 에 CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 추가"
else
  mkdir -p "$HOME/.claude"

  if [ ! -f "$SETTINGS_FILE" ]; then
    echo '{}' > "$SETTINGS_FILE"
  fi

  if grep -q "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS" "$SETTINGS_FILE" 2>/dev/null; then
    echo "  ✓ Agent Teams가 이미 활성화되어 있습니다."
  else
    python3 - <<EOF
import json

with open('$SETTINGS_FILE', 'r') as f:
    settings = json.load(f)

if 'env' not in settings:
    settings['env'] = {}

settings['env']['CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS'] = '1'

with open('$SETTINGS_FILE', 'w') as f:
    json.dump(settings, f, indent=2, ensure_ascii=False)
    f.write('\n')

print('  ✓ Agent Teams 활성화 완료')
EOF
  fi
fi

echo ""
echo "  설정 가이드: macos/guides/04-claude-code.md"
echo "  로그인: claude (최초 실행 시 브라우저 인증)"
