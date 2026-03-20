#!/bin/bash
# skills/ 디렉토리의 스킬들을 로컬 .claude/commands/ 에 복사
# 사용법:
#   bash scripts/install-skills.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
SKILLS_SRC="$REPO_ROOT/skills"
SKILLS_DEST="$REPO_ROOT/.claude/commands"

if [[ ! -d "$SKILLS_SRC" ]]; then
  echo "오류: skills/ 디렉토리를 찾을 수 없습니다."
  exit 1
fi

mkdir -p "$SKILLS_DEST"

COUNT=0
for file in "$SKILLS_SRC"/*.md; do
  [[ -f "$file" ]] || continue
  cp "$file" "$SKILLS_DEST/"
  COUNT=$((COUNT + 1))
  echo "  ✓ $(basename "$file")"
done

if [[ $COUNT -eq 0 ]]; then
  echo "설치할 스킬이 없습니다."
else
  echo ""
  echo "$COUNT개 스킬 설치 완료 → $SKILLS_DEST/"
fi
