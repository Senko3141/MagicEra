-- Gamepasses

local Players = game:GetService("Players")
local MarketPlaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage.Remotes
local Products = require(ReplicatedStorage.Modules.Shared.Gamepasses)

MarketPlaceService.ProcessReceipt = function(Info)
	local PurchaseID = Info.PurchaseId
	local PlayerId = Info.PlayerId
	local ProductID = Info.ProductId
	
	local Player = Players:GetPlayerByUserId(PlayerId)

	if Products.Gamepasses[ProductID] then
		
		local resp = Products.Gamepasses[ProductID].Func(Player)
		if resp then
			Remotes.Notify:FireClient(Player, "<font color='rgb(50,205,50)'>[GAMEPASSES]</font> Successful purchase for gamepass: [".. Products.Gamepasses[ProductID].Name.."]!", 7)
		end		
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end
end