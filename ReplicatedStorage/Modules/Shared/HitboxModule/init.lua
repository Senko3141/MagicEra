local Hitbox = {
	Info = require(script:WaitForChild("Info"))
}
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local RotatedRegion3 = require(Modules.Shared.RotatedRegion3)

function Hitbox.Cast(Character, HitboxInfo, Duration, Visualize, Type)	
	local hitboxObject = script.HitBox:Clone()
	hitboxObject.CFrame = HitboxInfo.CFrame
	hitboxObject.Size = HitboxInfo.Size
	hitboxObject.Parent = workspace.Effects

	game.Debris:AddItem(hitboxObject, Duration)
	if Visualize then
		hitboxObject.Transparency = .8
	else
		hitboxObject.Transparency = 1
	end

	local Weld = Instance.new("WeldConstraint", hitboxObject)
	Weld.Part0 = hitboxObject
	Weld.Part1 = Character.HumanoidRootPart

	local StartTick = os.clock()
	local FoundPlayers = nil
	if Type == "Multi" then
		FoundPlayers = {}
	end

	-- Region3 Hitbox

	local OverlapParam = OverlapParams.new()
	OverlapParam.FilterDescendantsInstances = {Character, hitboxObject, workspace.Areas, workspace.Place.Trees}
	OverlapParam.FilterType = Enum.RaycastFilterType.Blacklist

	while os.clock() - StartTick < Duration do
		if Type == "Multi" then
			if #FoundPlayers > 0 then
				break
			end
		end
		if Type == "Single" and FoundPlayers ~= nil then
			break
		end
				
		-- detection		
		if Type == "Multi" then
			local InBox = workspace:GetPartBoundsInBox(hitboxObject.CFrame, hitboxObject.Size, OverlapParam)
			if #InBox > 0 then
				for i = 1, #InBox do
					local Obj = InBox[i]
					if Obj.Parent and Obj.Parent:FindFirstChild("Humanoid") and Obj.Parent:FindFirstChild("HumanoidRootPart") then
						local Model = Obj.Parent
						if Model:IsDescendantOf(workspace.Live) and not table.find(FoundPlayers, Model) then
							local StatusFolder = Model:FindFirstChild("Status")
							local Distance = (Character.HumanoidRootPart.Position - Model.HumanoidRootPart.Position).Magnitude
							
							if not StatusFolder:FindFirstChild("Carrier") and not StatusFolder:FindFirstChild("Gripper") and Distance <= 12 then
								table.insert(FoundPlayers, Model)
							end
						end
					end
					
				end
			end
		end
		if Type == "Single" then
			local Inbox = workspace:GetPartBoundsInBox(hitboxObject.CFrame, hitboxObject.Size, OverlapParam)
			if #Inbox > 0 then
				for i = 1, #Inbox do
					local Obj = Inbox[i]
					if Obj.Parent and Obj.Parent:FindFirstChild("Humanoid") and Obj.Parent:FindFirstChild("HumanoidRootPart") then
						local Model = Obj.Parent
						if Model:IsDescendantOf(workspace.Live) then
							local StatusFolder = Model:FindFirstChild("Status")
							local Distance = (Character.HumanoidRootPart.Position - Model.HumanoidRootPart.Position).Magnitude

							if not StatusFolder:FindFirstChild("Carrier") and not StatusFolder:FindFirstChild("Gripper") and Distance <= 12 then
								FoundPlayers = Model
								break
							end
						end
					end
				end
			end
		end
		--RunService.Heartbeat:Wait()
		task.wait()
	end


	-- Magnitude Hitbox
	--[[
	while os.clock() - StartTick < Duration and not FoundPlayer do
		for _,target in pairs(workspace.Live:GetChildren()) do
			if target ~= Character then
				local a = Character.HumanoidRootPart.Position
				
				local hrp = target:FindFirstChild("HumanoidRootPart")
				if hrp then
					local distance = (a-hrp.Position).Magnitude
					print(distance)
					
					if distance <= 5 then
						FoundPlayer = target
						break
					end
				end
			end
		end
		--RunService.Heartbeat:Wait()
		task.wait()
	end
	]]--

	return FoundPlayers
end

return Hitbox