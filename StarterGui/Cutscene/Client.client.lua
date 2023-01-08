-- Cutscene

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")

Remotes.Cutscene.OnClientEvent:Connect(function(Title, Duration, Action)
	if Action ~= nil and Action == "TravelWaypoint" then
		local TravelScene = script.TravelScene:Clone()
		TravelScene.Parent = script.Parent
		
		TravelScene["1"]:TweenPosition(UDim2.new(0.5,0,0,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
		TravelScene["2"]:TweenPosition(UDim2.new(0.5,0,1,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)

		task.delay(Duration or 2, function()
			TravelScene["1"]:TweenPosition(UDim2.new(0.5,0,-0.5,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
			TravelScene["2"]:TweenPosition(UDim2.new(0.5,0,1.5,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
			
			task.wait(.7)
			TravelScene:Destroy()
		end)
	else
		local Clone = script.Template:Clone()
		Clone["2"].Title.Text = Title
		Clone.Parent = script.Parent

		Clone["1"]:TweenPosition(UDim2.new(0.5,0,0.063,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
		Clone["2"]:TweenPosition(UDim2.new(0.5,0,0.928,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)

		task.wait(Duration)
		Clone["1"]:TweenPosition(UDim2.new(0.5,0,-0.1,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
		Clone["2"]:TweenPosition(UDim2.new(0.5,0,1.1,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
		task.wait(.5)
		Clone:Destroy()
	end
end)