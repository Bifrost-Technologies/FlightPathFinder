local F=FlightPathFinder
function F:StopPath(reason)
 self.pathGeneration=(self.pathGeneration or 0)+1
 if self.cancelPath then self.cancelPath();self.cancelPath=nil end
 self.path=nil;self.pathIndex=nil;self.pathStatus=reason
 for _,line in ipairs(self.pathLines or {})do line:Hide()end
 if self.pathHUD then self.pathHUD:Hide()end
end
function F:RouteTo(node)
 self:StopPath('Select a flight master to plan a walking route.')
 if not self.db.pathing or not node then return false end
 local N=WorldNavigation
 if not N then self.pathStatus='Enable WorldNavigation for road and terrain routing.';return false end
 local from=N:Position();local vector=self:Call(CreateVector2D,node.x,node.y)
 local map,world=self:Call(C_Map and C_Map.GetWorldPosFromMapPos,node.map,vector)
 local x,y;if world and world.GetXY then x,y=self:Call(world.GetXY,world)end
 if not from or not N:Finite(x)or not N:Finite(y)or map~=from.map then self.pathStatus='World coordinates unavailable or destination is on another continent.';return false end
 local destination={x=x,y=y,map=map}
 -- A flight master personally visited supplies a confirmed standing height.
 local known=self.character.approaches and self.character.approaches[node.id]
 if known and known.map==map and math.abs(known.x-x)<30 and math.abs(known.y-y)<30 then destination=N:Copy(known)end
 self.selected=node.id;self.pathStatus='Planning a road-preferred terrain route…'
 local generation=self.pathGeneration;self.pathOrigin=from;self.pathRequested=GetTime()
 self.cancelPath=N:Request(from,destination,function(route,reason)
  if self.pathGeneration~=generation or not self.db.pathing then return end
  self.path=route;self.pathIndex=2
  self.pathStatus=route and ('Follow the mapped approach to '..node.name..'. '..route.source)or reason
  self:Refresh();self:RenderPath()
 end)
 return true
end
function F:RenderPath()
 self.pathLines=self.pathLines or {};for _,line in ipairs(self.pathLines)do line:Hide()end
 local map=WorldMapFrame
 if not self.db.pathing or not self.path or not map or not map:IsShown()or not map.GetCanvas or (map.IsForbidden and map:IsForbidden())then return end
 local canvas=map:GetCanvas();if not canvas or not canvas.CreateLine then return end
 local id=map:GetMapID();local width,height=self:Call(canvas.GetWidth,canvas),self:Call(canvas.GetHeight,canvas)
 if not self:Number(width,1,100000)or not self:Number(height,1,100000)then return end
 local function project(p)
  local v=self:Call(CreateVector2D,p.x,p.y)
  local which,pos=self:Call(C_Map and C_Map.GetMapPosFromWorldPos,p.map,v,id)
  if which==id then return self:Vector(pos)end
 end
 local points=self.path.points;local count=0
 for i=math.max(2,self.pathIndex or 2),math.min(#points,(self.pathIndex or 2)+399)do
  local ax,ay=project(points[i-1]);local bx,by=project(points[i])
  if ax and bx then
   count=count+1;local line=self.pathLines[count]
   if not line then line=canvas:CreateLine(nil,'OVERLAY');if not line then return end;self.pathLines[count]=line end
   line:SetParent(canvas);line:SetThickness(3);line:SetColorTexture(.2,.75,1,.9)
   line:SetStartPoint('TOPLEFT',canvas,ax*width,-ay*height);line:SetEndPoint('TOPLEFT',canvas,bx*width,-by*height);line:Show()
  end
 end
end
function F:UpdatePath()
 if not self.db.pathing or not self.path or not WorldNavigation then return end
 local N=WorldNavigation;local p=N:Position()
 if not p then if self.pathHUD then self.pathHUD:Hide()end;self.pathStatus='Position unavailable; guidance paused.';return end
 local points=self.path.points;local nextPoint=points[self.pathIndex]
 if not nextPoint or p.map~=nextPoint.map then self:StopPath('Route ended or map changed. Select the flight master again.');return end
 while N:Distance(p,nextPoint)<=1.5 do
  self.pathIndex=self.pathIndex+1;nextPoint=points[self.pathIndex]
  if not nextPoint then self:StopPath('Approach reached. Find and speak to the flight master.');return end
 end
 local distance=N:SegmentDistance(p,points[self.pathIndex-1],nextPoint)
 if distance>25 and GetTime()-(self.pathRequested or 0)>5 then self:RouteTo(self.nodes[self.selected]);return end
 if not self.pathHUD then
  local hud=CreateFrame('Frame','FlightPathFinderDirections',UIParent,'BackdropTemplate');self.pathHUD=hud;hud:SetSize(520,60);hud:SetPoint('TOP',0,-100)
  hud:SetBackdrop({bgFile='Interface\\Buttons\\WHITE8X8'});hud:SetBackdropColor(.035,.045,.065,.95)
  hud.text=hud:CreateFontString(nil,'OVERLAY','GameFontHighlight');hud.text:SetAllPoints();hud.text:SetTextColor(.4,.75,1)
 end
 self.pathHUD.text:SetText(('Flight approach: waypoint %d / %d · %.0f yards\nFollow the blue map line; do not cut across its bends.'):format(self.pathIndex,#points,N:Distance(p,nextPoint)))
 self.pathHUD:Show();self:RenderPath()
end
local render=F.Render
function F:Render()render(self);self:RenderPath()end
local locate=F.Locate
function F:Locate(node)local ok=locate(self,node);if node and self.db.pathing then self:RouteTo(node)end;return ok end
local events=CreateFrame('Frame');events:RegisterEvent('TAXIMAP_OPENED')
events:SetScript('OnEvent',function()
 if not F.character or not WorldNavigation then return end
 local p=WorldNavigation:Position();if not p then return end
 F.character.approaches=F.character.approaches or {}
 for _,node in pairs(F.nodes)do
  local map,pos=F:Call(C_Map and C_Map.GetWorldPosFromMapPos,node.map,F:Call(CreateVector2D,node.x,node.y))
  local x,y;if pos and pos.GetXY then x,y=F:Call(pos.GetXY,pos)end
  if map==p.map and type(x)=='number'and type(y)=='number'and (p.x-x)^2+(p.y-y)^2<900 then F.character.approaches[node.id]=WorldNavigation:Copy(p)end
 end
end)
