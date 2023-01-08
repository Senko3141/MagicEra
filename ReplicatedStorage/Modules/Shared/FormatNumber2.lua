local FormatNumber = {}

local Abbreviations = {"k", "m", "b", "t", "qa", "qi", "sx", "sp", "o", "n", "d"}
function FormatNumber.FormatShort(Number)
	assert(Number and typeof(Number) == "number", "Supplied value must be a number")
	
	local AbsNumber = math.abs(Number)
	
	if (AbsNumber < 1000) then return tostring(Number) end
	
	for Key, Abbreviation in pairs(Abbreviations) do
		if (AbsNumber >= 10^(3*Key) and AbsNumber < 10^(3*(Key+1))) then
			return (Number < 0 and "-" or "") .. tostring(math.floor((AbsNumber/(10^(3*Key)))*10)/10) .. Abbreviation
		end
	end
	
	return FormatNumber.FormatLong(Number)
end

function FormatNumber.FormatLong(Number)
	assert(Number and typeof(Number) == "number", "Supplied value must be a number")

	if (math.abs(Number) < 1000) then return tostring(Number) end

	local String = (Number < 0 and "-" or "") .. tostring(math.abs(math.floor(Number))):reverse():gsub("%d%d%d","%1,"):gsub(",$",""):reverse()

	if (not (Number == math.floor(Number))) then
		String = String .. "." .. (tostring(Number):match("%d+.$"))
	end

	return String
end

--[[
	Examples
	
	print(FormatNumber.FormatLong(123456789))
	print(FormatNumber.FormatShort(123456789))
	print(FormatNumber.FormatLong(123456789.123))
	print(FormatNumber.FormatShort(123456789.123))
	print(FormatNumber.FormatLong(-123456789.69))
	print(FormatNumber.FormatShort(-123456.69))
]]--

return FormatNumber