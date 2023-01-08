-- Guild System

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local UI = script.Parent
local InviteList_Frame = UI:WaitForChild("InviteList")

Remotes.Guild.OnClientEvent:Connect(function(Action, Data)
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
			Clone.Name = #InviteList_Frame:GetChildren()+1

			Clone.Label.Text = "Guild request from <b>"..SenderPlayer.Name.."</b>. ("..StartTime..")"
			Clone.Accept.MouseButton1Click:Connect(function()
				Clone:Destroy()
				Remotes.Guild:FireServer("Accept", {
					["Sender"] = Sender
				})
			end)
			Clone.Decline.MouseButton1Click:Connect(function()
				Clone:Destroy()
				Remotes.Guild:FireServer("Decline", {
					["Sender"] = Sender
				})
			end)

			Clone.Parent = InviteList_Frame

			while Clone.Parent do
				if StartTime <= 0 then
					if Clone.Parent then
						-- Destroy
						Clone:Destroy()						
					end
					break
				end
				StartTime -= 1
				Clone.Label.Text = "Guild request from <b>"..SenderPlayer.Name.."</b>. ("..StartTime..")"
				task.wait(1)
			end
		end
	end
end)