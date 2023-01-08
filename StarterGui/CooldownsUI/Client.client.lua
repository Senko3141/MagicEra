-- Cooldown

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local HUD = script.Parent

local List = HUD:WaitForChild("List")
local Event = HUD:WaitForChild("init")

local function fire(Name, Duration)
	local Clone = script.Template:Clone()
	Clone.Name = Name
	Clone.Title.Text = Name.." ("..Duration..")"
	Clone.Parent = List
	
	task.spawn(function()
		Clone.Bar.Main:TweenSize(UDim2.new(0,0,1,0), Enum.EasingDirection.Out, Enum.EasingStyle.Linear, Duration, true)
		while Clone.Parent ~= nil do
			if Duration <= 0 then
				break
			end
			Duration -= 1
			Clone.Title.Text = Name.." ("..Duration..")"
			task.wait(1)
		end
		if Clone.Parent then
			Clone:Destroy()
		end
	end)	
end

Event.Event:Connect(function(Name, Durationn)
	fire(Name, Durationn)
end)
Remotes.Cooldown.OnClientEvent:Connect(function(Name, Duration)
	fire(Name, Duration)
end)