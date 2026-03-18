#!/bin/bash
# tmux 설치 스크립트
# 사용법:
#   bash macos/scripts/install-tmux.sh
#   bash macos/scripts/install-tmux.sh --dry-run

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

echo "▶ tmux 설치 중..."

if command -v tmux &>/dev/null; then
  echo "  ✓ tmux가 이미 설치되어 있습니다. ($(tmux -V))"
  exit 0
fi

if ! command -v brew &>/dev/null; then
  echo "  ✗ Homebrew가 설치되어 있지 않습니다. 먼저 Homebrew를 설치해주세요."
  echo "    https://brew.sh"
  exit 1
fi

run brew install tmux

echo "  ✓ tmux 설치 완료"
echo ""
echo "  추천 설정 가이드: macos/guides/03-tmux.md"
