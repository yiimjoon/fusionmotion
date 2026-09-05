# 6개 프리셋 코드 리뷰

## v0.1.0 배포 수정 — 2026-09-05

아래는 수정 전 리뷰 기록이다. v0.1.0에서는 Pro 네 방향의 SoftnessCalc를 덧셈으로 수정하고, PosterizeFrames에 허용 하한 1과 시간 표현식의 max(1, 값) 방어를 적용했다. 기존 TimeStretcher 및 공개 컨트롤 구조는 유지했다.

수정된 원본을 Resolve의 새 숨겨진 컴포지션으로 각각 로드했다. 6개 프리셋의 공개 입력 총 107개와 텍스트 전달 검사를 통과했다. 네 Pro 모두 220프레임의 블러 계산 및 Follower X/Y 값이 2.9166667로 일치했다. 프레임 홀드 0, -1, 1, 2, 12에서 11프레임의 시간 평가가 각각 11, 11, 11, 10, 0으로 확인됐다. 검사 스크립트는 이제 이 조건을 assertion으로 검증한다.

[수정 후 호스트 검사 출력](release-host-results.txt). 렌더 및 실제 Edit 클립의 시각 검사는 수행하지 않았다. 아래의 미수정 설명과 진단 로그는 이전 리뷰 시점에 해당한다.

검토 기준: `99b68a7` (Fusion Motion 저장소 정리 및 CodexTypo 추가 후).
검증 호스트: Resolve 21.0.0b.20, 내장 Lua 실행기.

## 확인된 결함

### P2 — Pro 네 방향 버전의 Outro Blur가 퇴장 구간에서 0으로 제한됨

파일: `package/Edit/Titles/Codex Rise Fade Pro.setting` 및 Left / Right / Down.
위치: 각 파일 362–374행, 특히 368행 `SoftnessCalc.Operator = 1`.

Calculation의 Operator 1은 빼기다. 현재 노드는 `IntroBlur - OutroBlur`를 계산해서 Follower의 SoftnessX1 / SoftnessY1로 보낸다. 퇴장 시 IntroBlur는 0이므로 음수가 되고, Softness 입력에서는 0으로 제한된다. 따라서 노출된 Outro Blur 컨트롤이 의도한 퇴장 블러를 만들지 못한다.

0–239프레임의 새 임시 컴포지션, 기본 설정에서 220프레임 값:

| 값 | 현재 | 임시 컴포지션에서 Operator=0 적용 |
|---|---:|---:|
| OutroBlur 출력 | 2.9166667 | 2.9166667 |
| SoftnessCalc 출력 | -2.9166667 | 2.9166667 |
| Follower SoftnessX1 | 0 | 2.9166667 |

네 파일 모두 같은 결과를 재현했다. 권장 수정은 이 계산 노드만 덧셈인 Operator 0으로 바꾸는 것이다. OpacityCalc의 곱셈 Operator 2는 이 문제와 무관하므로 바꾸지 않는다.

### P2 — Pro 네 방향 버전의 Stop Motion Frames에 0을 입력하면 시간 표현식이 실패함

위치: 각 파일 190–203행. `INP_MinScale=1`은 슬라이더 표시 범위이며 강제 하한이 아니다. `INP_MinAllowed`가 없고, SourceTime 표현식은 그대로 PosterizeFrames로 나눈다.

호스트 검사에서 PosterizeFrames에 0이 저장됐고 `SourceTime[10]`은 nil이었다. 정상 값 1에서는 10을 반환했다. Inspector 숫자 직접 입력이나 스크립트에서 0이 들어가면 시간 평가가 실패할 수 있다. 이미지 렌더는 실행하지 않았으므로 구체적인 화면 증상은 단정하지 않는다.

권장 수정은 허용 하한 1과 표현식 방어를 함께 두는 것이다. 예: 분모와 곱셈에 모두 `max(1, PosterizeFrames)`를 사용한다. 새 그래프의 기본은 native Stop Motion이며, 기존 매크로를 그 노드로 교체할 경우 공개 컨트롤과 기존 인스턴스 호환성을 별도 확인한다.

## 파일별 결과

| 파일 | 결과 |
|---|---|
| Codex Rise Fade Pro | 위 두 결함 재현 |
| Codex Rise Fade Pro Left | 동일 두 결함 재현 |
| Codex Rise Fade Pro Right | 동일 두 결함 재현 |
| Codex Rise Fade Pro Down | 동일 두 결함 재현 |
| Codex Rise Fade Image | 검사 범위에서 추가 결함 미확인. 유지됨 |
| CodexTypo | 검사 범위에서 추가 결함 미확인. GroupOperator와 기존 단어 리빌 유지됨 |

## 통과한 검사와 오해하면 안 되는 부분

- 6개 모두 Resolve의 bmd.readfile 파싱과 내부 SourceOp 참조 검사 통과.
- 실제 숨겨진 컴포지션으로 로드하여 공개 입력을 확인했다. Pro는 각각 20개, Image는 7개, CodexTypo는 20개이며 없는 입력 참조는 없었다.
- Pro의 Text 컨트롤은 Text1.StyledText를 가리키지만 실제로 텍스트를 바꿔도 Follower 연결이 유지됐고 Follower.Text 값이 갱신됐다. 연결을 끊는 결함이라고 판단하지 않았다.
- Image 내부 MediaOut에는 현재 호스트에서 실제 Output 포트가 있었다. 출력이 없는 sink라고 추측해 결함으로 판단하지 않았다.
- Pro 네 파일은 그룹 이름과 방향 좌표 외에 동일했다. 좌우·상하 출발 좌표는 서로 다른 축/방향으로 정의돼 있다.
- Pro의 LUTLookup은 Back 이징을 적용한다. 내부 LinearLookup과 직선 PolyPath의 Linear 플래그만 보고 애니메이션 전체가 리니어라고 판단하지 않았다.
- CodexTypo Text 편집이 Follower2_1.Text에 반영됐다. 베이스 Opacity6는 0/8/16프레임에서 0/0.875/1이었다.
- CodexTypo Text+는 UseFrameFormatSettings=1이고, 1080×1920 임시 컴포지션에서 실제 Width/Height가 1080/1920으로 따라왔다.

## 제한 및 추가 시각 검증

- CodexTypo의 기본 리빌은 0–16프레임, Delay는 20/27/41프레임의 고정 키다. 아주 짧은 클립이나 단어가 많은 문장에 자동으로 재분배되는 구조가 아니다. 이는 README에 명시한 사용 조건이며 이번 리뷰에서 새 회귀 결함으로 분류하지 않았다.
- 폰트 대체, 긴 한글/여러 줄 마스크, 극단적인 글자 지연, Edit 페이지의 실제 영상에 Image 효과를 드래그한 결과는 별도 시각 검증이 필요하다.
- 프레임 범위 변경 직후 같은 LUT를 반복 평가한 초기 실험은 캐시 영향 가능성이 있어 속도·길이 일반화의 근거에서 제외했다. 확정한 블러 결함은 새 컴포지션의 단일 0–239 범위에서 재현했다.
- **렌더하지 않았다.** 호스트의 숫자 입력·출력과 연결을 검사하고 임시 컴포지션을 저장 없이 닫았다. 사용자 로켓 프로젝트와 배경 Transform1의 1.323 값은 보존됐다.
- 결함 수정은 임시 컴포지션에서만 시험했다. 검토 대상 배포 파일의 동작은 이번 리뷰 커밋에서 변경하지 않았다.

## 재현

Resolve가 실행 중일 때 `scripts/review_presets.lua`를 Resolve의 fuscript.exe로 실행한다. 이 스크립트는 저장소 경로를 스스로 찾고, 실제 타임라인 대신 숨겨진 임시 컴포지션을 사용한다.

```powershell
& '<Resolve 설치 폴더>/fuscript.exe' -l lua '<저장소>/scripts/review_presets.lua'
```

[호스트 검증 출력](review-host-results.txt)에 확정 결과를 보관했다. 결과의 `ZERO_HOLD_PROBE`와 `OUTRO_BLUR`는 의도적으로 결함 조건을 검사하는 진단이며 통과 주장으로 읽으면 안 된다.
