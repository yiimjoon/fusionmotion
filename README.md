# Fusion Motion

DaVinci Resolve용 타이틀·Fusion 매크로와 실제 제작에서 검증한 모션그래픽 작업 지식입니다.

## 포함 패키지

- Titles: `Codex Rise Fade`, `Codex Rise Fade Pro`, `Codex Rise Fade Pro Left / Right / Down`
- Effects: **`Codex Rise Fade Image` 유지**
- Transitions: **`BQ Grid Flow`**
- Fusion/Macros/Codex: **`CodexTypo`**, `Codex Screen Pixel Overlay`, `gridanim`

원본은 `package/Edit/Titles`, `package/Edit/Effects`, `package/Fusion/Macros/Codex`에 있습니다.

## 설치

[v0.1.0 다운로드](https://github.com/yiimjoon/fusionmotion/releases/tag/v0.1.0)에서 전체 설치 ZIP을 내려받아 압축을 풀고 아래 명령을 실행합니다. CodexTypo를 포함한 Fusion 매크로가 필요하면 전체 ZIP을 사용합니다. Edit 타이틀·효과만 필요하면 별도 FusionMotion.drfx를 설치할 수 있습니다.

```powershell
.\install.ps1
```

Edit 타이틀·효과와 Fusion 매크로를 Resolve 사용자 폴더에 복사하고 `dist/FusionMotion.drfx`를 생성합니다. 로컬 설치 없이 패키지만 만들려면 `./install.ps1 -PackageOnly`를 실행합니다.

**DRFX는 Edit 타이틀·효과만 포함합니다.** CodexTypo 등 Fusion 매크로는 install.ps1로 설치하거나 `package/Fusion/Macros` 내용을 `%APPDATA%/Blackmagic Design/DaVinci Resolve/Support/Fusion/Macros`로 복사합니다.

라이브러리 새로고침 또는 Resolve 재시작 후 새 인스턴스를 삽입합니다. 파일 교체는 기존 타임라인 인스턴스를 갱신하지 않습니다. 저장소에서 제외한 프리셋의 예전 로컬 설치본은 자동 삭제하지 않습니다.

## BQ Grid Flow

Edit 페이지의 Video Transitions > BQ에서 사용하는 셀 단위 그리드 전환입니다. 가로 칸 수를 기준으로 해상도 비율에 맞춘 정사각형 셀을 자동 계산하며, 자동 모드를 끄면 세로 칸 수를 직접 지정할 수 있습니다.

- 12가지 등장 방식: 가로·세로·대각선·중앙·체커보드·랜덤 셀
- 리빌 길이와 위치, 움직임 곡선, 셀 시간차와 페이드
- 격자선 표시, 외곽선, 픽셀 굵기와 컬러 피커
- 기본 격자선 색상은 검정

효과 전후의 클립을 더 오래 보여주려면 타임라인에서 트랜지션 길이를 늘리고, 실제 셀 리빌 구간은 `리빌 길이 (프레임)`과 `리빌 위치 (앞↔뒤)`로 따로 조절합니다.

`package/Fusion/Scripts/Comp/Codex Add Screen Pixel Overlay.py`는 필요할 때 Resolve의 `Fusion/Scripts/Comp` 폴더로 수동 복사하는 보조 스크립트입니다.

## CodexTypo

Typotest의 단어별 리빌을 유지하면서 Inspector 컨트롤을 확장한 **GroupOperator**입니다. 그룹을 확장해 내부 Text+와 Follower를 수정할 수 있습니다.

- Text, Font / Style, Size / Position
- Tracking / Line Spacing, Horizontal / Vertical Alignment
- Text Color / Alpha
- Word Stagger / Word Slide / Reveal Opacity
- Reveal Mask Shape / Width / Height / Softness

기본 폰트는 Pretendard Bold입니다. 없는 환경에서는 사용 가능한 폰트로 바꿉니다. 단어 리빌에는 고정 키프레임이 포함되므로 모든 길이에 자동 대응한다고 가정하지 않습니다.

## Rise Fade 계열

- 기본 버전은 48프레임 진입을 사용하는 고정형입니다.
- Pro 네 방향 버전은 속도, 이징, 진입·퇴장 블러, 글자 지연, 모션블러, 프레임 홀드 컨트롤을 제공합니다.
- Rise Fade Image는 Edit Effects의 이미지/영상 입력에 위치·크기·진입 오프셋을 적용합니다.

## 제작 지식

- [로컬·글로벌 카메라 계층 상세 분석](docs/BQ_CAMERA_HIERARCHY_KO.md) — 두 번째 컴포지션 비교, 타이밍 분리, 카메라 영향 범위
- [BQ 스타일 분석과 다음 영상 제작 플레이북](docs/BQ_STYLE_PLAYBOOK_KO.md) — 2026-09-08 라이브 그래프의 연결·키프레임 근거와 재사용 절차
- [Fusion 제작 규칙과 스크립팅 검증](docs/FUSION_MOTION_KO.md)
- [6개 프리셋 코드 리뷰와 확인된 결함](docs/PRESET_REVIEW_KO.md)
- [기여 및 작업 원칙](AGENTS.md)

파싱 성공, 호스트 입력·노드 검증, 실제 렌더와 사용자 시각 확인을 구분합니다.
