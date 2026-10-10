-- Host input/connection checks only: no render, no timeline changes, no save.
local source=debug.getinfo(1,'S').source:sub(2):gsub('\\','/')
local root=assert(source:match('^(.*)/scripts/[^/]+$'))
local file=root..'/package/Fusion/Macros/Codex/Codex Monitor RGB.setting'
local data=assert(bmd.readfile(file),'Parse failed')
local def=assert(data.Tools.CodexMonitorRGB)
local r=assert(bmd.scriptapp('Resolve'),'Resolve scripting unavailable')
local c=assert(r:Fusion():LoadComp(file,{Quiet=true,AutoClose=true,Hidden=true}))
local ok,err=pcall(function()
 for name,control in pairs(def.Inputs) do
  if type(control)=='table' then
  local tool=assert(c:FindTool(control.SourceOp),'Missing tool '..control.SourceOp)
  local found=false
  for _,inp in pairs(tool:GetInputList()) do
   if inp:GetAttrs().INPS_ID==control.Source then found=true end
  end
  assert(found,'Missing control '..name..' -> '..control.Source)
  end
 end
 for _,name in ipairs({'SourceSoftness','PixelRGB','ScreenWarp','OpticalSoftness'}) do
  assert(c:FindTool(name),'Missing node '..name)
 end
 assert(c:FindTool('PixelRGB').Image1:GetConnectedOutput():GetTool():GetAttrs().TOOLS_Name=='SourceSoftness')
 local warp=c:FindTool('ScreenWarp')
 assert(warp.Image1:GetConnectedOutput():GetTool():GetAttrs().TOOLS_Name=='PixelRGB')
 local blur=c:FindTool('OpticalSoftness')
 assert(blur.Input:GetConnectedOutput():GetTool():GetAttrs().TOOLS_Name=='ScreenWarp')
 print('MONITOR_RGB_INPUTS_AND_CONNECTIONS_OK_NO_RENDER')
end)
c:SetAttrs({COMPB_Modified=false});c:Close()
assert(ok,err)
