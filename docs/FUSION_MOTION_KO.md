# Fusion 모션 제작 지식

2026-09-05, Resolve 21.0.0b.20의 실제 콜라주 로켓 작업에서 확인했다. 다른 버전과 플러그인에서는 재검증한다.

## 연출과 그래프

대본 → B롤 구도·어셋 계획 → 이미지젠 FG/BG → 알파 확인 → Fusion 합성 → 로컬 움직임 → 글로벌 카메라 움직임 순서로 작업한다. 설명은 보이스오버와 자막에 맡기고 B롤에는 불필요한 글자를 넣지 않는다.

움직임마다 Transform 하나를 둔다. 로켓은 Layout → Entry → Wobble → Launch → Tilt → Recede, 배경과 합성한 다음 Global Pan → Global Zoom으로 구성했다. 순서가 결과를 바꾼다. 이동 후 축소하면 이동 거리까지 줄어드는 점을 고려한다.

**글로벌 이동 전에 배경 overscan을 확보한다.** 화면에 딱 맞는 배경은 팬·회전 시 잘린다. 사용자가 배경 뒤 Transform을 추가해 Size 1.323으로 보정했다. 이는 해당 장면의 값이며 모든 장면에 맞는 상수가 아니다. 최대 팬·회전·줌아웃에서 경계가 드러나지 않는지 확인한다.

1080×1920·24fps가 기본 제작 의도지만 부모 타임라인과 FrameFormat을 각각 읽는다. 이번 부모 타임라인은 23.976fps, Fusion FrameFormat은 24fps였다. 6초 애니메이션을 만들었다고 클립 전체 길이를 제한하면 안 된다. RenderStart/RenderEnd를 GlobalStart/GlobalEnd에 맞춘다. 동작 종료 후 최종 포즈를 유지한다.

## 이미지

사용자는 SVG보다 **이미지젠 어셋을 선호**한다. 투명 PNG는 실제 alpha 채널을 확인한다. 원형 달 PNG를 균일 축소해 사용했다. Fusion EllipseMask Height에 1080/1920을 다시 곱해 달이 눌렸던 오류가 있었다. 해당 노드에서는 Width=Height로 수정했고, 최종적으로 이미지젠 달로 교체했다.

어셋은 프로젝트 폴더에 저장한다. 다른 PC에서는 경로를 다시 지정할 수 있도록 컴포지션과 함께 관리한다.

## Lua 연결과 노드 생성

현재 PC에서는 Resolve 내장 fuscript.exe로 Lua 연결이 성공했다. 외부 Python 3.14 호출은 정상 결과 없이 종료했다. Python 실패나 과거 연결 실패를 현재 Lua 연결 불가로 일반화하지 않는다.

```lua
local resolve = assert(bmd.scriptapp('Resolve'))
local project = resolve:GetProjectManager():GetCurrentProject()
local timeline = project:GetCurrentTimeline()
local item = timeline:GetCurrentVideoItem()
local comp = assert(item:GetFusionCompByIndex(1))
```

Fusion():GetCurrentComp()가 nil이어도 위 경로로 컴포지션을 얻었다. AddTool 전 **comp:SetActiveTool(nil)**로 활성 노드를 비운다. 그렇지 않으면 Merge 자동 생성이나 기존 Merge의 EffectMask에 다음 마스크가 붙는 일이 생긴다. ConnectInput으로 연결을 명시하고 읽어서 확인한다.

StartUndo → Lock → pcall 작업 → Unlock → EndUndo로 감싼다. 오류 때도 Unlock을 실행한다. 성공 후 컴포지션과 Resolve 프로젝트를 모두 저장한다. 사용자가 추가한 Transform1 등은 임의로 삭제하지 않는다.

## 베지어

진입은 감속·작은 오버슈트, 발사는 가속, 정착과 카메라는 부드러운 감속 등으로 구분한다. 정속 구간이나 홀드까지 모두 곡선으로 바꾸지 않는다. LUTLookup의 easing이 적용된다면 내부 직선 PolyPath나 선형 기준 LUT가 곧 선형 시간 움직임이라는 뜻은 아니다.

**SetKeyFrames의 LH/RH는 상대 오프셋, 저장된 .setting/.comp의 LH/RH는 절대 좌표**다. 파일 좌표를 함수에 그대로 전달하면 시간·값이 두 번 더해져 크기와 위치가 튄다.

```lua
-- 이 작업이 소유한 spline에만 기존 키 전체 삭제를 적용한다.
spline:DeleteKeyFrames(-1000000, 1000000)
spline:SetKeyFrames({
    [0]  = {0, RH={8, 0}, Flags={Linear=false}},
    [24] = {1, LH={-8, 0}, Flags={Linear=false}},
}, true)
```

저장 파일에서는 끝 키의 LH가 {16,1}로 나타난다. 키 작성 후 시작·중간·끝 값과 구간 최솟값/최댓값을 검사한다. Center는 표현식을 제거하고 XYPath를 붙인 뒤 X/Y의 BezierSpline을 조정하면 Spline에서 편집할 수 있다.

## Stop Motion과 성능

```lua
comp:SetActiveTool(nil)
local stop = comp:AddTool('ofx.com.blackmagicdesign.resolvefx.StopMotion', -32768, -32768)
stop.frameRepeat = 2
stop.frameRepeatVar = 0
stop:ConnectInput('Source', finalTransform) -- Input이 아니라 Source
mediaOut:ConnectInput('Input', stop)
```

프록시는 사용자 요청으로 사용하지 않는다. 최종 설정은 COMPB_Proxy=false, Comp.Interactive.Proxy.Scale=1, Comp.Interactive.Proxy.Auto=false. COMPI_ProxyScale 변경은 실제 배율에 적용되지 않았다.

외부 렌더 중단, Saver·불필요한 노드 제거, FlowView 썸네일 끄기 후 사용자가 Fusion 페이지 렉 해소를 확인했다. 여러 변경을 함께 했으므로 하나를 유일한 원인이라고 단정하지 않는다. GPU 유휴 사용량 한 번만 읽고 원인을 확정하지 않는다.

**외부 데모 렌더는 밖에서 보기 위해 사용자가 요청할 때만 한다.** 다빈치 안에서 확인하는 중에는 자동으로 렌더를 시작하지 않는다.

## 검증 경계

- 파싱: 문법·SourceOp 참조·공개 컨트롤 구조.
- 호스트: 실제 노드 타입·입력 ID·연결·키 값·클립 범위.
- 시각: 현재 뷰어 또는 요청받은 출력의 구도·알파·경계.
- 사용자 확인: 로켓 움직임·달 위치·렉 해소 확인. 배경 overscan은 사용자 수정.

CodexTypo 설치 파일 교체는 기존 인스턴스를 바꾸지 않는다. 새 인스턴스의 Inspector와 내부 Text+를 별도로 확인한다.

매크로를 타임라인에 넣지 않고 검사할 때 `fusion:LoadComp(settingPath, true, true)`로 숨겨진 임시 컴포지션을 만들 수 있었다. 현재 호스트에서 comp:Paste는 문자열/테이블 모두 false를 반환했고 빈 GroupOperator의 LoadSettings는 true를 반환해도 자식 노드를 만들지 않았다. 성공 플래그 대신 실제 노드 수를 검사한다. 검증 후 COMPB_Modified=false로 지정하고 임시 comp를 Close하며 소스 .setting에는 Save하지 않는다.
