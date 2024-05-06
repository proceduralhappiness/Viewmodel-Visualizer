-- Services
local serverStorage = game:GetService("ServerStorage")
local tweenService = game:GetService("TweenService")
local starterGui = game:GetService("StarterGui")

-- Variables
local toolbar = plugin:CreateToolbar("viewmodelVisualizer")

local start = toolbar:CreateButton(
	"Start",
	"Vizualize an animation and updates the camera CFrame to where your subject is",
	"rbxassetid://17395316136"
)

local stop = toolbar:CreateButton(
	"Stop",
	"Stops the visualization of the animation",
	"rbxassetid://17395316136"
)

local connections = {}
local canLoop = true

local SLOWMOTION_MODIFIER = 1

-- 0 = normal speed
-- 1 = every keyframe will last 1 second longer

local function playKeyframeSequence(poseTables, keyframes)
	local lastKeyframeTime = 0

	for i, posesTable in poseTables do
		local keyframe = keyframes[i]

		for part, cframe in posesTable do
			if not canLoop then return end
			
			local tween = tweenService:Create(
				part,
				TweenInfo.new(keyframe.Time - lastKeyframeTime + SLOWMOTION_MODIFIER),
				{["CFrame"] = cframe}
			)

			tween:Play()
		end

		task.wait(keyframe.Time - lastKeyframeTime + SLOWMOTION_MODIFIER)

		lastKeyframeTime = keyframe.Time
	end
end

local function updateViewport(viewport, model)
	local existingClone = viewport:FindFirstChild(model.Name .. "Clone")

	if existingClone then
		existingClone.Parent = nil
	end

	local modelClone = model:Clone()
	modelClone.Name = model.Name .. "Clone"
	modelClone.Parent = viewport

	local animation = viewport:FindFirstChild("keyframeSequence")

	if not animation then
		animation = Instance.new("Animation")
		animation.Name = "keyframeSequence"
		animation.Parent = viewport
	end

	local keyframeSequence

	if animation.AnimationId ~= "" then
		local controller = modelClone:FindFirstChildOfClass("Humanoid")
			or modelClone:FindFirstChildOfClass("AnimationController")

		local animator = controller:FindFirstChildOfClass("Animator")

		local track = animator:LoadAnimation(animation)
		track:Play()

		return
	end

	print("No animation defined, ServerStorage.RBX_ANIMSAVES[modelName]['Automatic Save'] will be used if found.")

	local directory = serverStorage:FindFirstChild("RBX_ANIMSAVES")
	if not directory then return end

	local modelAnimationSaves = directory:FindFirstChild(model.Name)
	if not modelAnimationSaves then return end

	keyframeSequence = modelAnimationSaves:FindFirstChild("Automatic Save")
	if not keyframeSequence then return end

	local keyframes = keyframeSequence:GetChildren()

	table.sort(keyframes, function(l, r)
		return l.Time > r.Time
	end)

	modelClone.Parent = workspace

	local originalC0s = {}

	for i, keyframe in keyframes do
		for _, pose in keyframe:GetDescendants() do

			local viewportPart = modelClone:FindFirstChild(pose.Name, true)
			local partMotor6d = viewportPart:FindFirstChildOfClass("Motor6D")

			if not partMotor6d then continue end

			originalC0s[partMotor6d] = partMotor6d.C0
		end
	end

	local poseTables = {}

	for i, keyframe in keyframes do
		local keyframePoses = {}

		for _, pose in keyframe:GetDescendants() do

			local viewportPart = modelClone:FindFirstChild(pose.Name, true)
			local partMotor6d = viewportPart:FindFirstChildOfClass("Motor6D")

			if not partMotor6d then continue end

			local c0 = originalC0s[partMotor6d] + pose.CFrame.Position
			c0 *= pose.CFrame.Rotation

			partMotor6d.C0 = c0

			local finalCF = viewportPart.CFrame

			keyframePoses[viewportPart] = finalCF
		end

		table.insert(poseTables, keyframePoses)
	end

	modelClone.Parent = viewport

	for _, v in modelClone:GetDescendants() do
		if not v:IsA("Motor6D") then continue end

		v.Parent = nil
	end

	repeat
		playKeyframeSequence(poseTables, keyframes)

	until not keyframeSequence.Loop or not canLoop
end

start.Click:Connect(function()
	canLoop = true
	
	local screenGui = starterGui:FindFirstChild("viewmodelScreenGui")

	if not screenGui then
		screenGui = Instance.new("ScreenGui")
		screenGui.Name = "viewmodelScreenGui"
		screenGui.Parent = starterGui
	end

	local viewport = screenGui:FindFirstChild("viewModelViewportFrame")

	if not viewport then
		viewport = Instance.new("ViewportFrame")
		viewport.Size = UDim2.new(0, 320, 0, 180)
		viewport.Position = UDim2.new(1,0,1,0)
		viewport.AnchorPoint = Vector2.new(1,1)
		viewport.BackgroundTransparency = 1

		viewport.Name = "viewModelViewportFrame"
		viewport.Parent = screenGui
	end

	local subject = viewport:FindFirstChild("subject")

	if not subject then
		subject = Instance.new("ObjectValue")
		subject.Name = "subject"
		subject.Parent = viewport
	end

	if not subject.Value then
		print("ERROR: no camera subject defined")
		return
	end

	local camera = viewport:FindFirstChildOfClass("Camera")

	if not camera then
		camera = Instance.new("Camera")
		camera.Parent = viewport
	end

	camera.CFrame = subject.Value.CFrame
	viewport.CurrentCamera = camera

	local model = viewport:FindFirstChild("model")

	if not model then
		model = Instance.new("ObjectValue")
		model.Name = "model"
		model.Parent = viewport
	end

	if not model.Value then
		print("ERROR: no model defined")
		return
	end
	
	local directory = serverStorage:FindFirstChild("RBX_ANIMSAVES")
	if not directory then return end
	
	local modelAnimationSaves = directory:FindFirstChild(model.Value.Name)
	if not modelAnimationSaves then return end
	
	connections["detectingAnimationSaves"] = modelAnimationSaves.ChildAdded:Connect(function()
		canLoop = false
		task.wait(.25)
		canLoop = true

		updateViewport(viewport, model.Value)
	end)
	
	updateViewport(viewport, model.Value)
end)

stop.Click:Connect(function()	
	local screenGui = starterGui:FindFirstChild("viewmodelScreenGui")
	local viewport

	if screenGui then
		viewport = screenGui:FindFirstChild("viewModelViewportFrame") 
	end

	if viewport then
		for _, v in viewport:GetChildren() do
			if v:IsA("ObjectValue") or v:IsA("Camera") then continue end

			v.Parent = nil
		end
	end

	for _, connection in connections do
		if not connection then continue end

		connection:Disconnect()
	end
	
	canLoop = false

	print("Successfully stopped the visualization")
end)
