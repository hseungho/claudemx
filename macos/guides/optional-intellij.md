# (선택) IntelliJ에서 Ghostty 열기

IntelliJ에서 현재 프로젝트 디렉토리로 Ghostty를 바로 열 수 있는 External Tool 설정입니다.

## 설정 방법

1. `Settings` → `Tools` → `External Tools` → `+` 클릭
2. 아래와 같이 입력:

| 항목 | 값 |
|------|-----|
| **Name** | Open in Ghostty |
| **Program** | `/Applications/Ghostty.app/Contents/MacOS/ghostty` |
| **Arguments** | `--working-directory=$ProjectFileDir$` |
| **Working directory** | `$ProjectFileDir$` |

3. `OK` 저장

## 단축키 등록

1. `Settings` → `Keymap`
2. 검색창에 `Open in Ghostty` 입력
3. 더블클릭 → `Add Keyboard Shortcut`
4. 원하는 단축키 입력 후 `OK`

## 사용

등록한 단축키를 누르면 현재 프로젝트 루트 디렉토리에서 Ghostty가 바로 열립니다.
