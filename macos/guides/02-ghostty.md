# Ghostty 설치 및 설정

## 설치

```bash
brew install --cask ghostty
```

## 설정 파일 위치

```
~/.config/ghostty/config
```

## 추천 설정

아래는 추천 설정 예시입니다. 취향에 맞게 수정하여 사용하세요.

```ini
# ~/.config/ghostty/config

# ── 폰트 ──────────────────────────────────────────
# 메인 폰트 설정 (원하는 폰트로 변경하세요)
font-family = Monaco
# Nerd Font (아이콘 지원, 없으면 생략)
# font-family = MesloLGS Nerd Font Mono
# 한글 폰트 (macOS 기본 한글 폰트)
font-family = Apple SD Gothic Neo
font-size = 14

# ── 테마 ──────────────────────────────────────────
# 내장 테마 목록: ghostty +list-themes
theme = Atom One Dark

# ── 창 설정 ───────────────────────────────────────
window-padding-x = 8
window-padding-y = 4
window-decoration = true
macos-titlebar-style = tabs

# ── 커서 ──────────────────────────────────────────
cursor-style = block
cursor-style-blink = true

# ── 클립보드 ──────────────────────────────────────
clipboard-read = allow
clipboard-write = allow
copy-on-select = clipboard

# ── 쉘 통합 ───────────────────────────────────────
shell-integration = zsh
```

## 폰트 추천

| 폰트 | 설명 | 설치 |
|------|------|------|
| [JetBrains Mono](https://www.jetbrains.com/legalnotice/fonts/) | 코딩용, 가독성 좋음 | `brew install --cask font-jetbrains-mono` |
| [Fira Code](https://github.com/tonsky/FiraCode) | 리가처 지원 | `brew install --cask font-fira-code` |
| [MesloLGS Nerd Font](https://github.com/romkatv/powerlevel10k#fonts) | Nerd Font, 아이콘 지원 | 링크에서 수동 설치 |

한글 폰트는 macOS 기본 내장 폰트를 사용하는 것을 추천합니다:
- `Apple SD Gothic Neo` — macOS 기본 한글 폰트

## 테마 확인

```bash
# 사용 가능한 테마 목록 확인
ghostty +list-themes

# 사용 가능한 폰트 목록 확인
ghostty +list-fonts
```

## 한글 입력 관련

터미널에서 한글 입력 시 자음/모음 조합 과정이 인라인으로 표시됩니다(밑줄). 이는 macOS IME의 특성으로 정상 동작입니다.
