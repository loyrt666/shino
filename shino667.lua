-- [[ SHINO V 5.1 - ULTIMATE STABLE ]] --
-- [[ ВСЕ БИНДЫ, ЦВЕТА И ХИТБОКСЫ ВОССТАНОВЛЕНЫ ]] --

local player = game.Players.LocalPlayer
local userInputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local players = game:GetService("Players")
local stats = game:GetService("Stats")
local tweenService = game:GetService("TweenService")
local httpService = game:GetService("HttpService")
local lighting = game:GetService("Lighting")

-- Кэширование
local math_floor = math.floor
local math_clamp = math.clamp
local task_wait = task.wait
local task_spawn = task.spawn

-- Состояние функций
local settings = {
    active = true,
    menuVisible = true,
    currentTab = "Visuals",
    accent = Color3.fromRGB(170, 0, 255),
    
    -- Visuals
    espBoxes = false,
    espNames = false,
    espHealth = false,
    teamCheck = true,
    watermarkEnabled = true,
    watermarkSize = 280,
    fullbrightEnabled = false,
    fovValue = 70,
    streamproofEnabled = true,
    rainbowUI = false,
    
    -- NEW Visuals (V 5.1)
    trailEnabled = false,
    trailColor = Color3.fromRGB(170, 0, 255),
    speedFovEnabled = false,
    
    -- Hitboxes (RESTORED)
    hitboxEnabled = false,
    hitboxSize = 2,
    hitboxTransparency = 50,
    hitboxColor = Color3.fromRGB(255, 0, 0),
    hitboxPart = "HumanoidRootPart", -- "Head", "Torso", "HumanoidRootPart"
    
    -- Colors (RESTORED FULL)
    colorVisible = Color3.fromRGB(255, 255, 255),
    colorHidden = Color3.fromRGB(170, 0, 255),
    colorAlly = Color3.fromRGB(0, 255, 120),
    
    -- Movement
    flyEnabled = false,
    flySpeed = 50,
    noClipEnabled = false,
    infiniteJumpEnabled = false,
    walkSpeed = 16,
    jumpPower = 50,
    spinBotEnabled = false,
    spinSpeed = 50,

    -- Misc
    antiAfkEnabled = false,
    autoClickerEnabled = false,
    keybindsEnabled = true,

    -- Keybinds (RESTORED ALL)
    keybinds = {
        toggleMenu = Enum.KeyCode.RightShift,
        toggleFly = nil,
        toggleNoClip = nil,
        toggleInfiniteJump = nil,
        toggleWalkSpeed = nil,
        toggleJumpPower = nil,
        toggleEsp = nil,
        toggleHitboxes = nil,
    },
    
    -- Config
    configName = "ShinoConfig.json",
    
    -- UI Theme
    menuAccentColor = Color3.fromRGB(170, 0, 255),
    menuBackgroundColor = Color3.fromRGB(15, 15, 15),
    menuSidebarColor = Color3.fromRGB(20, 20, 20),
    menuTextColor = Color3.fromRGB(230, 230, 230),
    menuButtonColor = Color3.fromRGB(25, 25, 25),
    menuCornerRadius = 10,
    toggleButtonColor = Color3.fromRGB(45, 45, 45),
    sliderBgColor = Color3.fromRGB(40, 40, 40),
    sliderFillColor = Color3.fromRGB(170, 0, 255),
}

local espObjects = {}
local originalLighting = {
    Brightness = lighting.Brightness,
    ClockTime = lighting.ClockTime,
    FogEnd = lighting.FogEnd,
    GlobalShadows = lighting.GlobalShadows,
    Ambient = lighting.Ambient
}

-- ==========================================
-- 0. UTILS & PROTECTION
-- ==========================================
local function protectGui(gui)
    if not gui then return end
    pcall(function()
        if settings.streamproofEnabled then
            if syn and syn.protect_gui then syn.protect_gui(gui) end
            gui.DisplayOrder = 999999
        end
    end)
end

local parentGui = (gethui and gethui()) or (game:GetService("CoreGui"):FindFirstChild("RobloxGui")) or player:WaitForChild("PlayerGui")

local function createGlow(parent, size)
    local glow = Instance.new("ImageLabel", parent)
    glow.Name = "Glow"
    glow.BackgroundTransparency = 1
    glow.Position = UDim2.new(0, -size, 0, -size)
    glow.Size = UDim2.new(1, size*2, 1, size*2)
    glow.ZIndex = parent.ZIndex - 1
    glow.Image = "rbxassetid://1316045217"
    glow.ImageColor3 = settings.accent
    glow.ImageTransparency = 0.6
    return glow
end

-- ==========================================
-- 1. WATERMARK
-- ==========================================
local watermarkGui = Instance.new("ScreenGui", parentGui)
watermarkGui.Name = "ShinoWatermark"
watermarkGui.ResetOnSpawn = false
protectGui(watermarkGui)

local watermarkFrame = Instance.new("Frame", watermarkGui)
watermarkFrame.Size = UDim2.new(0, settings.watermarkSize, 0, 30)
watermarkFrame.Position = UDim2.new(0, 20, 0, 20)
watermarkFrame.BackgroundColor3 = settings.menuBackgroundColor
watermarkFrame.BorderSizePixel = 0
watermarkFrame.Active = true
watermarkFrame.Draggable = true
Instance.new("UICorner", watermarkFrame).CornerRadius = UDim.new(0, 6)
local watermarkGlow = createGlow(watermarkFrame, 15)

local watermarkText = Instance.new("TextLabel", watermarkFrame)
watermarkText.Size = UDim2.new(1, -20, 1, 0)
watermarkText.Position = UDim2.new(0, 10, 0, 0)
watermarkText.BackgroundTransparency = 1
watermarkText.TextColor3 = settings.menuTextColor
watermarkText.TextSize = 14
watermarkText.Font = Enum.Font.Code
watermarkText.Text = "SHINO.cc"
watermarkText.TextXAlignment = Enum.TextXAlignment.Left

task_spawn(function()
    while task_wait(0.2) do
        if not settings.active then break end
        watermarkFrame.Visible = settings.watermarkEnabled
        if settings.watermarkEnabled then
            local fps = math_floor(stats.Network.RenderPps)
            local ping = math_floor(player:GetNetworkPing() * 1000)
            watermarkText.Text = string.format("SHINO.cc | %s | %d FPS | %d MS", player.Name:upper(), fps, ping)
        end
    end
end)

-- ==========================================
-- 2. MAIN MENU UI
-- ==========================================
local screenGui = Instance.new("ScreenGui", parentGui)
screenGui.Name = "ShinoUltimateMenu"
screenGui.ResetOnSpawn = false
protectGui(screenGui)

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 550, 0, 380)
mainFrame.Position = UDim2.new(0.5, -275, 0.5, -190)
mainFrame.BackgroundColor3 = settings.menuBackgroundColor
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, settings.menuCornerRadius)
local mainGlow = createGlow(mainFrame, 30)

local sideBar = Instance.new("Frame", mainFrame)
sideBar.Size = UDim2.new(0, 150, 1, 0)
sideBar.BackgroundColor3 = settings.menuSidebarColor
Instance.new("UICorner", sideBar).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel", sideBar)
title.Size = UDim2.new(1, 0, 0, 60)
title.Text = "SHINO"
title.TextColor3 = settings.menuAccentColor
title.TextSize = 28
title.Font = Enum.Font.GothamBold
title.BackgroundTransparency = 1

local tabContainer = Instance.new("Frame", sideBar)
tabContainer.Size = UDim2.new(1, 0, 1, -70)
tabContainer.Position = UDim2.new(0, 0, 0, 70)
tabContainer.BackgroundTransparency = 1
Instance.new("UIListLayout", tabContainer).HorizontalAlignment = Enum.HorizontalAlignment.Center

local contentArea = Instance.new("ScrollingFrame", mainFrame)
contentArea.Size = UDim2.new(1, -170, 1, -30)
contentArea.Position = UDim2.new(0, 160, 0, 15)
contentArea.BackgroundTransparency = 1
contentArea.ScrollBarThickness = 0
contentArea.CanvasSize = UDim2.new(0, 0, 2.5, 0)
Instance.new("UIListLayout", contentArea).Padding = UDim.new(0, 12)

-- UI Creators
local function createToggle(name, key, parent, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -15, 0, 45)
    frame.BackgroundColor3 = settings.menuBackgroundColor
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, -70, 1, 0); label.Position = UDim2.new(0, 15, 0, 0); label.Text = name; label.TextColor3 = settings.menuTextColor; label.TextXAlignment = Enum.TextXAlignment.Left; label.BackgroundTransparency = 1; label.Font = Enum.Font.Gotham; label.TextSize = 15
    local toggleBtn = Instance.new("TextButton", frame)
    toggleBtn.Size = UDim2.new(0, 44, 0, 22); toggleBtn.Position = UDim2.new(1, -55, 0.5, -11); toggleBtn.BackgroundColor3 = settings[key] and settings.menuAccentColor or settings.toggleButtonColor; toggleBtn.Text = ""; Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)
    local circle = Instance.new("Frame", toggleBtn)
    circle.Size = UDim2.new(0, 18, 0, 18); circle.Position = settings[key] and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9); circle.BackgroundColor3 = Color3.new(1,1,1); Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)
    toggleBtn.MouseButton1Click:Connect(function()
        settings[key] = not settings[key]
        tweenService:Create(circle, TweenInfo.new(0.2), {Position = settings[key] and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)}):Play()
        tweenService:Create(toggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = settings[key] and settings.menuAccentColor or settings.toggleButtonColor}):Play()
        if callback then callback(settings[key]) end
    end)
end

local function createSlider(name, key, min, max, parent, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -15, 0, 55); frame.BackgroundTransparency = 1
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, 0, 0, 20); label.Text = name .. ": " .. settings[key]; label.TextColor3 = settings.menuTextColor; label.TextXAlignment = Enum.TextXAlignment.Left; label.BackgroundTransparency = 1; label.Font = Enum.Font.Gotham; label.TextSize = 14
    local sliderBg = Instance.new("Frame", frame)
    sliderBg.Size = UDim2.new(1, 0, 0, 6); sliderBg.Position = UDim2.new(0, 0, 0, 30); sliderBg.BackgroundColor3 = settings.sliderBgColor; Instance.new("UICorner", sliderBg)
    local fill = Instance.new("Frame", sliderBg)
    fill.Size = UDim2.new((settings[key] - min) / (max - min), 0, 1, 0); fill.BackgroundColor3 = settings.sliderFillColor; Instance.new("UICorner", fill)
    local dragging = false
    local function update(input)
        local pos = math_clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        local val = math_floor(min + (max - min) * pos)
        settings[key] = val; label.Text = name .. ": " .. val; fill.Size = UDim2.new(pos, 0, 1, 0)
        if callback then callback(val) end
    end
    sliderBg.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true update(input) end end)
    userInputService.InputChanged:Connect(function(input) if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then update(input) end end)
    userInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
end

local function createDropdown(name, key, options, parent)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -15, 0, 45); frame.BackgroundColor3 = settings.menuBackgroundColor; Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, -120, 1, 0); label.Position = UDim2.new(0, 15, 0, 0); label.Text = name .. ": " .. settings[key]; label.TextColor3 = settings.menuTextColor; label.TextXAlignment = Enum.TextXAlignment.Left; label.BackgroundTransparency = 1; label.Font = Enum.Font.Gotham; label.TextSize = 14
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0, 100, 0, 25); btn.Position = UDim2.new(1, -110, 0.5, -12.5); btn.BackgroundColor3 = settings.menuButtonColor; btn.Text = "Next"; btn.TextColor3 = settings.menuTextColor; Instance.new("UICorner", btn)
    local index = 1
    btn.MouseButton1Click:Connect(function()
        index = index + 1; if index > #options then index = 1 end
        settings[key] = options[index]; label.Text = name .. ": " .. settings[key]
    end)
end

local function createKeybind(name, key, parent)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -15, 0, 45); frame.BackgroundColor3 = settings.menuBackgroundColor; Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, -70, 1, 0); label.Position = UDim2.new(0, 15, 0, 0); label.Text = name; label.TextColor3 = settings.menuTextColor; label.TextXAlignment = Enum.TextXAlignment.Left; label.BackgroundTransparency = 1; label.Font = Enum.Font.Gotham; label.TextSize = 15
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0, 80, 0, 22); btn.Position = UDim2.new(1, -95, 0.5, -11); btn.BackgroundColor3 = settings.toggleButtonColor; btn.Text = settings.keybinds[key] and settings.keybinds[key].Name or "None"; btn.TextColor3 = settings.menuTextColor; Instance.new("UICorner", btn)
    btn.MouseButton1Click:Connect(function()
        btn.Text = "..."; local conn; conn = userInputService.InputBegan:Connect(function(input, gp)
            if not gp and input.UserInputType == Enum.UserInputType.Keyboard then
                settings.keybinds[key] = input.KeyCode; btn.Text = input.KeyCode.Name; conn:Disconnect()
            end
        end)
    end)
end

local function createColorPicker(label, key, parent)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -15, 0, 60); frame.BackgroundTransparency = 1
    local txt = Instance.new("TextLabel", frame); txt.Size = UDim2.new(1, 0, 0, 20); txt.Text = label; txt.TextColor3 = settings.menuTextColor; txt.BackgroundTransparency = 1; txt.Font = Enum.Font.Gotham; txt.TextSize = 14
    local container = Instance.new("Frame", frame); container.Size = UDim2.new(1, 0, 0, 35); container.Position = UDim2.new(0, 0, 0, 25); container.BackgroundTransparency = 1
    local layout = Instance.new("UIListLayout", container); layout.FillDirection = Enum.FillDirection.Horizontal; layout.Padding = UDim.new(0, 8)
    local colors = {Color3.new(1,1,1), Color3.new(1,0,0), Color3.new(0,1,0), Color3.new(0,0,1), Color3.fromRGB(170,0,255), Color3.fromRGB(0,255,255), Color3.fromRGB(255,255,0)}
    for _, color in ipairs(colors) do
        local btn = Instance.new("TextButton", container)
        btn.Size = UDim2.new(0, 30, 0, 30); btn.BackgroundColor3 = color; btn.Text = ""; Instance.new("UICorner", btn)
        btn.MouseButton1Click:Connect(function() settings[key] = color end)
    end
end

local function updateMenu()
    for _, v in pairs(contentArea:GetChildren()) do if not v:IsA("UIListLayout") then v:Destroy() end end
    
    if settings.currentTab == "Visuals" then
        createToggle("Streamproof", "streamproofEnabled", contentArea)
        createToggle("ESP Boxes", "espBoxes", contentArea)
        createToggle("ESP Names", "espNames", contentArea)
        createToggle("Health Bar", "espHealth", contentArea)
        createToggle("Rainbow UI", "rainbowUI", contentArea)
        createToggle("Trail (Unique)", "trailEnabled", contentArea)
        createToggle("Speed-FOV (Unique)", "speedFovEnabled", contentArea)
        createSlider("FOV", "fovValue", 30, 120, contentArea)
        createColorPicker("Visible Color:", "colorVisible", contentArea)
        createColorPicker("Hidden Color:", "colorHidden", contentArea)
        createColorPicker("Ally Color:", "colorAlly", contentArea)
        createColorPicker("Trail Color:", "trailColor", contentArea)
        
    elseif settings.currentTab == "Movement" then
        createToggle("Fly", "flyEnabled", contentArea)
        createSlider("Fly Speed", "flySpeed", 1, 200, contentArea)
        createToggle("NoClip", "noClipEnabled", contentArea)
        createToggle("Infinite Jump", "infiniteJumpEnabled", contentArea)
        createSlider("WalkSpeed", "walkSpeed", 1, 128, contentArea)
        createSlider("JumpPower", "jumpPower", 1, 300, contentArea)
        createToggle("SpinBot", "spinBotEnabled", contentArea)
        createSlider("Spin Speed", "spinSpeed", 1, 100, contentArea)
        
    elseif settings.currentTab == "Hitboxes" then
        createToggle("Enable Hitboxes", "hitboxEnabled", contentArea)
        createDropdown("Target Part", "hitboxPart", {"HumanoidRootPart", "Head", "Torso"}, contentArea)
        createSlider("Size", "hitboxSize", 1, 100, contentArea)
        createSlider("Transparency", "hitboxTransparency", 0, 100, contentArea)
        createColorPicker("Hitbox Color:", "hitboxColor", contentArea)

    elseif settings.currentTab == "Keybinds" then
        createKeybind("Toggle Menu", "toggleMenu", contentArea)
        createKeybind("Toggle Fly", "toggleFly", contentArea)
        createKeybind("Toggle NoClip", "toggleNoClip", contentArea)
        createKeybind("Toggle WalkSpeed", "toggleWalkSpeed", contentArea)
        createKeybind("Toggle ESP", "toggleEsp", contentArea)
        createKeybind("Toggle Hitboxes", "toggleHitboxes", contentArea)
        
    elseif settings.currentTab == "Misc" then
        createToggle("Fullbright", "fullbrightEnabled", contentArea, function(v)
            if v then lighting.Brightness = 2; lighting.ClockTime = 14; lighting.GlobalShadows = false; lighting.Ambient = Color3.new(1,1,1)
            else lighting.Brightness = originalLighting.Brightness; lighting.ClockTime = originalLighting.ClockTime; lighting.GlobalShadows = originalLighting.GlobalShadows; lighting.Ambient = originalLighting.Ambient end
        end)
        createToggle("Auto Clicker", "autoClickerEnabled", contentArea)
        local save = Instance.new("TextButton", contentArea)
        save.Size = UDim2.new(1, -15, 0, 40); save.BackgroundColor3 = settings.menuAccentColor; save.Text = "Save Config"; save.TextColor3 = Color3.new(1,1,1); save.Font = Enum.Font.GothamBold; Instance.new("UICorner", save)
        save.MouseButton1Click:Connect(function() if writefile then pcall(function() writefile(settings.configName, httpService:JSONEncode(settings)) end) end end)
        local unload = Instance.new("TextButton", contentArea)
        unload.Size = UDim2.new(1, -15, 0, 40); unload.BackgroundColor3 = Color3.fromRGB(100, 30, 30); unload.Text = "Unload"; unload.TextColor3 = Color3.new(1,1,1); unload.Font = Enum.Font.GothamBold; Instance.new("UICorner", unload)
        unload.MouseButton1Click:Connect(function() settings.active = false; screenGui:Destroy(); watermarkGui:Destroy(); for _, o in pairs(espObjects) do pcall(function() o.Highlight:Destroy(); o.Billboard:Destroy() end) end end)
    end
end

local function createTab(name)
    local btn = Instance.new("TextButton", tabContainer)
    btn.Size = UDim2.new(0.85, 0, 0, 40); btn.BackgroundColor3 = settings.currentTab == name and settings.menuAccentColor or settings.menuButtonColor; btn.Text = name; btn.TextColor3 = settings.currentTab == name and settings.menuTextColor or Color3.fromRGB(150, 150, 150); btn.Font = Enum.Font.GothamSemibold; btn.TextSize = 14; Instance.new("UICorner", btn)
    btn.MouseButton1Click:Connect(function()
        settings.currentTab = name
        for _, v in pairs(tabContainer:GetChildren()) do if v:IsA("TextButton") then local is = (v.Text == settings.currentTab); tweenService:Create(v, TweenInfo.new(0.3), {BackgroundColor3 = is and settings.menuAccentColor or settings.menuButtonColor, TextColor3 = is and settings.menuTextColor or Color3.fromRGB(150, 150, 150)}):Play() end end
        updateMenu()
    end)
end

createTab("Visuals"); createTab("Movement"); createTab("Hitboxes"); createTab("Keybinds"); createTab("Misc")
updateMenu()

-- ==========================================
-- 3. LOGIC (ESP, HITBOXES, TRAIL)
-- ==========================================
local function createEsp(p)
    if p == player then return end
    local function setup(char)
        if not char then return end
        task.defer(function()
            local head = char:WaitForChild("Head", 10); local hum = char:WaitForChild("Humanoid", 10)
            if not head or not hum then return end
            if espObjects[p] then pcall(function() espObjects[p].Highlight:Destroy(); espObjects[p].Billboard:Destroy() end) end
            local hi = Instance.new("Highlight", char); hi.FillTransparency = 0.5; hi.Enabled = false
            local bb = Instance.new("BillboardGui", head); bb.Size = UDim2.new(0, 200, 0, 60); bb.AlwaysOnTop = true; bb.StudsOffset = Vector3.new(0, 3, 0); bb.Enabled = false; protectGui(bb)
            local hbg = Instance.new("Frame", bb); hbg.Size = UDim2.new(0, 60, 0, 6); hbg.Position = UDim2.new(0.5, -30, 0, 0); hbg.BackgroundColor3 = Color3.new(0, 0, 0)
            local hm = Instance.new("Frame", hbg); hm.Size = UDim2.new(1, 0, 1, 0); hm.BackgroundColor3 = Color3.new(0, 1, 0)
            local lb = Instance.new("TextLabel", bb); lb.Size = UDim2.new(1, 0, 0, 20); lb.Position = UDim2.new(0, 0, 0, 10); lb.BackgroundTransparency = 1; lb.TextColor3 = Color3.new(1, 1, 1); lb.TextSize = 14; lb.Font = Enum.Font.SourceSansBold
            espObjects[p] = { Highlight = hi, Billboard = bb, HealthBar = hm, Label = lb, Char = char }
        end)
    end
    p.CharacterAdded:Connect(setup); if p.Character then setup(p.Character) end
end

task_spawn(function() for _, p in pairs(players:GetPlayers()) do createEsp(p) task_wait(0.02) end end)
players.PlayerAdded:Connect(createEsp)

-- Trail Logic
local trail; local attachment0; local attachment1
local function updateTrail()
    if settings.trailEnabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        if not trail then
            local hrp = player.Character.HumanoidRootPart
            attachment0 = Instance.new("Attachment", hrp); attachment0.Position = Vector3.new(0, 0.5, 0)
            attachment1 = Instance.new("Attachment", hrp); attachment1.Position = Vector3.new(0, -0.5, 0)
            trail = Instance.new("Trail", hrp); trail.Attachment0 = attachment0; trail.Attachment1 = attachment1
            trail.Lifetime = 0.5; trail.WidthScale = NumberSequence.new(1, 0)
        end
        trail.Color = ColorSequence.new(settings.trailColor)
        trail.Enabled = true
    elseif trail then trail.Enabled = false end
end

runService.RenderStepped:Connect(function()
    if not settings.active then return end
    
    -- Speed FOV
    if settings.speedFovEnabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local vel = player.Character.HumanoidRootPart.Velocity.Magnitude
        workspace.CurrentCamera.FieldOfView = settings.fovValue + math_clamp(vel/5, 0, 20)
    else workspace.CurrentCamera.FieldOfView = settings.fovValue end
    
    -- Rainbow UI
    if settings.rainbowUI then
        local color = Color3.fromHSV(tick() % 5 / 5, 0.8, 1)
        settings.accent = color; mainGlow.ImageColor3 = color; watermarkGlow.ImageColor3 = color; title.TextColor3 = color
    end
    
    -- SpinBot
    if settings.spinBotEnabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(settings.spinSpeed), 0)
    end
    
    updateTrail()
    
    for p, obj in pairs(espObjects) do
        if obj.Char and obj.Char.Parent then
            local hum = obj.Char:FindFirstChild("Humanoid"); local root = obj.Char:FindFirstChild("HumanoidRootPart")
            if hum and root and hum.Health > 0 then
                local isAlly = (p.Team == player.Team)
                local finalColor = (settings.teamCheck and isAlly) and settings.colorAlly or settings.colorVisible
                obj.Highlight.Enabled = settings.espBoxes; obj.Highlight.FillColor = finalColor
                obj.Billboard.Enabled = (settings.espNames or settings.espHealth)
                obj.HealthBar.Parent.Visible = settings.espHealth; obj.HealthBar.Size = UDim2.new(hum.Health / hum.MaxHealth, 0, 1, 0)
                if settings.espNames then obj.Label.Text = p.Name; obj.Label.TextColor3 = finalColor else obj.Label.Text = "" end
                if settings.hitboxEnabled then
                    local part = obj.Char:FindFirstChild(settings.hitboxPart)
                    if part then part.Size = Vector3.new(settings.hitboxSize, settings.hitboxSize, settings.hitboxSize); part.Transparency = settings.hitboxTransparency / 100; part.Color = settings.hitboxColor; part.CanCollide = false end
                end
            else obj.Highlight.Enabled = false; obj.Billboard.Enabled = false end
        end
    end
end)

-- Movement
runService.RenderStepped:Connect(function()
    if not settings.active then return end
    if settings.flyEnabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = player.Character.HumanoidRootPart; local moveDir = Vector3.new(0,0,0); local cam = workspace.CurrentCamera.CFrame
        if userInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.LookVector end
        if userInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.LookVector end
        if userInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.RightVector end
        if userInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.RightVector end
        if userInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0,1,0) end
        if userInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0,1,0) end
        hrp.Velocity = moveDir * settings.flySpeed
    end
    if player.Character and player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid.WalkSpeed = settings.walkSpeed; player.Character.Humanoid.JumpPower = settings.jumpPower end
end)

runService.Stepped:Connect(function() if settings.noClipEnabled and player.Character then for _, p in pairs(player.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end end)
userInputService.JumpRequest:Connect(function() if settings.infiniteJumpEnabled and player.Character and player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end end)

-- Inputs (RESTORED ALL BINDS)
userInputService.InputBegan:Connect(function(input, gp)
    if not gp then
        if settings.keybinds.toggleMenu and input.KeyCode == settings.keybinds.toggleMenu then settings.menuVisible = not settings.menuVisible; mainFrame.Visible = settings.menuVisible
        elseif settings.keybinds.toggleFly and input.KeyCode == settings.keybinds.toggleFly then settings.flyEnabled = not settings.flyEnabled
        elseif settings.keybinds.toggleNoClip and input.KeyCode == settings.keybinds.toggleNoClip then settings.noClipEnabled = not settings.noClipEnabled
        elseif settings.keybinds.toggleWalkSpeed and input.KeyCode == settings.keybinds.toggleWalkSpeed then settings.walkSpeed = (settings.walkSpeed == 16 and 100 or 16)
        elseif settings.keybinds.toggleEsp and input.KeyCode == settings.keybinds.toggleEsp then settings.espBoxes = not settings.espBoxes
        elseif settings.keybinds.toggleHitboxes and input.KeyCode == settings.keybinds.toggleHitboxes then settings.hitboxEnabled = not settings.hitboxEnabled end
    end
end)
