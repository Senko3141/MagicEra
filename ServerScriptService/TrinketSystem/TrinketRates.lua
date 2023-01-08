local Rates = {}

Rates.Rates = {
	["Nothing"] = 45,
	["Bronze Coin"] = 50,
	["Silver Coin"] = 20,
	["Gold Coin"] = 10,
	["Magic Book I"] = 5,
	["Magic Book II"] = 4,
	["Magic Book III"] = .01,
	["Magic Book IV"] = .001,
	["Diamond Coin"] = 2,
	["Grace Lacrima"] = .01,
	["Dragon Lacrima"] = .001,
}
function Rates:GetRandom()
	local Counter = 0
	local RNG = Random.new()
	
	for name,rate in pairs(Rates.Rates) do 
		Counter += rate
	end
	local Chosen = RNG:NextNumber(0, Counter)
	for name,rate in pairs(Rates.Rates) do 
		Counter -= rate
		if Chosen > Counter then
			return name
		end
	end	
end

return Rates