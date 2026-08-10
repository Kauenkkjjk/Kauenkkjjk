local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local cursorImage = "rbxassetid://114233524919488"

local plr = Players.LocalPlayer
local boxSystem = ReplicatedStorage:WaitForChild("BoxSystem")
local pickupRemote = boxSystem:WaitForChild("PickupBox")
local dropRemote = boxSystem:WaitForChild("DropBox")
local throwRemote = boxSystem:WaitForChild("ThrowBox")

local holding = false
local box = nil
local walking = false
local charging = false

local faceTextureNormal = "rbxassetid://115728117502974"
local faceTextureHolding = "rbxassetid://129720783627832"
local emoticonEnabledHolding = true

local function updateEmoticonAndFace(isHolding)
	local char = plr.Character
	if not char then return end
	
	local emoticon1 = char:FindFirstChild("Emoticon1")
	if emoticon1 then
		local particle = emoticon1:FindFirstChildOfClass("ParticleEmitter")
		if particle then
			particle.Enabled = isHolding and emoticonEnabledHolding or false
		end
	end
	
	local facePart = char:FindFirstChild("Face")
	if facePart then
		local texture = facePart:FindFirstChild("Face")
		if texture and texture:IsA("Texture") then
			texture.Texture = isHolding and faceTextureHolding or faceTextureNormal
		end
	end
end

local throwGui = nil
local power = 0
local maxPower = 100
local beam = nil
local attachment0 = nil
local attachment1 = nil

local beamConfig = {
	width0 = 0.4,
	width1 = 0.1,
	Texture = "rbxassetid://8733216068",
	faceCamera = true,
	textureMode = Enum.TextureMode.Stretch,
	textureLength = 1.5,
	curveHeightMin = 1,
	curveHeightMax = 6,
	throwMinSpeed = 15,
	throwMaxSpeed = 85,
	throwUpVelocity = 25,
}

local anims = {
	pickup = "rbxassetid://107713327284682",
	idle = "rbxassetid://99656006367593",
	walk = "rbxassetid://81719127587157",
	throw = "rbxassetid://122859311309256",
}

local pickupTrack, idleTrack, walkTrack, throwTrack

local function play(id, priority, looped, speed)
	local char = plr.Character
	if not char then return nil end
	
	local hum = char:FindFirstChildOfClass("Humanoid")
	local anim = hum and hum:FindFirstChild("Animator")
	if not anim then return nil end
	
	local a = Instance.new("Animation")
	a.AnimationId = id
	
	local ok, track = pcall(function() return anim:LoadAnimation(a) end)
	if not ok or not track then return nil end
	
	track.Priority = priority or Enum.AnimationPriority.Action
	track.Looped = looped or false
	track:Play()
	if speed then track:AdjustSpeed(speed) end
	return track
end

local function stopAll()
	if pickupTrack then pickupTrack:Stop() pickupTrack = nil end
	if idleTrack then idleTrack:Stop() idleTrack = nil end
	if walkTrack then walkTrack:Stop() walkTrack = nil end
	if throwTrack then throwTrack:Stop() throwTrack = nil end
end

local function getAimDirection()
	local char = plr.Character
	if not char then return Vector3.new(0, 0, -1) end
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return Vector3.new(0, 0, -1) end
	
	local camera = workspace.CurrentCamera
	if not camera then return root.CFrame.LookVector end
	
	return camera.CFrame.LookVector
end

local function startHolding()
	local char = plr.Character
	if not char then return end
	
	local hum = char:FindFirstChildOfClass("Humanoid")
	local anim = hum and hum:FindFirstChild("Animator")
	if not anim then return end
	
	for _, t in ipairs(anim:GetPlayingAnimationTracks()) do t:Stop() end
	
	if anims.pickup ~= "rbxassetid://" then
		pickupTrack = play(anims.pickup, Enum.AnimationPriority.Action, false, 2.0)
		if pickupTrack then
			pickupTrack.Stopped:Wait()
		end
	end
	
	if not holding then return end
	
	if anims.idle ~= "rbxassetid://" then
		idleTrack = play(anims.idle, Enum.AnimationPriority.Action, true)
	end
	
	if anims.walk ~= "rbxassetid://" then
		walkTrack = play(anims.walk, Enum.AnimationPriority.Action, true)
		if walkTrack then walkTrack:Stop() end
	end
	
	walking = false
end

RunService.Heartbeat:Connect(function()
	if not holding then return end
	
	local char = plr.Character
	if not char then return end
	
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum then return end
	
	local moving = hum.MoveDirection.Magnitude > 0.1
	
	if moving ~= walking then
		walking = moving
		if walking then
			if idleTrack then idleTrack:Stop() end
			if walkTrack then walkTrack:Play() end
		else
			if walkTrack then walkTrack:Stop() end
			if idleTrack then idleTrack:Play() end
		end
	end
end)

local function destroyBeam()
	if beam then beam:Destroy() beam = nil end
	if attachment0 then attachment0:Destroy() attachment0 = nil end
	if attachment1 then attachment1:Destroy() attachment1 = nil end
end

local function createBeam()
	destroyBeam()
	
	local char = plr.Character
	if not char then return end
	
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end
	
	attachment0 = Instance.new("Attachment")
	attachment0.Parent = root
	
	attachment1 = Instance.new("Attachment")
	attachment1.Parent = root
	
	beam = Instance.new("Beam")
	beam.Width0 = beamConfig.width0
	beam.Texture = beamConfig.Texture
	beam.Width1 = beamConfig.width1
	beam.FaceCamera = beamConfig.faceCamera
	beam.TextureMode = beamConfig.textureMode
	beam.TextureLength = beamConfig.textureLength
	beam.Attachment0 = attachment0
	beam.Attachment1 = attachment1
	beam.Parent = root
	beam.Enabled = false
end

local function updateBeam()
	if not beam or not attachment0 or not attachment1 then return end
	if not holding or not charging then
		beam.Enabled = false
		return
	end
	beam.Enabled = true
	
	local char = plr.Character
	if not char then return end
	
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end
	
	local aimDir = getAimDirection()
	local powerFactor = power / 100
	
	local throwSpeed = beamConfig.throwMinSpeed + (beamConfig.throwMaxSpeed - beamConfig.throwMinSpeed) * powerFactor
	local v0 = aimDir * throwSpeed + Vector3.new(0, beamConfig.throwUpVelocity, 0)
	local g = workspace.Gravity
	
	local startPos = root.Position
	if box then
		local main = box:FindFirstChild("Main")
		if main then
			startPos = main.Position
		end
	end
	
	local t
	if v0.Y > 0.1 then
		t = 2 * v0.Y / g
	else
		t = 0.3
	end
	
	local landingPos = startPos + Vector3.new(v0.X * t, 0, v0.Z * t)
	
	attachment0.Position = root.CFrame:VectorToObjectSpace(startPos - root.Position)
	attachment1.Position = root.CFrame:VectorToObjectSpace(landingPos - root.Position)
	
	local arcHeight = 0
	if v0.Y > 0.1 then
		arcHeight = (v0.Y * v0.Y) / (2 * g)
	end
	arcHeight = math.clamp(arcHeight, beamConfig.curveHeightMin, beamConfig.curveHeightMax)
	beam.CurveSize0 = arcHeight
	beam.CurveSize1 = arcHeight
	
	local colorLow = Color3.fromRGB(80, 255, 120)
	local colorMid = Color3.fromRGB(255, 220, 60)
	local colorHigh = Color3.fromRGB(255, 60, 40)
	local color
	if powerFactor < 0.5 then
		color = colorLow:Lerp(colorMid, powerFactor * 2)
	else
		color = colorMid:Lerp(colorHigh, (powerFactor - 0.5) * 2)
	end
	local endColor = Color3.new(color.R * 0.35, color.G * 0.35, color.B * 0.35)
	beam.Color = ColorSequence.new(color, endColor)
	beam.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.15),
		NumberSequenceKeypoint.new(0.7, 0.4),
		NumberSequenceKeypoint.new(1, 0.85),
	})
	beam.Width0 = beamConfig.width0 + powerFactor * 0.4
	beam.Width1 = beamConfig.width1
end

plr.CharacterAdded:Connect(function()
	holding = false
	box = nil
	walking = false
	charging = false
	power = 0
	stopAll()
	destroyBeam()
	if throwGui then throwGui.Enabled = false end
	updateEmoticonAndFace(false)
end)

local mouse = plr:GetMouse()
local lastTarget = nil

mouse.Move:Connect(function()
	local target = mouse.Target
	local isBox = false
	
	if target then
		local model = target:FindFirstAncestorOfClass("Model")
		if model and model.Name == "Box" then
			isBox = true
		end
	end
	
	if isBox and not holding then
		mouse.Icon = cursorImage
	elseif lastTarget and not isBox then
		mouse.Icon = ""
	end
	
	lastTarget = target
end)

local function setupThrowGui()
	throwGui = plr:WaitForChild("PlayerGui"):WaitForChild("ThrowGui")
	local mainFrame = throwGui.MainFrame
	local powerFrame = mainFrame.PowerFrame
	local powerFill = powerFrame.Fill
	local powerText = powerFrame.PowerText
	local throwButton = mainFrame.ThrowButton
	
	local function updatePowerVisual()
		local pf = power / maxPower
		powerFill.Size = UDim2.new(1, 0, pf, 0)
		powerText.Text = math.floor(power) .. "%"
		local r = math.min(pf * 2, 1)
		local g = math.min((1 - pf) * 2, 1)
		powerFill.BackgroundColor3 = Color3.new(r, g, 0.15)
	end
	
	local chargeSpeed = 55
	
	local function startCharging()
		if not holding then return end
		charging = true
		throwButton.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
		throwButton.UILINE.Color = Color3.fromRGB(85, 0, 0)
		createBeam()
		
		task.spawn(function()
			local direction = 1
			while charging do
				power = power + chargeSpeed * 0.016 * direction
				if power >= maxPower then
				power = maxPower
				direction = -1
				elseif power <= 0 then
				power = 0
				direction = 1
				end
				updatePowerVisual()
				task.wait()
			end
		end)
	end
	
	local function releaseThrow()
		if not charging then return end
		charging = false
		throwButton.BackgroundColor3 = Color3.fromRGB(94, 211, 141)
		throwButton.UILINE.Color = Color3.fromRGB(0, 118, 87)
		
		if power > 10 and holding and box then
			local char = plr.Character
			if char then
				local root = char:FindFirstChild("HumanoidRootPart")
				if root then
					local aimDir = getAimDirection()
					local powerFactor = power / 100
					local throwSpeed = beamConfig.throwMinSpeed + (beamConfig.throwMaxSpeed - beamConfig.throwMinSpeed) * powerFactor
					local distance = throwSpeed
					
					if anims.throw ~= "rbxassetid://" then
						throwTrack = play(anims.throw, Enum.AnimationPriority.Action, false, 1.5)
					end
					
					throwRemote:FireServer(aimDir, power, distance)
				end
			end
		end
		
		power = 0
		updatePowerVisual()
		destroyBeam()
	end
	
	throwButton.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			startCharging()
		end
	end)
	
	throwButton.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			releaseThrow()
		end
	end)
	
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if input.KeyCode == Enum.KeyCode.Q then
			if holding then
				pickupRemote:FireServer("Drop")
			end
		end
	end)
end

pickupRemote.OnClientEvent:Connect(function(action, b)
	if action == "StartPickup" then
		holding = true
		box = b
		startHolding()
		if throwGui then throwGui.Enabled = true end
		updateEmoticonAndFace(true)
	elseif action == "ThrowSuccess" then
		holding = false
		box = nil
		charging = false
		power = 0
		stopAll()
		destroyBeam()
		if throwGui then throwGui.Enabled = false end
		updateEmoticonAndFace(false)
	end
end)

dropRemote.OnClientEvent:Connect(function(action)
	if action == "Dropped" then
		holding = false
		box = nil
		charging = false
		power = 0
		stopAll()
		destroyBeam()
		if throwGui then throwGui.Enabled = false end
		updateEmoticonAndFace(false)
	end
end)

RunService.RenderStepped:Connect(function()
	updateBeam()
end)

setupThrowGui()
