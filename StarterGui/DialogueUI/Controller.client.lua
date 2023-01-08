-- Dialogue Controller

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ProximityPromptService = game:GetService("ProximityPromptService")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

repeat task.wait() until Player:GetAttribute("DataLoaded") == true

local NPCs = Workspace:WaitForChild("NPCs")

local StatusFolder = Character:WaitForChild("Status")

local Gui = script.Parent
local Root = Gui:WaitForChild("Root")
local DialogueBox = Root.Dialogue
local ResponsesBox = Root.Responses
local TitleBox = Root.Title
local ResponseTemplate = script:WaitForChild("ResponseTemplate")

local LocalConfiguration = {
	isInteracting = false,
	skipAttempt = false,
	
	previousInteract = nil,
}
local UI_To_Toggle = {
	[script.Parent.Parent.HUD] = true,
	[script.Parent.Parent:WaitForChild("BackpackGui")] = true,
	--[script.Parent.Parent:WaitForChild("KeyDisplayer")] = false
}

local PublicConfiguration = script.Parent:WaitForChild("Configuration")
local NPCInformation = PublicConfiguration.NPCs
local MainConfig = require(PublicConfiguration.Main)

local Modules = game:GetService("ReplicatedStorage"):WaitForChild("Modules")
local SoundModule = require(Modules.Client.Effects.Sound)

local function initDialogue(npcName)
	local fetchedInformation = NPCInformation:FindFirstChild(npcName) and require(NPCInformation[npcName]) or nil
	if not fetchedInformation then return end
	
	-- set interacting to true rq lol
	if os.clock() - (LocalConfiguration.previousInteract or 0) < MainConfig.InteractCooldown then
		return -- on cooldown
	end
	
	local ActionObject = Instance.new("Folder")
	ActionObject.Name = "Action"
	ActionObject.Parent = StatusFolder
	
	LocalConfiguration.isInteracting = true
	
	for _ui,_bool in pairs(UI_To_Toggle) do
		_ui.Enabled = not _bool
	end
	
	local dialogueOn = 1
	local currentDialogueTable = fetchedInformation[dialogueOn]
	local redirects = currentDialogueTable.Redirects
	local responses = currentDialogueTable.Responses
	local lastResponse = nil
	
	-- Functions here
	
	local function animateGui(type, ...)
		local Arguments = {...}
		if type == "Start" then
			-- set properties
			TitleBox.NPCName.Text = npcName
			
			-- animate
			DialogueBox.Visible = true
			TitleBox.Visible = true
		end
		if type == "End" then
			DialogueBox.Visible = false
			TitleBox.Visible = false
		end
		if type == "ResponseBox_In" then
			-- response box goes in
			ResponsesBox.Main:TweenPosition(UDim2.new(0,0,0,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, .5, true)
		end
		if type == "ResponseBox_Out" then
			-- goes out
			ResponsesBox.Main:TweenPosition(UDim2.new(1,0,0,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, .5, true)
		end
		if type == "FadeTemplate_In" then
			-- template fade box in
			local object = Arguments[1]
			
			local tween = TweenService:Create(object, TweenInfo.new(.7, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				BackgroundTransparency = .7
			})
			local tween2 = TweenService:Create(object.Label, TweenInfo.new(.7, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				TextStrokeTransparency = .7,
				TextTransparency = 0
			})
			
			tween:Play()
			tween2:Play()			
		end
	end
	local function updateInformation()
		if dialogueOn == "Terminate" or dialogueOn == "Terminate/Success" then
			return
		end
		currentDialogueTable = fetchedInformation[dialogueOn]
		redirects = currentDialogueTable.Redirects
		responses = currentDialogueTable.Responses
	end
	local function doDialogue()
		local function generateResponses()
			-- clearing children
			local function clearChildren()
				for _,child in pairs(ResponsesBox.Main:GetChildren()) do
					if child:IsA("Frame") or child:IsA("ImageLabel") then
						child:Destroy()
					end
				end				
			end
			
			clearChildren()
			-- animate
			animateGui("ResponseBox_In")
			
			local connections = {}
			local function disconnectAll()
				for i = 1,#connections do
					connections[i]:Disconnect()
					connections[i] = nil
				end
				table.clear(connections)
			end
			
			for i = 1, #responses do
				local Clone = ResponseTemplate:Clone()
				Clone.Name = i
				Clone.Label.Text = responses[i]
				Clone.Parent = ResponsesBox.Main

				animateGui("FadeTemplate_In", Clone)

				table.insert(connections, Clone.Label.MouseEnter:Connect(function()
					TweenService:Create(Clone.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
						Transparency = 0,
						Color = Color3.fromRGB(255,255,255)
					}):Play()
				end))
				table.insert(connections, Clone.Label.MouseLeave:Connect(function()
					TweenService:Create(Clone.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
						Transparency = 1,
						Color = Color3.fromRGB(75,75,75)
					}):Play()
				end))
				table.insert(connections, Clone.Label.MouseButton1Click:Connect(function()
					if not LocalConfiguration.isInteracting then return end
					
					disconnectAll()

					local responseNumber = i
					local redirectTo = redirects[responseNumber]
					
					if not currentDialogueTable.LastDialogue then
						warn(responseNumber)
						lastResponse = responseNumber
					end
										
					dialogueOn = redirectTo
					updateInformation() -- update information
					
					if currentDialogueTable.LastDialogue and dialogueOn == "Terminate/Success" then
						-- success, pressed yes
						currentDialogueTable.DoSuccessFunction(Player, responseNumber, lastResponse)
					end
					
					doDialogue() -- repeat					
				end))


			end
		end
		
		animateGui("ResponseBox_Out") -- shouldn't be out, make sure it isnt
		
		if dialogueOn == "Terminate" or dialogueOn == "Terminate/Success" then
			-- finished dialogue
			animateGui("End")
			LocalConfiguration.previousInteract = os.clock()
			
			LocalConfiguration.skipAttempt = false
			LocalConfiguration.isInteracting = false
			
			ActionObject:Destroy()
			
			for _ui,_bool in pairs(UI_To_Toggle) do
				_ui.Enabled = _bool
			end
		else
			
			local canStart = currentDialogueTable.canStart(Player)
			if not canStart then
				dialogueOn = currentDialogueTable.Redirects[canStart]
				updateInformation()
			end
			
			local text = currentDialogueTable.Text

			-- setting prereq text, setting visible amount to 0
			LocalConfiguration.skipAttempt = false
			DialogueBox.Label.MaxVisibleGraphemes = 0
			DialogueBox.Label.Text = text

			-- making writer connection
			local WriteConnection;
			local timePassed = 0
			local maxTime = MainConfig.TextDisplayInterval * string.len(text)

			WriteConnection = RunService.RenderStepped:Connect(function(deltaTime)
				if timePassed >= maxTime or LocalConfiguration.skipAttempt then -- attempt to skip
					-- finished
					WriteConnection:Disconnect()
					WriteConnection = nil
					-- making visible
					DialogueBox.Label.MaxVisibleGraphemes = -1

					-- create responses
					generateResponses()
				else
					timePassed += deltaTime
					DialogueBox.Label.MaxVisibleGraphemes = (timePassed/maxTime)*string.len(text)
					
					local Sound = game.ReplicatedStorage.Assets.Sounds.TypingSound:Clone()
					Sound.Parent = script.Parent.Parent:WaitForChild("Effects")
					Sound:Play()
					task.delay(Sound.TimeLength+.2, function()
						Sound:Destroy()
					end)
				end
			end)
		end
	end
	
	--
	animateGui("Start")
	
	local canStart = currentDialogueTable.canStart(Player)
	
	if not canStart then		
		dialogueOn = redirects[canStart] -- "false" Redirect
		-- set new info
		updateInformation()
	end
	
	-- continue
	
	doDialogue()
end

local function promptTriggered(promptObject, playerTriggered)
	if playerTriggered ~= Player then -- LocalPlayer
		return
	end
	
	if promptObject.Name == "Prompt" then
		if LocalConfiguration.isInteracting then return end -- Already Interacting
		
		local npcName = promptObject:GetAttribute("Name")
		
		if promptObject.Parent and promptObject:IsDescendantOf(workspace.NPCs) and npcName ~= nil then			
			initDialogue(npcName)
		end
	end
end

ProximityPromptService.PromptTriggered:Connect(promptTriggered)
UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	
	if input.KeyCode == Enum.KeyCode.Space then
		-- skip keybind
		if LocalConfiguration.isInteracting then
			LocalConfiguration.skipAttempt = true
		end
	end
end)