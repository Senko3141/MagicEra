local TS = game:GetService("TweenService")
local TweenIt = true

while TweenIt == true do
	TS:Create(script.Parent,TweenInfo.new(3,Enum.EasingStyle.Quad,Enum.EasingDirection.InOut,0,false,0),{Position = Vector3.new(script.Parent.Position.X,script.Parent.Position.Y + 2,script.Parent.Position.Z)}):Play()
	task.wait(3)
	TS:Create(script.Parent,TweenInfo.new(3,Enum.EasingStyle.Quad,Enum.EasingDirection.InOut,0,false,0),{Position = Vector3.new(script.Parent.Position.X,script.Parent.Position.Y - 2,script.Parent.Position.Z)}):Play()
	task.wait(3)
end

