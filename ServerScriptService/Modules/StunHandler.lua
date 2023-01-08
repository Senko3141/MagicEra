-- Stun Handler

local Debris = game:GetService("Debris")
local StunHandler = {}

function StunHandler:Stun(Target, Duration, Ragdoll, DataType)
	local StatusFolder = Target:FindFirstChild("Status")
	if StatusFolder then
		local i = Instance.new("Folder")
		i.Name = "Stunned"
		i.Parent = StatusFolder
		
		if Ragdoll then
			local Ragdoll = Instance.new("Folder")
			Ragdoll.Name = "Ragdoll"
			Ragdoll.Parent = StatusFolder
			
			local RagdollTime = Duration + 1
			
			local Intang = Instance.new("Folder")
			Intang.Name = "Intangibility"
			Intang.Parent = StatusFolder
			
			Debris:AddItem(Intang, RagdollTime+.5)
			Debris:AddItem(Ragdoll, RagdollTime)			
		end
		
		if DataType ~= nil then
			if not Ragdoll then
				-- shouldnt do it when ragdolled?
				if DataType == "Light" or DataType == "Heavy" then
					local NoAttack = Instance.new("Folder")
					NoAttack.Name = "NoAttack"
					NoAttack.Parent = StatusFolder
					Debris:AddItem(NoAttack, .5)
				end
			end
		end
		
		Debris:AddItem(i, Duration)
	end
end

return StunHandler