-- In Combat --

local Players = game:GetService("Players")
local InCombat = {}

function InCombat.PutInCombat(Player, Target, Duration)	
	game.ServerScriptService.Events.PutInCombat:Fire(Player, Target, Duration)
end

return InCombat