local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

return function(Data)
	local Target = Data.Target
	
	task.spawn(function()
		local StoredTracks = {}
		task.delay(1.5, function()
			for _,v in pairs(Target.Humanoid:GetPlayingAnimationTracks()) do
				if StoredTracks[v] then
					v:AdjustSpeed(1)
				end
			end
		end)

		for _,v in pairs(Target.Humanoid:GetPlayingAnimationTracks()) do
			StoredTracks[v] = v.Speed
			v:AdjustSpeed(0)
		end		
	end)
end