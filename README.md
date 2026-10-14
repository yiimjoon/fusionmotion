# Fusion Motion

DaVinci Resolve용 타이틀·Fusion 매크로와 실제 제작에서 검증한 모션그래픽 작업 지식입니다.

## 포함 패키지

- Titles: `Codex Rise Fade`, `Codex Rise Fade Pro Up / Down / Left / Right`
- Titles: `Codex Rise Up / Down / Left / Right`, `Codex Scale Up / Down`, `Codex Mask Reveal Pro` — 스트로크·그림자 Inspector 컨트롤
- Effects: **`Codex Rise Fade Image` 유지**
- Transitions: **`BQ Grid Flow`**
- Fusion/Macros/Codex: **`CodexTypo`**, `Codex Screen Pixel Overlay`, `gridanim`
- Fusion macro: `Codex Monitor RGB` — RGB subpixel modulation, row gaps, radial warp and optical softness. Live viewer verified on Resolve Studio 21.1.1; final export not tested.

### Codex Monitor RGB

Connect `MediaIn → Codex Monitor RGB → MediaOut`. When a source has downstream Color-page CST/grading, first create a **Fusion Clip** and confirm the graded image reaches its MediaIn. Apply this macro in the outer Fusion composition. Adding it to the source's original Fusion composition would send the effect through the source's CST.

RGB Groups Across is the number of RGB triplets across the image (360 gives a 10.67-pixel period at 3840 width), not a pixel-size control. The user-approved close-screen preset uses RGB Strength 0.7, Row Gap Strength 0.035, Row Count 540, Subpixel Slant 0.008, Brightness Compensation 0.8, Screen Curvature 0 and Edge Overscan 1.015. Source Softness is 0 for already-filmed monitors; Optical Softness is 0.08. Blur values use Fusion units, not literal pixels. Zero RGB/row-gap/curvature/both softness controls and set overscan to 1 for neutral settings.

Screen Curvature / Fisheye supports 0–2: 0 keeps the approved flat-screen look; 1.5 gives strong barrel distortion. Positive curvature automatically crops/zooms to cover the edges, so stronger values lose more peripheral content. Typed negative values are supported down to -0.8 for the opposite bend. This is a stylized radial warp, not a calibrated optical fisheye lens model.

This is a separate expandable GroupOperator; the original overlay is unchanged. It uses channel multiplication so black remains black, warps the pattern and source together, and preserves input alpha through the Custom nodes. Extreme edges clamp to the source edge. No animation, external texture, or timeline range changes are introduced. Check at final resolution and 100% viewer scale.

Run `scripts/review_monitor_rgb.lua` for host input/connection validation; it does not render. On 2026-10-10 the macro passed host checks and the user approved the fine RGB pattern in the live Fusion viewer on a 3840×2160 graded Fusion Clip. Custom Tool trigonometric expressions use **degrees** (`360` per cycle), unlike Lua `math.cos`; the original radians-based draft produced broad bands and was corrected. Full playback/final export are not yet validated. The macro is not included in the Edit-only DRFX.

After exporting a composition snapshot, invoke `scripts/insert_monitor_rgb.lua` inside the target comp with `comp:Execute("dofile([[absolute/path/to/insert_monitor_rgb.lua]])")`. Host-context paste creates an expandable group and one Fusion undo event. The helper does not create a Fusion Clip or move grading for you.

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

## Rise / Scale / Mask Reveal 스타일 컨트롤

Rise 네 방향, Scale Up/Down, Mask Reveal Pro의 새 인스턴스에서 다음 항목을 조절합니다.

- 스트로크: 켜기, 두께, 색상, 불투명도
- 그림자: 켜기, 색상, 불투명도, 위치, 블러

기본값은 둘 다 꺼짐입니다. 기존 모션·폰트·텍스트와 Follower를 유지하며 별도 이미지 렌더 노드를 추가하지 않습니다. 스트로크·그림자는 글자의 페이드를 따르고, Mask Reveal에서는 기존 Follower의 이동·블러도 공유합니다. 파일 교체는 이미 배치한 클립에 자동 적용되지 않으므로 새 프리셋 인스턴스를 넣습니다.

2026-09-30: 7개 전부 Resolve 21.1 숨겨진 임시 컴포지션에서 13개 공개 입력, 값 전달, 기존 노드·파라미터 보존과 5개 프레임의 페이드 동기화를 검사했습니다. 렌더·화면 시각 확인은 별도입니다. Codex Shin Yebin Color Cycle, 1 Minute Countdown, Slot Price는 이 패키지의 지원 목록에 포함하지 않습니다.

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
