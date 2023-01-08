-- Leaning

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

local Player = Players.LocalPlayer
repeat task.wait() until Player.Character
local Character = Player.Character
local Humanoid: Humanoid = Character:WaitForChild("Humanoid")
local animator = Humanoid:FindFirstChildOfClass("Animator")
local cam = workspace.CurrentCamera
local root = Character:WaitForChild("HumanoidRootPart")
local StatusFolder = Character:WaitForChild("Status")
local Events = script.Parent.Parent:WaitForChild("Events")
local Info = require(script.Parent.Parent:WaitForChild("Input").Info)
local collecionservice = game:GetService("CollectionService")
local remote = game.ReplicatedStorage.Remotes.Swim



local swimanim = animator:LoadAnimation(game.ReplicatedStorage.Assets.Animations.Swim)

local movementtype = "walk"
local depth = "shallow"
local swimjump = false
local swimBP = Instance.new("BodyPosition")
swimBP.Name = "Float"
swimBP.MaxForce = Vector3.new()
swimBP.D = 150



UIS.InputBegan:connect(function(key, busy)
	if busy then return end
	if key.KeyCode == Enum.KeyCode.Space then
		if movementtype == "swim" then
			if os.clock() - (Info.PreviousSwimJump or 0) > Info.SwimJumpCd then
				local lv = Character.Head.CFrame.lookVector*Vector3.new(1,0,1)

				if not root:FindFirstChild("leap") then
					local bv = Instance.new("BodyVelocity")
					bv.Name = "leap"
					bv.MaxForce = Vector3.new(4e9,4e9,4e9)
					bv.Velocity = lv*20+Vector3.new(0,40,0)
					bv.Parent = root
					game.Debris:AddItem(bv,0.1)
					swimBP.MaxForce = Vector3.new()
					movementtype = "walk"
					Info.PreviousSwimJump = os.clock()
				end
			end
		end
	end
end)

UIS.InputEnded:connect(function(key,busy)
	if key.KeyCode ~= Enum.KeyCode.Unknown then
	end
end)






RunService.RenderStepped:connect(function()
	local pos = root.Position

	local vel = root.Velocity*Vector3.new(1,0,1)
	local velMag = vel.magnitude

	local waterRay = Ray.new(pos,Vector3.new(0,3,0))
	local rhit,rpos,rnor = workspace:FindPartOnRayWithWhitelist(waterRay,collecionservice:GetTagged("Water"))	



	local offset = math.sin(tick()*1.5)
	local aPos = Vector3.new(pos.x,rpos.y,pos.z)


	if rhit and not root:FindFirstChild("Leap") and movementtype ~= "swim" then
		swimBP.MaxForce = Vector3.new(0,100000,0)
		swimBP.Position = aPos + Vector3.new(0,8.5,0)
		movementtype = "swim"
		remote:FireServer("Swim")
	end
	
	
	if cam.CFrame.Y < rpos.Y - 3 and movementtype == "swim" then
		game.Lighting.Underwater.Enabled = true
		if not workspace.Underwater.IsPlaying then
			workspace.Underwater:Play()
		end
	else
		game.Lighting.Underwater.Enabled = false
		workspace.Underwater:Stop()
	end

	
	if movementtype == "swim" then
		swimBP.Parent = root
		Info.Swimming = true
		if not swimanim.IsPlaying then
			swimanim:Play()
		end
		if not StatusFolder:FindFirstChild("NoRun") then
			local NoRun = Instance.new("Folder")
			NoRun.Name = "NoRun"
			NoRun.Parent = StatusFolder
		end
		if StatusFolder:FindFirstChild("Running") then
			StatusFolder.Running:Destroy()
		end
	end	

	if movementtype == "walk" then
		swimBP.Parent = nil
		Info.Swimming = false
		swimanim:Stop()
		swimBP.MaxForce = Vector3.new(0,0,0)
		if StatusFolder:FindFirstChild("NoRun") then
			StatusFolder.NoRun:Destroy()
		end
	end

end)
