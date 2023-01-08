local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

local function doEffect(Character, Parent)
	local RunObject = script.Run:Clone()
	RunObject.Parent = workspace.Visuals
	RunObject.CFrame = Parent.CFrame * CFrame.fromEulerAnglesXYZ(0,math.rad(-180),0)
	
	RunObject.Shard:Emit(math.random(3,7))
	
	Debris:AddItem(RunObject, 1)
end

return function(Data)
	local Character = Data.Character
	local Parent = Data.Parent
	
	doEffect(Character, Parent)
end