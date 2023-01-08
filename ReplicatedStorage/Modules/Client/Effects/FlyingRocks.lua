--|| Services ||--
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local PhysicsService = game:GetService("PhysicsService")

return function(Data)
	
	local partHit = Data.Instance
	local Position = Data.Position
	local Size = Data.Size
	local Amount = Data.Count
	
	for i = 1, Amount do	
		
		local Block = script.Block:Clone()
		Block.Size = Size
		Block.Rotation = Vector3.new(math.random(-360,360),math.random(-360,360),math.random(-360,360))
		Block.BrickColor = partHit.BrickColor
		Block.Material = partHit.Material
		Block.Position = Position
		Block.Velocity = Vector3.new(math.random(-80,80),math.random(80,100),math.random(-80,80))
		Block.Parent = workspace.Visuals
						
		task.delay(.25, function()
			Block.CanCollide = true
			
			task.wait(1)
			local t = TweenService:Create(Block, TweenInfo.new(0.5), {
				Transparency = 1
			})
			t:Play()
			t.Completed:Connect(function()
				Debris:AddItem(Block, 0)
			end)
		end)

		local BodyVelocity = Instance.new("BodyVelocity")
		BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
		BodyVelocity.Velocity = Vector3.new(math.random(-23/1,23/1),math.random(28/1,28/1),math.random(-23/1,23/1))
		BodyVelocity.P = 20
		BodyVelocity.Parent = Block

		Debris:AddItem(BodyVelocity, .1)
		wait()
	end
end