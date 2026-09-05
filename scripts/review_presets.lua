-- Run with Resolve's fuscript.exe -l lua <absolute path to this file>.
-- Hidden temporary comps only. Does not render, save templates or modify timelines.
local source=debug.getinfo(1,'S').source:sub(2):gsub('\\','/')
local root=assert(source:match('^(.*)/scripts/[^/]+$'),'Cannot locate repository')..'/'
local files={
 'package/Edit/Titles/Codex Rise Fade Pro.setting',
 'package/Edit/Titles/Codex Rise Fade Pro Left.setting',
 'package/Edit/Titles/Codex Rise Fade Pro Right.setting',
 'package/Edit/Titles/Codex Rise Fade Pro Down.setting',
 'package/Edit/Effects/Codex Rise Fade Image.setting',
 'package/Fusion/Macros/Codex/CodexTypo.setting',
}
local resolve=assert(bmd.scriptapp('Resolve'),'Resolve is not reachable')
local fusion=resolve:Fusion()
local failures=0
for _,file in ipairs(files) do
 local data=assert(bmd.readfile(root..file),'Parse failed: '..file)
 local groupName,definition
 for name,value in pairs(data.Tools) do
  if type(value)=='table' and value.Tools then groupName=name;definition=value end
 end
 local comp=assert(fusion:LoadComp(root..file,true,true),'Cannot load hidden comp: '..file)
 comp:Lock()
 local ok,err=pcall(function()
  comp:SetPrefs({['Comp.FrameFormat.Width']=1080,['Comp.FrameFormat.Height']=1920,['Comp.FrameFormat.Rate']=24})
  comp:SetAttrs({COMPN_GlobalStart=0,COMPN_GlobalEnd=239,COMPN_RenderStart=0,COMPN_RenderEnd=239})
  local group=assert(comp:FindTool(groupName))
  local checked=0
  for key,def in pairs(definition.Inputs) do
   if type(def)=='table' and def.SourceOp then
    local target=assert(comp:FindTool(def.SourceOp));local found=false
    for _,input in pairs(target:GetInputList()) do
     if input:GetAttrs().INPS_ID==def.Source then found=true end
    end
    assert(found,'Missing input '..key..' -> '..def.SourceOp..'.'..def.Source)
    checked=checked+1
   end
  end
  print('PORTS_OK',file,checked)
  local follower=comp:FindTool('Follower1') or comp:FindTool('Follower2_1')
  if follower then
   for _,input in pairs(group:GetInputList()) do
    local attrs=input:GetAttrs()
    if attrs.INPS_Name=='Text' then group:SetInput(attrs.INPS_ID,'REVIEW TEXT PROBE') end
   end
   assert(tostring(follower.Text[0])=='REVIEW TEXT PROBE','Text control did not reach Follower')
   print('TEXT_CONTROL_OK',file)
  end
  local calc=comp:FindTool('SoftnessCalc')
  if calc then
   local function number(name,frame) return comp:FindTool(name):GetOutputList()[1]:GetValue(frame) end
   print('OUTRO_BLUR',file,'source',number('OutroBlur',220),'calculation',number('SoftnessCalc',220),'effective',follower.SoftnessX1[220])
   calc.Operator=0
   print('ADD_OPERATOR_PROBE',file,number('SoftnessCalc',220),follower.SoftnessX1[220])
  end
  local poster=comp:FindTool('TimeStretcher1')
  if poster then
   poster.PosterizeFrames=0
   print('ZERO_HOLD_PROBE',file,poster.PosterizeFrames[0],tostring(poster.SourceTime[10]))
  end
  local text=comp:FindTool('Text1_2')
  if text then print('TYPO_FORMAT',text.Width[0],text.Height[0]);print('TYPO_BASE_ALPHA',follower.Opacity6[0],follower.Opacity6[8],follower.Opacity6[16]) end
 end)
 comp:Unlock();comp:SetAttrs({COMPB_Modified=false});comp:Close()
 if not ok then failures=failures+1;print('HARNESS_ERROR',file,tostring(err)) end
end
assert(failures==0,'Some host checks did not complete')
print('REVIEW_COMPLETE_NO_RENDERS')
