local Hitbox = {}

local DefaultParams = OverlapParams.new()
DefaultParams.FilterType = Enum.RaycastFilterType.Blacklist
DefaultParams.FilterDescendantsInstances = {workspace.Effects, workspace.Areas, workspace.Place.Trees}

function Hitbox:Start(CF, Size, Params, Visualize)	
	if Visualize then
		local Box = Instance.new("Part")
		Box.Name = "Hitbox"
		Box.Color = Color3.fromRGB(255,0,0)
		Box.Transparency = .7
		Box.CanCollide = false
		Box.Anchored = true
		Box.CanQuery = false
		Box.CanTouch = false

		Box.Parent = workspace.Visualizers
		Box.CFrame = CF
		Box.Size = Size

		if Params then
			table.insert(Params.FilterDescendantsInstances, Box)
		end

		game.Debris:AddItem(Box, .2)
	end
	
	local HitParts = workspace:GetPartBoundsInBox(CF, Size, Params)
	--print(table.unpack(HitParts))
	return HitParts
end
--[[
function Hitbox:Start(Origin, Direction, Blacklist, Visualizer)
	
	
	local RayParams = RaycastParams.new()
	RayParams.FilterType = Enum.RaycastFilterType.Blacklist
	RayParams.FilterDescendantsInstances = Blacklist
	
	return workspace:Raycast(Origin, Direction, RayParams)
end
]]--

return Hitbox
