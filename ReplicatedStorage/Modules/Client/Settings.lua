local Settings = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")

Settings.ButtonInfo = {
	["LowGraphics"] = {
		Time = os.clock(),
		AwaitingResult = false,
	},
	["Music"] = {
		Time = os.clock(),
		AwaitingResult = false,
	},
	["DisableSS"] = {
		Time = os.clock(),
		AwaitingResult = false,
	},
	["DamageInd"] = {
		Time = os.clock(),
		AwaitingResult = false,
	},
	["EnableClientTags"] = {
		Time = os.clock(),
		AwaitingResult = false,
	},
	["InstantCast"] = {
		Time = os.clock(),
		AwaitingResult = false,
	},
	["CustomClothesEnabled"] = {
		Time = os.clock(),
		AwaitingResult = false,
	},
}
local StoredGraphics = {}
local StoredMusics = {}

local function LowGraphics(Bool)
	-- simulate time thing
	
	local Result = nil
	
	if Bool then
		for _,obj in pairs(workspace:GetDescendants()) do
			if obj:IsA("BasePart") then
				StoredGraphics[obj] = obj.Material
				obj.Material = Enum.Material.SmoothPlastic
			end
		end
	else
		-- toggle off
		for object,realMaterial in pairs(StoredGraphics) do
			object.Material = realMaterial
			StoredGraphics[object] = nil
		end
	end
	
	task.wait(1)
	return "Success"
end
local function Music(Bool)
	if Bool then
		-- music off		
		for _,v in pairs(game.SoundService.AreaMusic:GetChildren()) do
			if v:IsA("Sound") then
				v.Volume = 0
			end
		end
	else
		-- music on
		for _,v in pairs(game.SoundService.AreaMusic:GetChildren()) do
			if v:IsA("Sound") then
				local default_volume = v:GetAttribute("DefaultVolume") or .5
				v.Volume = default_volume
			end
		end
	end	
	return "Success"
end
local function DisableSS(Bool)
	if Bool then
		_G.DisabledScreenShake.Value = true
	else
		_G.DisabledScreenShake.Value = false
	end
	return "Success"
end
local function DamageInd(Bool)
	return "Success"
end
local function EnableClientTags(Bool)
	return "Success"
end
local function InstantCast(Bool)
	return "Success"
end
local function CustomClothesEnabled(Bool)
	return "Success"
end


Settings.LowGraphics = LowGraphics
Settings.Music = Music
Settings.DisableSS = DisableSS
Settings.DamageInd = DamageInd
Settings.EnableClientTags = EnableClientTags
Settings.InstantCast = InstantCast
Settings.CustomClothesEnabled = CustomClothesEnabled


return Settings