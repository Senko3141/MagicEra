local HitboxInfo = {
	Info = {
		Combat = function(Character, Type, Skill)
			local StatusFolder = Character:FindFirstChild("Status")
			
			if StatusFolder and StatusFolder:FindFirstChild("Enlarged") then
				warn("bro")
				return {
					["CFrame"] = Character.HumanoidRootPart.CFrame * CFrame.new(0,0,-3.3),
					Size = (Type == "Heavy" and Vector3.new(6, 7, 6)) or Vector3.new(5.2, 6.1, 6.7),
				}
			end
			if Skill == "Hit" then
				return {
					["CFrame"] = Character.HumanoidRootPart.CFrame * CFrame.new(0,0,-3.3),
					Size = Vector3.new(7, 6.1, 15),
				}
			end
			
			return {
				["CFrame"] = Character.HumanoidRootPart.CFrame * CFrame.new(0,-2,-3.3),
				Size = (Type == "Heavy" and Vector3.new(7, 10, 7)) or Vector3.new(6.2, 9.1, 6.3),
			}
		end,
		Caestus = function(Character, Type, Skill)
			local StatusFolder = Character:FindFirstChild("Status")

			if StatusFolder and StatusFolder:FindFirstChild("Enlarged") then
				warn("bro")
				return {
					["CFrame"] = Character.HumanoidRootPart.CFrame * CFrame.new(0,0,-3.3),
					Size = (Type == "Heavy" and Vector3.new(6, 7, 6)) or Vector3.new(5.2, 6.1, 6.7),
				}
			end
			if Skill == "Hit" then
				return {
					["CFrame"] = Character.HumanoidRootPart.CFrame * CFrame.new(0,0,-3.3),
					Size = Vector3.new(7, 6.1, 15),
				}
			end

			return {
				["CFrame"] = Character.HumanoidRootPart.CFrame * CFrame.new(0,-2,-3.3),
				Size = (Type == "Heavy" and Vector3.new(6, 9, 6)) or Vector3.new(5.2, 8.1, 5.3),
			}
		end,
		["Silver Gauntlet"] = function(Character, Type, Skill)
			local StatusFolder = Character:FindFirstChild("Status")

			if StatusFolder and StatusFolder:FindFirstChild("Enlarged") then
				warn("bro")
				return {
					["CFrame"] = Character.HumanoidRootPart.CFrame * CFrame.new(0,0,-3.3),
					Size = (Type == "Heavy" and Vector3.new(6, 7, 6)) or Vector3.new(5.2, 6.1, 6.7),
				}
			end
			if Skill == "Hit" then
				return {
					["CFrame"] = Character.HumanoidRootPart.CFrame * CFrame.new(0,0,-3.3),
					Size = Vector3.new(7, 6.1, 15),
				}
			end

			return {
				["CFrame"] = Character.HumanoidRootPart.CFrame * CFrame.new(0,-2,-3.3),
				Size = (Type == "Heavy" and Vector3.new(6, 9, 6)) or Vector3.new(5.2, 8.1, 5.3),
			}
		end,
		Dagger = function(Character, Type)
			return {
				["CFrame"] = Character.HumanoidRootPart.CFrame * CFrame.new(0,0,-3.3),
				Size = (Type == "Heavy" and Vector3.new(6, 7, 4)) or Vector3.new(5.2, 6.1, 3.3),
			}
		end,
		Greatsword = function(Character, Type)
			return {
				["CFrame"] = Character.HumanoidRootPart.CFrame * CFrame.new(0,0,-3.3),
				Size = (Type == "Heavy" and Vector3.new(6, 7, 6)) or Vector3.new(5.2, 6.1, 6.7),
			}
		end,
		SkullSpear = function(Character, Type)
			return {
				["CFrame"] = Character.HumanoidRootPart.CFrame * CFrame.new(0,0,-3.3),
				Size = (Type == "Heavy" and Vector3.new(6, 7, 6)) or Vector3.new(5.2, 6.1, 6.7),
			}
		end,
		["Sacred Katana"] = function(Character, Type)
			return {
				["CFrame"] = Character.HumanoidRootPart.CFrame * CFrame.new(0,0,-3.3),
				Size = (Type == "Heavy" and Vector3.new(6, 7, 6)) or Vector3.new(5.2, 6.1, 6.7),
			}
		end,
		["Baroque"] = function(Character, Type)
			return {
				["CFrame"] = Character.HumanoidRootPart.CFrame * CFrame.new(0,0,-3.3),
				Size = (Type == "Heavy" and Vector3.new(6, 7, 6)) or Vector3.new(5.2, 6.1, 6.7),
			}
		end,
		["Excalibur"] = function(Character, Type)
			return {
				["CFrame"] = Character.HumanoidRootPart.CFrame * CFrame.new(0,0,-3.3),
				Size = (Type == "Heavy" and Vector3.new(6, 7, 6)) or Vector3.new(5.2, 6.1, 6.7),
			}
		end,
		Battleaxe = function(Character, Type)
			return {
				["CFrame"] = Character.HumanoidRootPart.CFrame * CFrame.new(0,0,-3.3),
				Size = (Type == "Heavy" and Vector3.new(6, 7, 6)) or Vector3.new(5.2, 6.1, 6.7),
			}
		end,
		Katana = function(Character, Type)
			return {
				["CFrame"] = Character.HumanoidRootPart.CFrame * CFrame.new(0,0,-3.3),
				Size = (Type == "Heavy" and Vector3.new(6, 7, 6)) or Vector3.new(5.2, 6.1, 6.7),
			}
		end,
		ScarletBlade = function(Character, Type)
			return {
				["CFrame"] = Character.HumanoidRootPart.CFrame * CFrame.new(0,0,-3.3),
				Size = (Type == "Heavy" and Vector3.new(6, 7, 6)) or Vector3.new(5.2, 6.1, 6.7),
			}
		end,
		Hodra = function(Character, Type)
			return {
				["CFrame"] = Character.HumanoidRootPart.CFrame * CFrame.new(0,0,-3.3),
				Size = (Type == "Heavy" and Vector3.new(9, 7, 9)) or Vector3.new(5.2, 6.1, 6.7),
			}
		end,
	}
}

function HitboxInfo.fetch(Character, WeaponName, ...)
	local func = HitboxInfo.Info[WeaponName] or nil
	if func then
		return func(Character, ...)
	end
	return nil
end


return HitboxInfo