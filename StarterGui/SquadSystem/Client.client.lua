-- Client

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Assets = ReplicatedStorage:WaitForChild("Assets")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
repeat task.wait() until Player:GetAttribute("DataLoaded") == true
local PlayerData = Player:WaitForChild("Data")

local Maid = require(Modules.Shared.Maid)
local HUD = script.Parent
local NotifyHUD = script.Parent.Parent:WaitForChild("Notifications")
local Sound = require(Modules.Client.Effects.Sound)
local Squads = ReplicatedStorage:WaitForChild("Squads")

local NotifyEvent = NotifyHUD:WaitForChild("Notify")
local Root = HUD:WaitForChild("Root")

local SquadFrame = Root.SquadInfo
local CreateSquad = Root.CreateSquad
local DisbandSquad = Root.Disband
local LeaveSquad = Root.LeaveSquad
local Buttons = SquadFrame.Buttons
local InviteList = Root.InviteList

local MembersFrame = SquadFrame.Members
local KickFrame = SquadFrame.KickMember
local InviteFrame = SquadFrame.Invite

local ButtonToFrame = {
	[Buttons.View] = MembersFrame,
	[Buttons.Invite] = InviteFrame,
	[Buttons.Kick] = KickFrame,
}

local IndicatorDisabled = false

local function IsInSquad()
	local DataToReturn = {
		IsOwner = false
	}
	-- Checking if is the owner of a squad
	if Squads:FindFirstChild(Player.UserId.."'s Squad") then
		DataToReturn.IsOwner = true
		return true, DataToReturn
	end
	-- Checking if is a member of a squad
	if #Squads:GetChildren() > 0 then
		for _,squad in pairs(Squads:GetChildren()) do
			local Members = squad:FindFirstChild("Members")
			if Members:FindFirstChild(Player.UserId) then
				DataToReturn.IsOwner = false

				local OwnerID = squad.Owner.Value
				DataToReturn.SquadOwner = Players:GetPlayerByUserId(OwnerID).Name
				return true, DataToReturn
			end
		end
	end
	--
	return false, DataToReturn
end

-- CREATE SQUAD --
CreateSquad.Main.MouseButton1Click:Connect(function()
	Sound({
		SoundName = "Click",
		Parent = script.Parent.Parent.Effects
	})
	Remotes.Squad:FireServer("Create", {})
end)
-- DISBAND SQUAD --
DisbandSquad.Main.MouseButton1Click:Connect(function()
	Sound({
		SoundName = "Click",
		Parent = script.Parent.Parent.Effects
	})
	Remotes.Squad:FireServer("Disband", {})
end)
-- LEAVE SQUAD --
LeaveSquad.Main.MouseButton1Click:Connect(function()
	Sound({
		SoundName = "Click",
		Parent = script.Parent.Parent.Effects
	})
	Remotes.Squad:FireServer("Leave", {})
end)
-- TOGGLE INDICATOR --
SquadFrame.DisableIndicator.Main.MouseButton1Click:Connect(function()
	IndicatorDisabled = not IndicatorDisabled
	if IndicatorDisabled then
		SquadFrame.DisableIndicator.Main.Text = "Disable Indicator: ON"
	else
		SquadFrame.DisableIndicator.Main.Text = "Disable Indicator: OFF"
	end
end)
-- INVITE --
local function GetPlayerFromPartial(String)
	for i,v in pairs(game.Players:GetPlayers()) do
		local matched = v.Name:lower():match('^' .. String:lower())
		if matched and v ~= Player then
			return v
		end
	end
end
InviteFrame.Main.Input.FocusLost:Connect(function()
	local p = GetPlayerFromPartial(InviteFrame.Main.Input.Text)
	if p then
		InviteFrame.Main.Input.Text = p.Name
	end
end)
InviteFrame.Main.Invite.Main.MouseButton1Click:Connect(function()
	Sound({
		SoundName = "Click",
		Parent = script.Parent.Parent.Effects
	})

	local InSquad, Returned = IsInSquad()
	if InSquad and Returned.IsOwner then
		-- IsOwner, so can invite
		local ToInvite = InviteFrame.Main.Input.Text
		if Players:FindFirstChild(ToInvite) then
			-- Is a player
			Remotes.Squad:FireServer("Invite", {
				["Target"] = ToInvite
			})
		end
	end
end)

-- OnClientEvent --
Remotes.Squad.OnClientEvent:Connect(function(Action, Data)
	if Action == "Invite" then
		local Sender = Data.Sender
		local StartTime = Data.Duration

		if not Sender then
			return
		end
		if not StartTime then
			return
		end

		local SenderPlayer = Players:GetPlayerByUserId(Sender)
		if SenderPlayer then			
			local Clone = script.InviteTemplate:Clone()
			Clone.Name = #InviteList:GetChildren()+1

			Clone.Label.Text = "Squad request from <b>"..SenderPlayer.Name.."</b>. ("..StartTime..")"
			Clone.Accept.MouseButton1Click:Connect(function()
				Clone:Destroy()
				Remotes.Squad:FireServer("Accept", {
					["Sender"] = Sender
				})
			end)
			Clone.Decline.MouseButton1Click:Connect(function()
				Clone:Destroy()
				Remotes.Squad:FireServer("Decline", {
					["Sender"] = Sender
				})
			end)

			Clone.Parent = InviteList

			while Clone.Parent do
				if StartTime <= 0 then
					if Clone.Parent then
						-- Destroy
						Clone:Destroy()						
					end
					break
				end
				StartTime -= 1
				Clone.Label.Text = "Squad request from <b>"..SenderPlayer.Name.."</b>. ("..StartTime..")"
				task.wait(1)
			end
		end
	end
end)

-- BUTTONS --
for _,button in pairs(Buttons:GetChildren()) do
	if button:IsA("ImageButton") then
		button.Main.MouseButton1Click:Connect(function()
			local Frame = ButtonToFrame[button]
			if Frame then
				for _,f in pairs(ButtonToFrame) do
					f.Visible = false
				end
				Frame.Visible = true
			end			
		end)
	end
end

local Open = true
script.Parent:WaitForChild("Toggle").MouseButton1Click:Connect(function()
	Open = not Open

	if Open then
		Root:TweenPosition(UDim2.new(0,0,0,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
		script.Parent.Toggle.Text = ">"
		script.Parent.Toggle:TweenPosition(UDim2.new(0.883,0,0.974,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
	else
		Root:TweenPosition(UDim2.new(1,0,0,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
		script.Parent.Toggle.Text = "<"
		script.Parent.Toggle:TweenPosition(UDim2.new(0.98,0,0.974,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
	end
end)

while true do
	-- Checking if in Squad
	local InSquad, Data = IsInSquad()

	if InSquad then
		-- In Squad
		if Data.IsOwner then
			-- Is the Owner
			CreateSquad.Visible = false
			LeaveSquad.Visible = false
			DisbandSquad.Visible = true

			SquadFrame.Visible = true
		else
			-- Not the Owner
			CreateSquad.Visible = false
			LeaveSquad.Visible = true
			DisbandSquad.Visible = false

			SquadFrame.Visible = true
		end

		-- Update Members
		local SquadFolder = nil
		if Data.IsOwner then
			SquadFolder = Squads:FindFirstChild(Player.UserId.."'s Squad")
		else
			local SquadOwner = Players:FindFirstChild(Data.SquadOwner)
			if SquadOwner then
				SquadFolder = Squads:FindFirstChild(SquadOwner.UserId.."'s Squad")
			end
		end

		if SquadFolder then
			-- Clearing Children
			task.spawn(function()
				for _,v in pairs(MembersFrame.List:GetChildren()) do
					if v:IsA("Frame") then
						v:Destroy()
					end
				end
			end)

			local SquadLeader = Players:GetPlayerByUserId(SquadFolder.Owner.Value)
			local Members = SquadFolder.Members

			if SquadLeader then
				MembersFrame.LeaderName.Text = "Leader: ".. SquadLeader.Name

				task.spawn(function()
					for _,v in pairs(KickFrame.List:GetChildren()) do
						if v:IsA("Frame") then
							local MemberPlayer = Players:FindFirstChild(v.Name)

							if not MemberPlayer then
								v:Destroy()
							else
								if not Members:FindFirstChild(MemberPlayer.UserId) then
									v:Destroy()
								end
							end						
						end
					end
				end)

				for _,member in pairs(Members:GetChildren()) do
					local MemberPlayer = Players:GetPlayerByUserId(tonumber(member.Name))

					if MemberPlayer then
						-- Cloning to [MembersFrame]
						local MemberClone = script.MemberTemplate:Clone()
						MemberClone.Name = MemberPlayer.Name
						MemberClone.MemberName.Text = MemberPlayer.Name

						if MemberPlayer.Name == SquadLeader.Name then
							-- Make name yellow
							MemberClone.MemberName.TextColor3 = Color3.fromRGB(229,223,102)
						else
							MemberClone.MemberName.TextColor3 = Color3.fromRGB(255,255,255)
						end

						MemberClone.Parent = MembersFrame.List

						-- Updating Health
						if MemberPlayer.Character then
							task.spawn(function()
								local MemberHumanoid = MemberPlayer.Character:WaitForChild("Humanoid")
								--MemberClone.Health.Main:TweenSize(UDim2.new(MemberHumanoid.Health/MemberHumanoid.MaxHealth,0,1,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)								
								MemberClone.Health.Main.Size = UDim2.new(MemberHumanoid.Health/MemberHumanoid.MaxHealth,0,1,0)
							end)
						end
						---------------------------------

						-- Cloning to [KickFrame]
						if MemberPlayer.UserId ~= SquadLeader.UserId then
							if not KickFrame.List:FindFirstChild(MemberPlayer.Name) then -- So it doesn't keep on cloning
								local KickClone = script.KickTemplate:Clone()
								KickClone.Name = MemberPlayer.Name
								KickClone.MemberName.Text = MemberPlayer.Name

								KickClone.Kick.MouseButton1Click:Connect(function()
									Remotes.Squad:FireServer("Kick", {
										["Target"] = KickClone.Name
									})
									Sound({
										SoundName = "Click",
										Parent = script.Parent.Parent.Effects
									})
								end)
								KickClone.Parent = KickFrame.List
							end
						end
					end
				end

				-- Squad Indicators
				for _,p in pairs(Players:GetPlayers()) do
					if Members:FindFirstChild(tostring(p.UserId)) then

						if p ~= Player then
							if p.Character:FindFirstChild("Head") then
								--[[
								if not p.Character.Head:FindFirstChild("SquadIndicator") then
									local SquadInd = Assets.SquadIndicator:Clone()
									SquadInd.Parent = p.Character.Head
								end
								]]--
								if not p.Character:FindFirstChild("SquadHighlight") then
									local Highlight = Instance.new("Highlight")
									Highlight.Name = "SquadHighlight"
									Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

									Highlight.OutlineColor = Color3.fromRGB(58, 255, 28)
									Highlight.FillColor = Color3.fromRGB(255,26,26)

									Highlight.FillTransparency = .7
									Highlight.Parent = p.Character
								end
							end		
						end

					end
				end

			end
		end
	else
		-- Not in a Squad
		CreateSquad.Visible = true
		LeaveSquad.Visible = false
		DisbandSquad.Visible = false

		SquadFrame.Visible = false
	end

	-- Destroying Squad Indicators
	task.spawn(function()
		for _,a in pairs(Players:GetPlayers()) do
			if a.Character and a.Character:FindFirstChild("Head") and a.Character:FindFirstChild("SquadHighlight") then

				if not InSquad then
					-- destroy indicators
					a.Character.SquadHighlight:Destroy()
				else
					-- in squad
					local SquadFolder = nil
					if Data.IsOwner then
						SquadFolder = Squads:FindFirstChild(Player.UserId.."'s Squad")
					else
						local SquadOwner = Players:FindFirstChild(Data.SquadOwner)
						if SquadOwner then
							SquadFolder = Squads:FindFirstChild(SquadOwner.UserId.."'s Squad")
						end
					end

					if SquadFolder then
						local Members = SquadFolder.Members
						if not Members:FindFirstChild(tostring(a.UserId)) then
							-- Member is not in the Squad anymore, but still has indicator
							--[[
							a.Character.Head.SquadIndicator:Destroy()
							]]--
							a.Character.SquadHighlight:Destroy()
						else
							-- still is member

							local HighlightObject = a.Character:FindFirstChild("SquadHighlight")
							if HighlightObject then

								if IndicatorDisabled then
									-- disabled
									HighlightObject.Enabled = false
								else
									HighlightObject.Enabled = true
								end

							end

						end
					end

				end
			end
		end
	end)

	task.wait()
end