-- Area Notifier

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local Debris = game:GetService("Debris")
local Lighting = game:GetService("Lighting")

local Areas = workspace:WaitForChild("Areas")
local Modules = ReplicatedStorage:WaitForChild("Modules")

local SoundModule = require(Modules.Client.Effects.Sound)
local Configuration = require(script:WaitForChild("Configuration"))
local ZoneService = require(Modules.Shared.Zone)

local MusicGroup = SoundService:WaitForChild("AreaMusic", 99)
local MusicCache = MusicGroup.Cache

local Player = Players.LocalPlayer
local PlayerData = Player:WaitForChild("Data", 99)
local PlayerSettings = PlayerData:WaitForChild("Settings", 99)

local CachedZones = {}
local PreviousZone = ""

--
local MainGui = nil
local Player = Players.LocalPlayer
if Player.Character then
	MainGui = Player.PlayerGui:WaitForChild("Areas")
end
Player.CharacterAdded:Connect(function()
	MainGui = Player.PlayerGui:WaitForChild("Areas")
end)
--

local function UIEffect(Object, Action, Info)
	local ToReturn = {}
	if Action == "In" then
		local Tween = TweenService:Create(Object, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			GroupTransparency = 0
		})
		Tween:Play()

		table.insert(ToReturn, {["Class"] = "Tween", ["Object"] = Tween})

		for _,v in pairs(Object:GetChildren()) do
			if v.Name == "Border1" then
				v:TweenPosition(UDim2.new(0.05,0,0.5,0), Enum.EasingDirection.Out, Enum.EasingStyle.Linear, 0.2, true)
			end
			if v.Name == "Border2" then
				v:TweenPosition(UDim2.new(0.95,0,0.5,0), Enum.EasingDirection.Out, Enum.EasingStyle.Linear, 0.2, true)
			end
			if v.name == "Separator" then
				v:TweenSize(UDim2.new(.6,0,0.02,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
			end
		end

	end
	if Action == "Out" then
		local Tween = TweenService:Create(Object, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			GroupTransparency = 1
		})
		Tween:Play()
		
		table.insert(ToReturn, {["Class"] = "Tween", ["Object"] = Tween})

		for _,v in pairs(Object:GetChildren()) do
			if v.Name == "Border1" then
				v:TweenPosition(UDim2.new(0.5,0,0.5,0), Enum.EasingDirection.Out, Enum.EasingStyle.Linear, 0.2, true)
			end
			if v.Name == "Border2" then
				v:TweenPosition(UDim2.new(0.5,0,0.5,0), Enum.EasingDirection.Out, Enum.EasingStyle.Linear, 0.2, true)
			end
			if v.name == "Separator" then
				v:TweenSize(UDim2.new(0,0,0.02,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
			end
		end

	end
	return ToReturn
end
local function Notify(Name)
	local Info = Configuration[Name]
	if Info then
		local FoundType = MainGui:FindFirstChild(Info.Type)
		if FoundType then
			
			-- Sound
			SoundModule({
				SoundName = "Notification",
				Parent = SoundService
			})
			--
			
			for _,v in pairs(MainGui:GetChildren()) do
				if v:IsA("CanvasGroup") then
					local AlreadyTweening = v:GetAttribute("AlreadyTweening")
					if AlreadyTweening == true then
						v:SetAttribute("AlreadyTweening", false)
					end
				end
			end
			FoundType:SetAttribute("AlreadyTweening", true)

			-- Changing Values
			if Info.Type == "Single" then
				FoundType.Title.Text = Info.Text
			end
			if Info.Type == "Dual" then
				FoundType.Title.Text = Info.Title
				FoundType.Description.Text = Info.Description
			end
			--

			-- Checking when Attribute Changed
			local Returned = UIEffect(FoundType, "In", Info)

			local Connection = nil
			Connection = FoundType:GetAttributeChangedSignal("AlreadyTweening"):Connect(function()
				if FoundType:GetAttribute("AlreadyTweening") == false then
					Connection:Disconnect()
					Connection = nil

					for _,o in pairs(Returned) do
						if o.Class == "Tween" then
							local Tween = o.Object
							if Tween.PlaybackState == Enum.PlaybackState.Playing then
								Tween:Cancel()
								Tween:Destroy()
							end
						end
					end	

					UIEffect(FoundType, "Out", Info)
				end
			end)

			task.delay(5, function()
				if Connection ~= nil then
					Connection:Disconnect()
					Connection = nil
					UIEffect(FoundType, "Out", Info)
				end
			end)

		end
	end
end
local function Music(Name)
	-- Clearing
	for _,v in pairs(MusicGroup:GetChildren()) do
		if v:IsA("Sound") then
			v.Parent = MusicCache
			TweenService:Create(v, TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
				Volume = 0
			}):Play()
			
			Debris:AddItem(v, .5)
		end
	end
	
	local Info = Configuration[Name]
	if Info then
		-- Music
		local Sounds = Info.Sounds
		if Sounds then
			for _,SoundData in pairs(Sounds) do
				local sound = Instance.new("Sound")
				sound.SoundId = SoundData.ID
				
				sound.Volume = (PlayerSettings.Music.Value and 0) or SoundData.Volume or .5
				sound:SetAttribute("DefaultVolume", SoundData.Volume)
				
				sound.Looped = true
				sound.Parent = MusicGroup

				sound:Play()
			end
		end	
	end
end

local QueuedTweens = {
	["AreaAtmosphere"] = "",
	["AreaColor"] = "",
}
local function UpdateLighting(AreaName, area_info)
	-- Changing Sky
	local skybox = Lighting.Skyboxes
	local skyuse = skybox:FindFirstChild(AreaName)
	if not skyuse then skyuse = skybox.Default end
	local skyuse2 = skyuse:Clone()

	local currentsky = Lighting:FindFirstChildWhichIsA("Sky")
	if currentsky.Name ~= skyuse.Name then
		currentsky:Destroy()
		skyuse2.Parent = Lighting
	end
	-- Others
	local atmosphere_data = area_info.Atmosphere
	local color_data = area_info.ColorCorrection

	if atmosphere_data then
		
		if QueuedTweens.AreaAtmosphere ~= "" then
			if QueuedTweens.AreaAtmosphere.PlaybackState == Enum.PlaybackState.Completed then
			else
				QueuedTweens.AreaAtmosphere:Pause()
			end
			QueuedTweens.AreaAtmosphere:Destroy()
		end
		QueuedTweens.AreaAtmosphere = TweenService:Create(Lighting.AreaAtmosphere, TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), atmosphere_data)
		QueuedTweens.AreaAtmosphere:Play()
		--[[
		for name,value in pairs(atmosphere_data) do
			local s,e = pcall(function()
				return Lighting.AreaAtmosphere[name]
			end)
			if s then
				Lighting.AreaAtmosphere[name] = value
			end
		end	
		]]
	end
	if color_data then
		if QueuedTweens.AreaColor ~= "" then
			if QueuedTweens.AreaColor.PlaybackState == Enum.PlaybackState.Completed then
			else
				QueuedTweens.AreaColor:Pause()
			end			
			QueuedTweens.AreaColor:Destroy()
		end
		QueuedTweens.AreaColor = TweenService:Create(Lighting.AreaColor, TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), color_data)
		QueuedTweens.AreaColor:Play()
		--[[
		for name,value in pairs(color_data) do
			local s,e = pcall(function()
				return Lighting.AreaColor[name]
			end)
			if s then
				Lighting.AreaColor[name] = value
			end
		end	
		]]
	end
end

-- Clearing
for _,Cache in pairs(CachedZones) do
	Cache:destroy()
end
--
for _,v in pairs(Areas:GetChildren()) do
	local Object = ZoneService.new(v)
	CachedZones[v] = Object

	Object.localPlayerEntered:Connect(function()
		--print("Entered ".. v.Name)
		PreviousZone = v.Name
		Notify(v.Name)
		Music(v.Name)
		UpdateLighting(v.Name, Configuration[v.Name])
	end)
	Object.localPlayerExited:Connect(function()
		if PreviousZone ~= v.Name then
			return -- weird?
		end
		
		--print("Exited ".. v.Name)
		
		task.spawn(function()
			for _,v in pairs(MainGui:GetChildren()) do
				if v:IsA("CanvasGroup") then
					local AlreadyTweening = v:GetAttribute("AlreadyTweening")
					if AlreadyTweening == true then
						v:SetAttribute("AlreadyTweening", false)
					end
				end
			end
		end)
		
		Music()
		--UpdateLighting(v.Name, Configuration["Default"])
	end)
end