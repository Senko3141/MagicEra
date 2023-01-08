local Knock = {}

function Knock:Knock(Target, Duration)
	local TargetStatus = Target:FindFirstChild("Status")
	if TargetStatus then
		
		if TargetStatus:FindFirstChild("Knocked") then return end -- already nkocked
		
		local Ragdoll = Instance.new("Folder")
		Ragdoll.Name = "Ragdoll"
		Ragdoll.Parent = TargetStatus
		
		local Stunned = Instance.new("Folder")
		Stunned.Name = "Stunned"
		Stunned.Parent = TargetStatus

		local Knocked = Instance.new("Folder")
		Knocked.Name = "Knocked"
		Knocked.Parent = TargetStatus
		
		local Intang = Instance.new("Folder")
		Intang.Name = "Intangibility"
		Intang.Parent = TargetStatus
		
		Knocked:SetAttribute("Destroy", false)
		
		if Target:FindFirstChild("Settings") then
			task.delay(25, function()
				if Knocked.Parent == nil or not Knocked:FindFirstChild("Destroy") then
					Ragdoll:Destroy()
					Stunned:Destroy()
					Knocked:Destroy()
					Intang:Destroy()
					for i,v in pairs(TargetStatus:GetChildren()) do
						if v.Name == "Intangibility" then
							v:Destroy()
						end
					end
				end
			end)
		else
			task.delay(10, function()
				if Knocked.Parent == nil or not Knocked:FindFirstChild("Destroy") then
					Ragdoll:Destroy()
					Stunned:Destroy()
					Knocked:Destroy()
					Intang:Destroy()
					for i,v in pairs(TargetStatus:GetChildren()) do
						if v.Name == "Intangibility" then
							v:Destroy()
						end
					end
				end
			end)
		end
		
		
		local Connection
		Connection = Knocked.AttributeChanged:Connect(function(attribute)
			if attribute == "Destroy" and Knocked:GetAttribute("Destroy") == true then
				-- Destroy Knock, was overrided --
				Ragdoll:Destroy()
				Stunned:Destroy()
				Knocked:Destroy()
				Intang:Destroy()
			end
		end)
		
		
	end
end


return Knock