local svcRun = game:GetService("RunService");
local ConfettiCannon = require(script.ConfettiParticles);
ConfettiCannon.setGravity(Vector2.new(0,1));
local confetti = {};
local AmountOfConfetti = 25;
local confettiColors = {Color3.fromRGB(255, 32, 35), Color3.fromRGB(47, 165, 255), Color3.fromRGB(34, 218, 31), Color3.fromRGB(218, 195, 22)};
for i=1, AmountOfConfetti do
	local p = ConfettiCannon.createParticle(
		Vector2.new(0.5,1),
		Vector2.new(math.random(90)-45, math.random(70,100)),
		script.Parent,
		confettiColors
	);
	table.insert(confetti, p);
end;

local confettiActive = false;
svcRun.RenderStepped:Connect(function()
	for _,val in pairs(confetti) do
		val.Enabled = confettiActive;
		val:Update();
	end;
end);

local fire = function()
	spawn(function()
		confettiActive = true;
		wait(tick);
		confettiActive = false;
	end);
end;

local ConfettiEvent = script.Parent.Parent:WaitForChild("Confetti")
ConfettiEvent.Event:Connect(function()
	fire()
end)