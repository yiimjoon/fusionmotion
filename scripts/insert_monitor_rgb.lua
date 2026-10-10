-- Execute inside the intended Fusion composition with comp:Execute + dofile.
-- Uses the packaged macro as the single source of expression/default values.
local source=debug.getinfo(1,'S').source:sub(2):gsub('\\','/')
local root=assert(source:match('^(.*)/scripts/[^/]+$'),'Cannot locate repository')
local c=assert(comp,'Run this script inside a Fusion composition')
local macroPath=root..'/package/Fusion/Macros/Codex/Codex Monitor RGB.setting'
local definition=assert(bmd.readfile(macroPath)).Tools.CodexMonitorRGB
local output=assert(c:FindTool('MediaOut1'),'No MediaOut1')
local oldOutput=assert(output.Input:GetConnectedOutput(),'MediaOut1 has no input')
assert(not c:FindTool('CodexMonitorRGB'),'Monitor RGB already exists')
assert(not c:FindTool('MonitorRGB_PixelRGB'),'Monitor RGB already exists')
local before={}
for _,tool in pairs(c:GetToolList(false)) do before[tool:GetAttrs().TOOLS_Name]=true end
local created={}
c:StartUndo('Add Codex Monitor RGB')
c:Lock()
local ok,err=pcall(function()
 c:SetActiveTool(nil)
 -- Paste is reliable when executed in the host composition context.
 c:Paste(bmd.readfile(macroPath))
 local group=c:FindTool('CodexMonitorRGB')
 if group then
  assert(c:FindTool('PixelRGB') and c:FindTool('ScreenWarp'),'Incomplete macro')
  assert(group:ConnectInput('MainInput1',oldOutput),'Cannot connect macro input')
  assert(output:ConnectInput('Input',group),'Cannot connect output')
  c:SetActiveTool(group)
 else
  -- Some hosts reject GroupOperator paste: create the identical editable chain.
  local names={'SourceSoftness','PixelRGB','ScreenWarp','OpticalSoftness'}
  local kinds={SourceSoftness='Blur',PixelRGB='Custom',ScreenWarp='Custom',OpticalSoftness='Blur'}
  for index,name in ipairs(names) do
   c:SetActiveTool(nil)
   local tool=assert(c:AddTool(kinds[name],-32768,-32768))
   tool:SetAttrs({TOOLS_Name='MonitorRGB_'..name})
   created[name]=tool
   for input,value in pairs(definition.Tools[name].Inputs) do
    if type(value)=='table' and value.Value~=nil then tool:SetInput(input,value.Value) end
   end
   c.CurrentFrame.FlowView:SetPos(tool,index*2,1)
  end
  for name,tool in pairs(created) do
   for input,value in pairs(definition.Tools[name].Inputs) do
    if type(value)=='table' and value.SourceOp then
     assert(tool:ConnectInput(input,created[value.SourceOp]),'Cannot connect '..name)
    end
   end
  end
  assert(created.SourceSoftness:ConnectInput('Input',oldOutput))
  assert(output:ConnectInput('Input',created.OpticalSoftness))
  c:SetActiveTool(created.PixelRGB)
 end
end)
if not ok then
 output:ConnectInput('Input',oldOutput)
 for _,tool in pairs(c:GetToolList(false)) do
  if not before[tool:GetAttrs().TOOLS_Name] then c:DeleteTool(tool) end
 end
end
c:Unlock()
c:EndUndo(ok)
assert(ok,err)
print('MONITOR_RGB_INSERTED_UNDOABLE')
