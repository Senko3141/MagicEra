local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

return function(Data)
	local BodyVelocity = Instance.new("BodyVelocity")
	
	for name,value in pairs(Data) do
		local s,e = pcall(function()
			local t = BodyVelocity[name]
		end)
		if s then
			BodyVelocity[name] = value
		end
	end
	
	local Duration = Data.Duration or 1
	Debris:AddItem(BodyVelocity, Duration)
end