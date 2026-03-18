#!/bin/bash
# claudemx 설치 스크립트
# 사용법:
#   bash macos/scripts/install-claudemx.sh
#   bash macos/scripts/install-claudemx.sh --dry-run

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
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

echo "▶ claudemx 설치 중..."

BIN_DIR="$HOME/.local/bin"
run mkdir -p "$BIN_DIR"

# PATH 확인
if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
  echo "  ⚠ $BIN_DIR 이 PATH에 없습니다."
  if $DRY_RUN; then
    echo "  [DRY-RUN] ~/.zshrc 에 export PATH=\"\$HOME/.local/bin:\$PATH\" 추가"
  else
    echo '# claudemx' >> "$HOME/.zshrc"
    echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$HOME/.zshrc"
    export PATH="$BIN_DIR:$PATH"
    echo "  ✓ PATH 설정 완료"
  fi
fi

# claudemx 스크립트 복사
run cp "$REPO_ROOT/bin/claudemx" "$BIN_DIR/claudemx"
run chmod +x "$BIN_DIR/claudemx"
echo "  ✓ claudemx 설치 완료 → $BIN_DIR/claudemx"

# zsh 자동완성 설치
echo ""
echo "▶ zsh 자동완성 설정 중..."

COMPLETION_DIR="$HOME/.local/share/zsh/completions"
run mkdir -p "$COMPLETION_DIR"
run cp "$REPO_ROOT/bin/_claudemx" "$COMPLETION_DIR/_claudemx"
echo "  ✓ zsh 자동완성 파일 복사 완료"

# .zshrc에 fpath 추가
ZSHRC="$HOME/.zshrc"

if grep -q "local/share/zsh/completions" "$ZSHRC" 2>/dev/null; then
  echo "  ✓ fpath가 이미 설정되어 있습니다."
elif $DRY_RUN; then
  echo "  [DRY-RUN] ~/.zshrc 에 fpath=(~/.local/share/zsh/completions \$fpath) 추가"
else
  if grep -q 'source $ZSH/oh-my-zsh.sh' "$ZSHRC"; then
    sed -i '' 's|source $ZSH/oh-my-zsh.sh|# claudemx 자동완성\nfpath=(~/.local/share/zsh/completions $fpath)\n\nsource $ZSH/oh-my-zsh.sh|' "$ZSHRC"
  elif grep -q "compinit" "$ZSHRC"; then
    sed -i '' 's|compinit|fpath=(~/.local/share/zsh/completions $fpath)\ncompinit|' "$ZSHRC"
  else
    echo '' >> "$ZSHRC"
    echo '# claudemx 자동완성' >> "$ZSHRC"
    echo 'fpath=(~/.local/share/zsh/completions $fpath)' >> "$ZSHRC"
    echo 'autoload -Uz compinit && compinit' >> "$ZSHRC"
  fi
  echo "  ✓ fpath 설정 완료"
fi

echo ""
if $DRY_RUN; then
  echo "  DRY-RUN 완료. 실제 설치하려면 --dry-run 없이 실행하세요."
else
  echo "  ✓ 설치 완료! 새 터미널을 열거나 'source ~/.zshrc' 후 사용하세요."
  echo ""
  echo "  사용법:"
  echo "    claudemx --orchestration --teammates 3"
  echo "    claudemx --agent 4"
  echo "    claudemx --help"
fi
