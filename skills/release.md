---
description: claudemx 릴리스 자동화. 변경 내용 분석 → 릴리스 노트 생성 → 태그 → push → GitHub Release 생성까지 전체 과정을 수행한다.
---

# claudemx Release

사용자가 `/release` 또는 릴리스를 요청하면 아래 절차를 순서대로 수행한다.

## 인자

- `$ARGUMENTS`에 버전이 포함되어 있으면 해당 버전을 사용한다. (예: `/release v0.0.3`)
- 버전이 없으면 마지막 태그에서 patch를 +1한 버전을 제안하고 사용자에게 확인받는다.

## 절차

### 1단계: 사전 검증

아래 항목을 모두 확인한다. 하나라도 실패하면 중단하고 사용자에게 안내한다.

- [ ] 버전 형식이 `vX.Y.Z`인지 확인
- [ ] 해당 태그가 이미 존재하지 않는지 확인: `git tag -l <version>`
- [ ] 커밋되지 않은 변경사항이 없는지 확인: `git status`
- [ ] `gh` CLI가 설치되어 있는지 확인
- [ ] 현재 브랜치가 `main`인지 확인

만약 커밋되지 않은 변경사항이 있으면, 사용자에게 먼저 커밋할지 물어본다.

### 2단계: 변경 내용 분석

마지막 태그 이후의 커밋들을 분석한다:

```bash
# 마지막 태그 찾기
git describe --tags --abbrev=0

# 마지막 태그 이후 커밋 목록
git log <last-tag>..HEAD --oneline

# 변경된 파일 목록
git diff <last-tag>..HEAD --stat
```

커밋 메시지와 변경된 파일을 바탕으로 변경 내용을 파악한다.

### 3단계: 릴리스 노트 생성

아래 형식으로 릴리스 노트를 작성한다. **반드시 사용자에게 보여주고 확인받은 후 다음 단계로 진행한다.**

```markdown
## <version> - <한줄 설명>

### 새 기능
- (해당 시)

### 개선
- (해당 시)

### 버그 수정
- (해당 시)

### 업데이트 방법

\`\`\`bash
claudemx --update
\`\`\`
```

규칙:
- 제목(`##`)에 버전과 한줄 설명을 포함한다.
- 변경이 없는 카테고리는 생략한다.
- 각 항목은 `**기능명**` — 설명 형식으로 작성한다.
- "업데이트 방법" 섹션은 항상 포함한다.

### 3.5단계: VERSION 변수 업데이트

`bin/claudemx`의 VERSION 변수를 새 버전으로 업데이트하고 커밋한다:

```bash
# bin/claudemx의 VERSION 변수 업데이트
sed -i '' "s/^VERSION=\"v[0-9]*\.[0-9]*\.[0-9]*\"/VERSION=\"<version>\"/" bin/claudemx

# 변경 커밋
git add bin/claudemx
git commit -m "chore: bump VERSION to <version>"
```

### 4단계: 릴리스 실행

사용자 확인을 받은 후 아래를 순서대로 실행한다:

```bash
# 태그 생성
git tag <version>

# push (main 브랜치 + 태그)
git push origin main <version>

# GitHub Release 생성 (제목은 태그만, 본문은 릴리스 노트)
gh release create <version> --title "<version>" --notes "<릴리스 노트>"
```

### 5단계: 로컬 설치본 동기화

```bash
cp bin/claudemx ~/.local/bin/claudemx
chmod +x ~/.local/bin/claudemx
cp bin/_claudemx ~/.local/share/zsh/completions/_claudemx
```

### 6단계: 완료 보고

릴리스 URL을 포함하여 결과를 보고한다:

```
✓ <version> 릴리스 완료!
  https://github.com/hseungho/claudemx/releases/tag/<version>
```
