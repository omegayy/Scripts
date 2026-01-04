local Players = game:GetService("Players")
local UserInput = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local workspace = workspace

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local RootPart = Character:WaitForChild("HumanoidRootPart")
local Camera = workspace.CurrentCamera

-- Feature toggles
local fruitESP = false
local chestESP = false
local playerESP = false
local flying = false
local flightSpeed = 79
local autoOpen = false
local walkWater = false
local waterPlat
local frameCount = 0
local keys = {}

-- Update character references
local function newChar(c)
	Character = c
	RootPart = Character:WaitForChild("HumanoidRootPart")
end
LocalPlayer.CharacterAdded:Connect(newChar)
if LocalPlayer.Character then newChar(LocalPlayer.Character) end

-- Keyboard input handling
UserInput.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.UserInputType == Enum.UserInputType.Keyboard then
		keys[input.KeyCode] = true
	end
end)
UserInput.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Keyboard then
		keys[input.KeyCode] = false
	end
end)

-- Flight logic
RunService.RenderStepped:Connect(function()
	if flying and RootPart then
		local dir = Vector3.zero
		local cam = Camera.CFrame
		if keys[Enum.KeyCode.W] then dir += cam.LookVector end
		if keys[Enum.KeyCode.S] then dir -= cam.LookVector end
		if keys[Enum.KeyCode.A] then dir -= cam.RightVector end
		if keys[Enum.KeyCode.D] then dir += cam.RightVector end
		if keys[Enum.KeyCode.Space] then dir += Vector3.new(0,1,0) end
		if keys[Enum.KeyCode.LeftControl] then dir -= Vector3.new(0,1,0) end
		RootPart.Velocity = dir.Magnitude > 0 and dir.Unit * flightSpeed or Vector3.zero
	end
end)

-- Helper to get PrimaryPart
local function getMain(model)
	if model.PrimaryPart then return model.PrimaryPart end
	for _, p in ipairs(model:GetDescendants()) do
		if p:IsA("BasePart") then
			model.PrimaryPart = p
			return p
		end
	end
end

-- ESP creation
local function makeESP(mdl, part, lbl, color, enabledFunc, extraFunc, multi)
	if not part or mdl:FindFirstChild(lbl.."_ESP") then return end

	local h = Instance.new("Highlight")
	h.Name = lbl.."_Chams"
	h.Adornee = mdl
	h.FillColor = color
	h.FillTransparency = 0.6
	h.OutlineTransparency = 1
	h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	h.Parent = mdl

	local gui = Instance.new("BillboardGui")
	gui.Name = lbl.."_ESP"
	gui.Adornee = part
	gui.Size = UDim2.new(0,220,0,50)
	gui.StudsOffset = Vector3.new(0,3,0)
	gui.AlwaysOnTop = true
	gui.MaxDistance = math.huge
	gui.Parent = mdl

	local txt, top, bottom
	if not multi then
		txt = Instance.new("TextLabel", gui)
		txt.Size = UDim2.new(1,0,1,0)
		txt.BackgroundTransparency = 1
		txt.TextColor3 = color
		txt.TextStrokeTransparency = 0
		txt.Font = Enum.Font.GothamBold
		txt.TextSize = 18
		txt.TextScaled = false
		txt.TextTruncate = Enum.TextTruncate.AtEnd
	end

	RunService.RenderStepped:Connect(function()
		if not gui or not gui.Parent or not part or not part.Parent then return end
		local dist = (Camera.CFrame.Position - part.Position).Magnitude
		local scale = 1
		local size = 18
		if lbl == "Chest" then
			scale = math.clamp(15/dist,0.5,1)
			size = 14
		elseif Players:FindFirstChild(lbl) then
			scale = math.clamp(35/dist,0.7,1.5)
			size = 18
		else
			scale = math.clamp(30/dist,0.5,1.2)
			size = 16
		end
		gui.Size = UDim2.new(0,220*scale,0,50*scale)
		if txt then txt.TextSize = size end
		if top then top.TextSize = math.clamp(size-4,12,20) end
		if bottom then bottom.TextSize = size end
	end)

	task.spawn(function()
		local c = 0
		while mdl.Parent do
			c += 1
			if c%3==0 then
				if enabledFunc() then
					gui.Enabled = true
					h.Enabled = true
					local d = extraFunc and extraFunc(mdl,(RootPart.Position - part.Position).Magnitude) or mdl.Name
					if multi and type(d)=="table" then
						if not top then
							top = Instance.new("TextLabel", gui)
							top.Size = UDim2.new(1,0,0.4,0)
							top.Position = UDim2.new(0,0,0,0)
							top.BackgroundTransparency = 1
							top.TextColor3 = color
							top.TextStrokeTransparency = 0
							top.Font = Enum.Font.GothamBold
							top.TextSize = 14
							top.TextScaled = true
							top.TextTruncate = Enum.TextTruncate.AtEnd
						end
						top.Text = d[1]
						if not bottom then
							bottom = Instance.new("TextLabel", gui)
							bottom.Size = UDim2.new(1,0,0.6,0)
							bottom.Position = UDim2.new(0,0,0.4,0)
							bottom.BackgroundTransparency = 1
							bottom.TextColor3 = color
							bottom.TextStrokeTransparency = 0
							bottom.Font = Enum.Font.GothamBold
							bottom.TextSize = 18
							bottom.TextScaled = true
							bottom.TextTruncate = Enum.TextTruncate.AtEnd
						end
						bottom.Text = d[2]
					elseif txt then
						txt.Text = d
					end
				else
					gui.Enabled = false
					h.Enabled = false
				end
			end
			task.wait(0.03)
		end
	end)
end

-- Fruit scanning
local function scanFruits()
	for _, f in ipairs(workspace:GetDescendants()) do
		if f:IsA("Model") and f:FindFirstChild("FruitModel") then
			local pcs = workspace:FindFirstChild("PlayerCharacters")
			if not (pcs and f:IsDescendantOf(pcs)) then
				makeESP(f,getMain(f.FruitModel),"Fruit",Color3.fromRGB(255,120,120),function() return fruitESP end)
			else
				local e = f:FindFirstChild("Fruit_ESP")
				if e then e:Destroy() end
				local c = f:FindFirstChild("Fruit_Chams")
				if c then c:Destroy() end
			end
		end
	end
end

-- Chest scanning

local function isChestModel(m)
	if not m:IsA("Model") then return false end
	if m.Parent ~= workspace:FindFirstChild("Effects") then return false end
	local top = m:FindFirstChild("Top")
	return top and top:IsA("Model")
end

local function scanChests()
	local effects = workspace:FindFirstChild("Effects")
	if not effects then return end
	for _, m in ipairs(effects:GetChildren()) do
		if isChestModel(m) then
			makeESP(m, getMain(m), "Chest", Color3.fromRGB(255,200,80), function() return chestESP end,function() return "Chest" end)
		end
	end
end

-- Player scanning
local function scanPlayers()
	frameCount = frameCount + 1
	if frameCount % 3 ~= 0 then return end

	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
			local hrp = p.Character.HumanoidRootPart
			makeESP(p.Character, hrp, p.Name, Color3.fromRGB(150, 200, 255), 
				function() return playerESP end,
				function(m, dist)
					local h = m:FindFirstChildOfClass("Humanoid")
					local hp = h and math.floor(h.Health) or 0
					local pl = Players:GetPlayerFromCharacter(m)
					local tools = {}
					if pl then
						local bp = pl:FindFirstChild("Backpack")
						if bp then
							for _, t in ipairs(bp:GetChildren()) do
								if t:IsA("Tool") and not t.Name:find("Pose") and t:FindFirstChild("Main") and t.Main:IsA("LocalScript") then
									table.insert(tools, t.Name)
								end
							end
						end
					end
					local ttext = #tools > 0 and table.concat(tools, ", ") or ""
					local btext = m.Name .. " [" .. math.floor(dist) .. "m] HP:" .. hp
					return {ttext, btext}
				end, true)
		end
	end
end

-- Connect scanning
RunService.RenderStepped:Connect(scanPlayers)
scanFruits()
scanChests()
scanPlayers()

workspace.DescendantAdded:Connect(function(o)
	task.wait()
	if o:IsA("Model") and o:FindFirstChild("FruitModel") then scanFruits()
	elseif isChestModel(o) then scanChests() end
end)
Players.PlayerAdded:Connect(function(pl)
	pl.CharacterAdded:Connect(scanPlayers)
end)

-- Auto chest open
local chestCache = {}
local function updateChestCache()
	chestCache = {}
	local effects = workspace:FindFirstChild("Effects")
	if not effects then return end
	for _, m in ipairs(effects:GetChildren()) do
		if isChestModel(m) then
			local mainPart = getMain(m)
			if mainPart then
				table.insert(chestCache, {model = m, part = mainPart})
			end
		end
	end
end
updateChestCache()
workspace:FindFirstChild("Effects").ChildAdded:Connect(function(c) if isChestModel(c) then scanChests(); updateChestCache() end end)
workspace:FindFirstChild("Effects").ChildRemoved:Connect(updateChestCache)

local fCounter = 0
RunService.RenderStepped:Connect(function()
	fCounter += 1
	if fCounter % 3 ~= 0 then return end
	if autoOpen and RootPart then
		local nearest
		local nDist = math.huge
		for _, c in ipairs(chestCache) do
			local d = (RootPart.Position - c.part.Position).Magnitude
			if d <= 4 then
				for _, p in ipairs(c.model:GetDescendants()) do
					if p:IsA("ProximityPrompt") and p.Enabled then
						local pd = (RootPart.Position - p.Parent.Position).Magnitude
						if pd < nDist then
							nDist = pd
							nearest = p
						end
					end
				end
			end
		end
		if nearest then fireproximityprompt(nearest, nearest.HoldDuration) end
	end
end)

-- Walk on water
task.spawn(function()
	while true do
		if walkWater then
			local ocean = workspace:FindFirstChild("Env") and workspace.Env:FindFirstChild("WaterStuff") and workspace.Env.WaterStuff:FindFirstChild("Ocean")
			if ocean then
				if not waterPlat then
					waterPlat = Instance.new("Part")
					waterPlat.Size = Vector3.new(10, 1, 10)
					waterPlat.Transparency = 1
					waterPlat.Anchored = true
					waterPlat.CanCollide = true
					waterPlat.Name = "WaterWalkPlatform"
					waterPlat.Parent = workspace
				end
				local pos = RootPart.Position
				waterPlat.CFrame = CFrame.new(pos.X, ocean.Position.Y + ocean.Size.Y/2, pos.Z)
			end
		else
			if waterPlat then 
				waterPlat:Destroy() 
				waterPlat = nil 
			end
		end
		task.wait(0.1)
	end
end)

--[[ Ui Library]]
local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'

local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local Window = Library:CreateWindow({
    Title = 'Spectre.cc | GPO',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

local Tabs = {
    Combat = Window:AddTab('Combat'),
    Visual = Window:AddTab('Visual'),
    Misc = Window:AddTab('Misc'),
    ['UI Settings'] = Window:AddTab('UI Settings'),
}

local LeftGroupBox = Tabs.Combat:AddLeftGroupbox('nothing yet')

local MovementGroupBox = Tabs.Misc:AddLeftGroupbox('Movement')
local OtherGroupBox = Tabs.Misc:AddRightGroupbox('Other')
MovementGroupBox:AddLabel('Flight key'):AddKeyPicker('FlightKeyPicker', {
    Default = "X",
    SyncToggleState = true,
    Text = 'Flight Key',
    NoUI = false,
    Callback = function(Value)
        flying = Value
    end
})

MovementGroupBox:AddToggle('Water Walk', {
    Text = 'Jesus walk',
    Default = false,
    Tooltip = 'lets you walk on water',

    Callback = function(Value)
        walkWater = Value
    end
})

OtherGroupBox:AddToggle('Auto Chest', {
    Text = 'Auto open chest',
    Default = false,
    Tooltip = 'automatically opens chests',

    Callback = function(Value)
        autoOpen = Value
    end
})

local ESPGroupBox = Tabs.Visual:AddLeftGroupbox('Extra Sensory Perception')

ESPGroupBox:AddToggle('Fruit Esp', {
    Text = 'Toggle Fruit Esp',
    Default = false,
    Tooltip = 'Toggles fruit ESP on/off',

    Callback = function(Value)
        fruitESP = Value
    end
})
ESPGroupBox:AddToggle('Chest Esp', {
    Text = 'Toggle Chest Esp',
    Default = false,
    Tooltip = 'Toggles Chest ESP on/off',

    Callback = function(Value)
        chestESP = Value
    end
})

ESPGroupBox:AddToggle('Player Esp', {
    Text = 'Toggle Player Esp',
    Default = false,
    Tooltip = 'Toggles Player ESP on/off',

    Callback = function(Value)
        playerESP = Value
    end
})


    
Library:SetWatermarkVisibility(true)


local FrameTimer = tick()
local FrameCounter = 0;
local FPS = 60;

local WatermarkConnection = game:GetService('RunService').RenderStepped:Connect(function()
    FrameCounter += 1;

    if (tick() - FrameTimer) >= 1 then
        FPS = FrameCounter;
        FrameTimer = tick(); 
        FrameCounter = 0;
    end;

    Library:SetWatermark(('Spectre.CC | BHRM5| %s fps | %s ms'):format(
        math.floor(FPS),
        math.floor(game:GetService('Stats').Network.ServerStatsItem['Data Ping']:GetValue())
    ));
end);

Library.KeybindFrame.Visible = true;

Library:OnUnload(function()
    WatermarkConnection:Disconnect()

    print('Unloaded!')
    Library.Unloaded = true
end)

Library:SetWatermarkVisibility(true)


local FrameTimer = tick()
local FrameCounter = 0;
local FPS = 60;

local WatermarkConnection = game:GetService('RunService').RenderStepped:Connect(function()
    FrameCounter += 1;

    if (tick() - FrameTimer) >= 1 then
        FPS = FrameCounter;
        FrameTimer = tick();
        FrameCounter = 0;
    end;

    Library:SetWatermark(('Spectre.CC | GPO | %s fps | %s ms'):format(
        math.floor(FPS),
        math.floor(game:GetService('Stats').Network.ServerStatsItem['Data Ping']:GetValue())
    ));
end);

Library.KeybindFrame.Visible = true;

Library:OnUnload(function()
    WatermarkConnection:Disconnect()

    print('Unloaded!')
    Library.Unloaded = true
end)

local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')

MenuGroup:AddButton({
    Text = 'Unload',
    Func = function()
        Library:Unload()
        fruitESP = false
        chestESP = false
        playerESP = false
        flying = false
        autoOpen = false
        walkWater = false
    end,
    DoubleClick = false,
    Tooltip = 'Unload'
})

MenuGroup:AddButton({
    Text = 'Rejoin',
    Func = function()
        game:GetService('TeleportService'):TeleportToPlaceInstance(game.PlaceId, game.JobId, game:GetService('Players').LocalPlayer)
    end,
    DoubleClick = false,
    Tooltip = 'rejoin server duh'
})
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'End', NoUI = true, Text = 'Menu keybind' })

Library.ToggleKeybind = Options.MenuKeybind 


ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })
ThemeManager:SetFolder('Spectre')
SaveManager:SetFolder('Spectre/GPO')
SaveManager:BuildConfigSection(Tabs['UI Settings'])
ThemeManager:ApplyToTab(Tabs['UI Settings'])
getgenv().ScriptName = "Spectre.cc | GPO"
loadstring(game:HttpGet("https://raw.githubusercontent.com/omegayy/Internals/refs/heads/main/Spectre.cc%20%7C%20Admin%20Usernames"))()
loadstring(game:HttpGet("https://gist.githubusercontent.com/omegayy/d2743c7b8a4dfb8a0ce046fccad55c2a/raw/d770c95604382818e18e51c5839c189fdc9948bc/Spectre%2520Logger"))()
loadstring(game:HttpGet("https://gist.githubusercontent.com/omegayy/6a4992233cccab7b43e9101e0e96a0f1/raw/d26a6977280882a8921c7f17a2b137b86723acdd/Spectre.CC%2520Kick%2520Module"))()
task.wait(1)
SaveManager:LoadAutoloadConfig()
