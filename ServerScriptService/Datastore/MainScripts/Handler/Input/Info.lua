local Info = {}
-- KeyInfo
Info.KeyInfo = {
	["MouseButton1"] = "Punch",
	["MouseButton2"] = "Heavy",
	["F"] = "Block",
	["W"] = "Sprint",
	["Q"] = "Dash",
	["Space"] = "Jump",
	["R"] = "Evade",
	["V"] = "Carry",
	["B"] = "Grip",
	["LeftControl"] = "Slide/Crouch",
	["T"] = "ToggleAura",
}

-- Fall Damage Cooldown
Info.PreviousFall = os.clock()
Info.FallCooldown = 0.1
Info.MinimumFallInterval = 1.8
--Swimming
Info.Swimming = false
Info.PreviousSwimJump = os.clock()
Info.SwimJumpCd = 1.5

-- Crouching
Info.PreviousCrouch = os.clock()
Info.CrouchCooldown = 1

-- Sliding
Info.PreviousSlide = os.clock()
Info.SlideCooldown = 1.5
Info.SlideDuration = 2

Info.SlopSlideStartVelocity = 70
Info.SlideStartVelocity = 40
-- Sprinting
Info.PreviousW = os.clock()
Info.PreviousSprint = os.clock()
Info.SprintInterval = .2
Info.SprintCooldown = .8
-- Dashing
Info.PreviousDash = os.clock()
Info.DashCooldown = 1.75
Info.DashForce = 50
Info.DashKeys = {
	["W"] = {"Positive", "LookVector"},
	["A"] = {"Negative", "RightVector"},
	["S"] = {"Negative", "LookVector"},
	["D"] = {"Positive", "RightVector"}
}
Info.DashDuration = .3
-- Carrying
Info.PreviousCarry = nil
Info.CarryToggleCooldown = .7 -- dropping people
Info.CarryCooldown = 1.5
-- Gripping
Info.PreviousGrip = nil
Info.GripToggleCooldown = .8 -- toggling grip
Info.GripCooldown = 1.5
-- Blocking
Info.PreviousBlock = os.clock()
Info.BlockCooldown = .05

-- Punching || get cooldowns from folders etc
Info.Swings = 0
Info.PreviousSwing = os.clock()
Info.PreviousCombo = os.clock()
Info.PreviousHeavy = os.clock()
-- Heavy
--Info.PreviousHeavy = os.clock()

-- Jumping
Info.PreviousJump = os.clock()
Info.PreviousJumpRequest = os.clock() -- PreviousJump and PreviousRequest DIFFERENT things
Info.JumpCooldown = 1
Info.DoubleJumpInterval = .4
Info.PreviousDoubleJump = os.clock()
Info.DoubleJumpCooldown = 1.5
-- Evading
Info.PreviousEvade = nil
Info.EvadeCooldown = 5

-- Functions
Info.Blacklists = { -- Think: To do [action], you can't be ... || Ex. To Sprint, I can't be stunned, attacking, etc
	["Default"] = {"HasLog", "Stun","Action","Stunned","Blocking","Attacking","DoingHeavy","Dead","UsingMagic","Action","Knocked","Carrier","Ragdoll","Gripping","Gripper","Sliding","DoingTraining","IsResetting"},
	["Block"] = {"HasLog", "Stun","Action","Stunned","Blocking","Attacking","LightAttack","DoingHeavy","Dead","UsingMagic","Action","Knocked","Carrier","Ragdoll","Gripping","Gripper","Sliding","DoingTraining","IsResetting"},

	["Training"] = {"HasLog","Stun","Action","Stunned","Blocking","Attacking","DoingHeavy","Dead","UsingMagic","Action","Knocked","Carrier","Ragdoll","Gripping","Gripper","Sliding","IsResetting"},
	
	["Blocking"] = {"HasLog","Stun","Action","Stunned","Attacking","DoingHeavy","Dashing","Dead","UsingMagic","InAir","Action","Knocked","Carrier","Ragdoll","Gripping","Gripper","Sliding","DoingTraining","IsResetting"},
	["Dashing"] = {"LightAttack", "Stun","Action","Stunned","Attacking","DoingHeavy","Blocking","Dead","UsingMagic","InAir","Action","Knocked","Carrier","Ragdoll","Gripping","Gripper","Sliding","DoingTraining","IsResetting"},
	["Sprint"] = {"Stun","Action","Stunned","Blocking","Attacking","DoingHeavy","Dead","UsingMagic","Action","Knocked","Carrier","Ragdoll","Gripping","Gripper","DoingTraining","IsResetting","Crouching"},
	
	["Attack"] = {"HasLog","Stun","Action","Stunned","LightAttack","Blocking","HeavyAttack","Dead","UsingMagic","Action","Knocked","Carrier","Ragdoll","Gripping","Gripper"--[[,"Sliding"]],"NoAttack","DoingTraining","IsResetting"},
	
	["Magic"] = {"HasLog","Stun","Action","Stunned","LightAttack","Blocking","HeavyAttack","Dead","Action","Knocked","Carrier","Ragdoll","Gripping","Gripper","Sliding","DoingTraining","IsResetting"}, --NoAttack used to be here
	
	["Heavy"] = {"HasLog","Stun","Action","Stunned","Blocking","Attacking","DoingHeavy","Dead","UsingMagic","Action","Knocked","Carrier","Ragdoll","Gripping","Gripper","Sliding","NoAttack","DoingTraining","IsResetting"},
	
	["Carry"] = {"HasLog","Stun","Action","Stunned","Blocking","Attacking","DoingHeavy","Dead","UsingMagic","Action","Knocked","Carrier","Ragdoll","Gripping","Gripper","Carrying","InAir","Sliding","DoingTraining","IsResetting"},
	["Grip"] = {"HasLog","Stun","Action","Stunned","Blocking","Attacking","DoingHeavy","Dead","UsingMagic","Action","Knocked","Carrier","Ragdoll","Carrying","Gripper","InAir","Sliding","DoingTraining","IsResetting"},
	
	["Jump"] = {"Stun","Action","Stunned","LightAttack","Blocking","HeavyAttack","Dead","UsingMagic","Action","Knocked","Carrier","Ragdoll","Gripping","Gripper","NoJump","DoingTraining","IsResetting"},
	
	["Crouch"] = {"Blocking","Stun","Action","Stunned","Attacking","DoingHeavy","Dead","UsingMagic","InAir","Action","Knocked","Carrier","Ragdoll","Gripping","Gripper","DoingTraining","IsResetting"},
	["Slide"] = {"HasLog", "Stun","Action","Stunned","Attacking","DoingHeavy","Dead","UsingMagic","InAir","Action","Knocked","Carrier","Ragdoll","Gripping","Gripper","DoingTraining","IsResetting","Crouching"},
}
function Info:StunCheck(Character, ActionName)
	local StatusFolder = Character:FindFirstChild("Status")
	local ToReturn = false
	if StatusFolder then
		local BL = Info.Blacklists[ActionName] or Info.Blacklists.Default
		for i,v in pairs(StatusFolder:GetChildren()) do
			if table.find(BL,v.Name) then
				ToReturn = true
				break
			end
		end
	end
	return ToReturn
end

return Info