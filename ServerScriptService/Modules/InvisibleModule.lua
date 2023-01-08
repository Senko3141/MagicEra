-- Invisible Module

local module = {
	stored = {}
}

function module.Invisible(model: Model)
	for _,v in pairs(model:GetDescendants()) do
		if v:IsA("BasePart") or v:IsA("Decal") or v:IsA("MeshPart") then
			module.stored[v] = v.Transparency
			v.Transparency = 1
		end
	end
end
function module.UnInvisible(model: Model)
	for _,v in pairs(model:GetDescendants()) do
		if v:IsA("BasePart") or v:IsA("Decal") or v:IsA("MeshPart") then
			if module.stored[v] ~= nil then
				v.Transparency = module.stored[v]
				module.stored[v] = nil
			end
		end
	end
end

return module