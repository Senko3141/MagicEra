-- Quests

local module = {}
local stored = {}

function module.GetQuestDataFromID(id)
	local found = stored[id]
	if found and found.Type and found.Type == "Quest" then
		return found
	end
	return nil
end

for _,m in pairs(script:GetDescendants()) do
	if m:IsA("ModuleScript") then
		stored[m.Name] = require(m)
	end
end




function module.RefreshQuests(QuestRank)
	local F = {
	[1] = "clean_guild_hall",
	[2] = "find_missing_cat",
	}
	
	local E = {
	[1] = "letter_hospital",
		[2] = "collect_squirrel",
	}
	
	local D = {
		[1] = "kill_hodras",
		[2] = "kill_hodras",
		[3] = "save_the_hostage",
		[4] = "save_the_hostage"
	}
	
	local toreturn = QuestRank[math.random(1,#QuestRank)]
	return toreturn
end

return module