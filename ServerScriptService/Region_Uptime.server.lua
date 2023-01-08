-- Server Region/Uptime

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HTTPService = game:GetService("HttpService")

local ServerRegion = ReplicatedStorage.ServerRegion
local ServerStartTime = ReplicatedStorage.ServerStartTime

local IP_Data = HTTPService:GetAsync("http://ip-api.com/json/")
IP_Data = HTTPService:JSONDecode(IP_Data)

ServerRegion.Value = IP_Data.regionName..", "..IP_Data.country
ServerStartTime.Value = os.time()
