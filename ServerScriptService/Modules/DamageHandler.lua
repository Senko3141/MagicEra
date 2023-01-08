local DamageHandler = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage.Remotes
local InCombat = require(script.Parent.InCombat)
local Formulas = require(ReplicatedStorage.Modules.Shared.Formulas)

function DamageHandler:Damage(Player, Target, Amount, OtherData)
	if Player and Target and Amount and OtherData then		
		-- add in knocking later
		
		-- Simulate --
		
		local old_health = Target.Humanoid.Health
		
		if Target.Humanoid.Health - Amount <= Formulas.HealthToKnock then
			-- Knock
			Target.Humanoid.Health = Formulas.HealthToKnock
		else
			-- won't knock
			Target.Humanoid:TakeDamage(Amount)
		end
		
		--Target.Humanoid:TakeDamage(Amount)
		
		local new_health = Target.Humanoid.Health
		
	--	warn(new_health, old_health, old_health-new_health, Player.Name, Amount)
				
		if OtherData.CanIndicate then
			Remotes.ClientFX:FireAllClients("DamageIndicator",
				{
					DamageAmount = tostring(Amount),
					Victim = Target,
					Color = Color3.fromRGB(255, 128, 130),
					NormalColor = Color3.fromRGB(229, 63, 65)
				}
			)
		end

		if OtherData.Type ~= "Block" then -- Things to ignore
			InCombat.PutInCombat(Player, Target, 45)
		end
	end
end


return DamageHandler