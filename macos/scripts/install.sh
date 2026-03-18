#!/bin/bash
# claudemx 원클릭 설치 스크립트
# 사용법:
#   bash macos/scripts/install.sh
#   bash macos/scripts/install.sh --dry-run

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DRY_RUN=false

for arg in "$@"; do
  case $arg in
    --dry-run) DRY_RUN=true ;;
  esac
done

DR_FLAG=""
$DRY_RUN && DR_FLAG="--dry-run"

run() {
  if $DRY_RUN; then
    echo "  [DRY-RUN] $*"
  else
    "$@"
  fi
}

echo "╔══════════════════════════════════════════════╗"
echo "║   claudemx 설치 시작                         ║"
echo "║   Ghostty + tmux + Claude Code Agent Teams  ║"
$DRY_RUN && echo "║   ⚠ DRY-RUN 모드 (실제 설치 안 함)          ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# macOS 확인
if [[ "$(uname)" != "Darwin" ]]; then
  echo "✗ 이 스크립트는 macOS 전용입니다."
  exit 1
fi

# Homebrew 확인
if ! command -v brew &>/dev/null; then
  if $DRY_RUN; then
    echo "  [DRY-RUN] /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
  else
    echo "▶ Homebrew 설치 중..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
else
  echo "✓ Homebrew 확인 완료 ($(brew --version | head -1))"
fi

echo ""

# 1. Ghostty
bash "$SCRIPT_DIR/install-ghostty.sh" $DR_FLAG
echo ""

# 2. tmux
bash "$SCRIPT_DIR/install-tmux.sh" $DR_FLAG
echo ""

# 3. Claude Code + Agent Teams
bash "$SCRIPT_DIR/install-claude-code.sh" $DR_FLAG
echo ""

# 4. claudemx
bash "$SCRIPT_DIR/install-claudemx.sh" $DR_FLAG
echo ""

echo "╔══════════════════════════════════════════════╗"
if $DRY_RUN; then
  echo "║   DRY-RUN 완료 (실제 변경 없음)              ║"
else
  echo "║   설치 완료!                                  ║"
fi
echo "╚══════════════════════════════════════════════╝"
echo ""

if ! $DRY_RUN; then
  echo "  다음 단계:"
  echo "  1. 새 터미널을 열거나: source ~/.zshrc"
  echo "  2. Claude Code 로그인: claude"
  echo "  3. Agent Teams 시작: claudemx --orchestration --teammates 3"
  echo ""
  echo "  상세 가이드: macos/guides/"
  echo "  Agent Teams 사용법: macos/guides/06-agent-teams.md"
fi
