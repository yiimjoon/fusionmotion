# Fusion Motion

DaVinci Resolve용 타이틀·Fusion 매크로와 실제 제작에서 검증한 모션그래픽 작업 지식입니다.

## 포함 패키지

- Titles: `Codex Rise Fade`, `Codex Rise Fade Pro`, `Codex Rise Fade Pro Left / Right / Down`
- Effects: **`Codex Rise Fade Image` 유지**
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

- [Fusion 제작 규칙과 스크립팅 검증](docs/FUSION_MOTION_KO.md)
- [6개 프리셋 코드 리뷰와 확인된 결함](docs/PRESET_REVIEW_KO.md)
- [기여 및 작업 원칙](AGENTS.md)

파싱 성공, 호스트 입력·노드 검증, 실제 렌더와 사용자 시각 확인을 구분합니다.
