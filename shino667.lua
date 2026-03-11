-- [[ SHINO V 4.2 - UPDATED & OPTIMIZED ]] --
local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local userInputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local players = game:GetService("Players")
local stats = game:GetService("Stats")
local tweenService = game:GetService("TweenService")
local httpService = game:GetService("HttpService")
local lighting = game:GetService("Lighting")

-- Кэширование для оптимизации
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
    
    -- Colors
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

    -- Misc
    antiAfkEnabled = false,
    autoClickerEnabled = false,
    keybindsEnabled = true,

    -- Keybinds
    keybinds = {
        toggleMenu = Enum.KeyCode.RightShift,
        toggleFly = nil,
        toggleNoClip = nil,
        toggleInfiniteJump = nil,
        toggleAntiAfk = nil,
    },
    
    -- Config
    configName = "ShinoConfig.json",
    
    -- UI Theme
    menuAccentColor = Color3.fromRGB(170, 0, 255),
    menuBackgroundColor = Color3.fromRGB(15, 15, 15),
    menuSidebarColor = Color3.fromRGB(20, 20, 20),
    menuTextColor = Color3.fromRGB(230, 230, 230),
    menuButtonColor = Color3.fromRGB(25, 25, 25),
    menuButtonHoverColor = Color3.fromRGB(35, 35, 35),
    menuButtonActiveColor = Color3.fromRGB(170, 0, 255),
    menuCornerRadius = 10,
    menuButtonCornerRadius = 8,
    toggleButtonColor = Color3.fromRGB(45, 45, 45),
    toggleCircleColor = Color3.new(1, 1, 1),
    sliderBgColor = Color3.fromRGB(40, 40, 40),
    sliderFillColor = Color3.fromRGB(170, 0, 255),
    colorPickerColors = {Color3.new(1,1,1), Color3.new(1,0,0), Color3.new(0,1,0), Color3.new(0,1,1), Color3.new(1,1,0), Color3.fromRGB(170, 0, 255)},
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
-- 1. WATERMARK
-- ==========================================
local watermarkGui = Instance.new("ScreenGui", playerGui)
watermarkGui.Name = "ShinoWatermark"
watermarkGui.ResetOnSpawn = false

local watermarkFrame = Instance.new("Frame", watermarkGui)
watermarkFrame.Size = UDim2.new(0, settings.watermarkSize, 0, 30)
watermarkFrame.Position = UDim2.new(0, 20, 0, 20)
watermarkFrame.BackgroundColor3 = settings.menuBackgroundColor
watermarkFrame.BorderSizePixel = 0
watermarkFrame.Active = true
watermarkFrame.Draggable = true
Instance.new("UICorner", watermarkFrame).CornerRadius = UDim.new(0, 6)

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
createGlow(watermarkFrame, 15)

local watermarkText = Instance.new("TextLabel", watermarkFrame)
watermarkText.Size = UDim2.new(1, -20, 1, 0)
watermarkText.Position = UDim2.new(0, 10, 0, 0)
watermarkText.BackgroundTransparency = 1
watermarkText.TextColor3 = settings.menuTextColor
watermarkText.TextSize = 14
watermarkText.Font = Enum.Font.Code
watermarkText.Text = "SHINO.cc"
watermarkText.TextXAlignment = Enum.TextXAlignment.Left

local function updateWatermarkVisual()
    watermarkFrame.Visible = settings.watermarkEnabled
    watermarkFrame.Size = UDim2.new(0, settings.watermarkSize, 0, 30)
    watermarkFrame.Active = settings.menuVisible
    watermarkFrame.Draggable = settings.menuVisible
end

task_spawn(function()
    while task_wait(0.2) do
        if not settings.active then break end
        if settings.watermarkEnabled then
            local fps = math_floor(stats.Network.RenderPps)
            local ping = math_floor(player:GetNetworkPing() * 1000)
            watermarkText.Text = string.format("SHINO.cc | %s | %d FPS | %d MS", player.Name:upper(), fps, ping)
        end
        updateWatermarkVisual()
    end
end)

-- ==========================================
-- 2. ГЛАВНОЕ МЕНЮ
-- ==========================================
local screenGui = Instance.new("ScreenGui", playerGui)
screenGui.Name = "ShinoNeonMenu"
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 550, 0, 380)
mainFrame.Position = UDim2.new(0.5, -275, 0.5, -190)
mainFrame.BackgroundColor3 = settings.menuBackgroundColor
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, settings.menuCornerRadius)
createGlow(mainFrame, 30)

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

-- Функции создания элементов
local function createToggle(name, key, parent, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -15, 0, 45)
    frame.BackgroundColor3 = settings.menuBackgroundColor
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, settings.menuButtonCornerRadius)
    
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, -70, 1, 0)
    label.Position = UDim2.new(0, 15, 0, 0)
    label.Text = name
    label.TextColor3 = settings.menuTextColor
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 15
    
    local toggleBtn = Instance.new("TextButton", frame)
    toggleBtn.Size = UDim2.new(0, 44, 0, 22)
    toggleBtn.Position = UDim2.new(1, -55, 0.5, -11)
    toggleBtn.BackgroundColor3 = settings[key] and settings.menuAccentColor or settings.toggleButtonColor
    toggleBtn.Text = ""
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)
    
    local circle = Instance.new("Frame", toggleBtn)
    circle.Size = UDim2.new(0, 18, 0, 18)
    circle.Position = settings[key] and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
    circle.BackgroundColor3 = settings.toggleCircleColor
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)
    
    toggleBtn.MouseButton1Click:Connect(function()
        settings[key] = not settings[key]
        local targetPos = settings[key] and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
        local targetColor = settings[key] and settings.menuAccentColor or settings.toggleButtonColor
        tweenService:Create(circle, TweenInfo.new(0.2), {Position = targetPos}):Play()
        tweenService:Create(toggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
        
        if key == "watermarkEnabled" then updateWatermarkVisual() end
        if callback then callback(settings[key]) end
    end)
end

local function createSlider(name, key, min, max, parent, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -15, 0, 55)
    frame.BackgroundTransparency = 1
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Text = name .. ": " .. settings[key]
    label.TextColor3 = settings.menuTextColor
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    local sliderBg = Instance.new("Frame", frame)
    sliderBg.Size = UDim2.new(1, 0, 0, 6)
    sliderBg.Position = UDim2.new(0, 0, 0, 30)
    sliderBg.BackgroundColor3 = settings.sliderBgColor
    Instance.new("UICorner", sliderBg)
    local fill = Instance.new("Frame", sliderBg)
    fill.Size = UDim2.new((settings[key] - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = settings.sliderFillColor
    Instance.new("UICorner", fill)
    
    local function update(input)
        local pos = math_clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        local val = math_floor(min + (max - min) * pos)
        settings[key] = val
        label.Text = name .. ": " .. val
        fill.Size = UDim2.new(pos, 0, 1, 0)
        if key == "watermarkSize" then updateWatermarkVisual() end
        if callback then callback(val) end
    end
    
    local dragging = false
    sliderBg.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true update(input) end end)
    userInputService.InputChanged:Connect(function(input) if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then update(input) end end)
    userInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
end

local function createKeybind(name, key, parent)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -15, 0, 45)
    frame.BackgroundColor3 = settings.menuBackgroundColor
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, settings.menuButtonCornerRadius)

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, -70, 1, 0)
    label.Position = UDim2.new(0, 15, 0, 0)
    label.Text = name
    label.TextColor3 = settings.menuTextColor
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 15

    local keybindBtn = Instance.new("TextButton", frame)
    keybindBtn.Size = UDim2.new(0, 60, 0, 22)
    keybindBtn.Position = UDim2.new(1, -75, 0.5, -11)
    keybindBtn.BackgroundColor3 = settings.toggleButtonColor
    keybindBtn.Text = settings.keybinds[key] and settings.keybinds[key].Name or "None"
    keybindBtn.TextColor3 = settings.menuTextColor
    Instance.new("UICorner", keybindBtn).CornerRadius = UDim.new(0, settings.menuButtonCornerRadius)

    local waitingForKey = false
    keybindBtn.MouseButton1Click:Connect(function()
        if waitingForKey then return end
        waitingForKey = true
        keybindBtn.Text = "..."
        local inputConnection
        inputConnection = userInputService.InputBegan:Connect(function(input, gp)
            if gp then return end
            if input.UserInputType == Enum.UserInputType.Keyboard then
                if input.KeyCode == Enum.KeyCode.Backspace then
                    settings.keybinds[key] = nil
                    keybindBtn.Text = "None"
                else
                    settings.keybinds[key] = input.KeyCode
                    keybindBtn.Text = input.KeyCode.Name
                end
                waitingForKey = false
                inputConnection:Disconnect()
            end
        end)
    end)
end

local function createColorPicker(label, key, parent)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -15, 0, 60)
    frame.BackgroundTransparency = 1
    local txt = Instance.new("TextLabel", frame)
    txt.Size = UDim2.new(1, 0, 0, 20)
    txt.Text = label
    txt.TextColor3 = settings.menuTextColor
    txt.TextXAlignment = Enum.TextXAlignment.Left
    txt.BackgroundTransparency = 1
    txt.Font = Enum.Font.Gotham
    txt.TextSize = 14
    local container = Instance.new("Frame", frame)
    container.Size = UDim2.new(1, 0, 0, 35)
    container.Position = UDim2.new(0, 0, 0, 25)
    container.BackgroundTransparency = 1
    local layout = Instance.new("UIListLayout", container)
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.Padding = UDim.new(0, 8)
    for _, color in ipairs(settings.colorPickerColors) do
        local btn = Instance.new("TextButton", container)
        btn.Size = UDim2.new(0, 30, 0, 30)
        btn.BackgroundColor3 = color
        btn.Text = ""
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
        btn.MouseButton1Click:Connect(function() settings[key] = color end)
    end
end

-- Обновление освещения для Fullbright
local function updateLighting()
    if settings.fullbrightEnabled then
        lighting.Brightness = 2
        lighting.ClockTime = 14
        lighting.FogEnd = 100000
        lighting.GlobalShadows = false
        lighting.Ambient = Color3.fromRGB(255, 255, 255)
    else
        lighting.Brightness = originalLighting.Brightness
        lighting.ClockTime = originalLighting.ClockTime
        lighting.FogEnd = originalLighting.FogEnd
        lighting.GlobalShadows = originalLighting.GlobalShadows
        lighting.Ambient = originalLighting.Ambient
    end
end

local function updateMenu()
    for _, v in pairs(contentArea:GetChildren()) do if not v:IsA("UIListLayout") then v:Destroy() end end
    
    if settings.currentTab == "Visuals" then
        createToggle("ESP Boxes", "espBoxes", contentArea)
        createToggle("ESP Names", "espNames", contentArea)
        createToggle("Health Bar", "espHealth", contentArea)
        createToggle("Team Check", "teamCheck", contentArea)
        createToggle("Fullbright", "fullbrightEnabled", contentArea, updateLighting)
        createSlider("FOV", "fovValue", 30, 120, contentArea)
        createToggle("Watermark", "watermarkEnabled", contentArea)
        createSlider("Watermark Width", "watermarkSize", 150, 500, contentArea)
        createColorPicker("Visible Enemy Color:", "colorVisible", contentArea)
        createColorPicker("Hidden Enemy Color:", "colorHidden", contentArea)
        createColorPicker("Ally Color:", "colorAlly", contentArea)
        
    elseif settings.currentTab == "Movement" then
        createToggle("Fly", "flyEnabled", contentArea)
        createSlider("Fly Speed", "flySpeed", 1, 200, contentArea)
        createToggle("NoClip", "noClipEnabled", contentArea)
        createToggle("Infinite Jump", "infiniteJumpEnabled", contentArea)
        -- Изменено по просьбе: WalkSpeed от 1 до 128
        createSlider("WalkSpeed", "walkSpeed", 1, 128, contentArea)
        createSlider("JumpPower", "jumpPower", 1, 300, contentArea)
        
    elseif settings.currentTab == "Player" then
        createToggle("Auto Clicker", "autoClickerEnabled", contentArea)
        local line = Instance.new("Frame", contentArea)
        line.Size = UDim2.new(1, -15, 0, 2)
        line.BackgroundColor3 = settings.menuAccentColor
        line.BorderSizePixel = 0
        
        for _, p in pairs(players:GetPlayers()) do
            if p ~= player then
                local playerFrame = Instance.new("Frame", contentArea)
                playerFrame.Size = UDim2.new(1, -15, 0, 45)
                playerFrame.BackgroundColor3 = settings.menuBackgroundColor
                Instance.new("UICorner", playerFrame).CornerRadius = UDim.new(0, settings.menuButtonCornerRadius)

                local playerName = Instance.new("TextLabel", playerFrame)
                playerName.Size = UDim2.new(1, -100, 1, 0)
                playerName.Position = UDim2.new(0, 15, 0, 0)
                playerName.Text = p.Name
                playerName.TextColor3 = settings.menuTextColor
                playerName.TextXAlignment = Enum.TextXAlignment.Left
                playerName.BackgroundTransparency = 1
                playerName.Font = Enum.Font.Gotham
                playerName.TextSize = 15

                local teleportBtn = Instance.new("TextButton", playerFrame)
                teleportBtn.Size = UDim2.new(0, 80, 0, 25)
                teleportBtn.Position = UDim2.new(1, -95, 0.5, -12.5)
                teleportBtn.BackgroundColor3 = settings.menuAccentColor
                teleportBtn.Text = "Teleport"
                teleportBtn.TextColor3 = settings.menuTextColor
                Instance.new("UICorner", teleportBtn).CornerRadius = UDim.new(0, settings.menuButtonCornerRadius)

                teleportBtn.MouseButton1Click:Connect(function()
                    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        player.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame
                    end
                end)
            end
        end
        
    elseif settings.currentTab == "Keybinds" then
        createToggle("Enable Keybinds", "keybindsEnabled", contentArea)
        createKeybind("Toggle Menu", "toggleMenu", contentArea)
        createKeybind("Toggle Fly", "toggleFly", contentArea)
        createKeybind("Toggle NoClip", "toggleNoClip", contentArea)
        createKeybind("Toggle Infinite Jump", "toggleInfiniteJump", contentArea)
        createKeybind("Toggle Anti-AFK", "toggleAntiAfk", contentArea)
        
    elseif settings.currentTab == "Misc" then
        local save = Instance.new("TextButton", contentArea)
        save.Size = UDim2.new(1, -15, 0, 40)
        save.BackgroundColor3 = settings.menuAccentColor
        save.Text = "Save Config"
        save.TextColor3 = Color3.new(1,1,1)
        save.Font = Enum.Font.GothamBold
        Instance.new("UICorner", save)
        save.MouseButton1Click:Connect(function() 
            if writefile then 
                pcall(function() writefile(settings.configName, httpService:JSONEncode(settings)) end) 
            end 
        end)
        
        local unload = Instance.new("TextButton", contentArea)
        unload.Size = UDim2.new(1, -15, 0, 40)
        unload.BackgroundColor3 = Color3.fromRGB(100, 30, 30)
        unload.Text = "Unload Script"
        unload.TextColor3 = Color3.new(1,1,1)
        unload.Font = Enum.Font.GothamBold
        Instance.new("UICorner", unload)
        unload.MouseButton1Click:Connect(function() 
            settings.active = false
            screenGui:Destroy() 
            watermarkGui:Destroy()
            updateLighting() -- Reset lighting
            for _, obj in pairs(espObjects) do 
                pcall(function() obj.Highlight:Destroy() obj.Billboard:Destroy() end) 
            end
        end)
    end
end

local function createTab(name)
    local btn = Instance.new("TextButton", tabContainer)
    btn.Size = UDim2.new(0.85, 0, 0, 40)
    btn.BackgroundColor3 = settings.currentTab == name and settings.menuAccentColor or settings.menuButtonColor
    btn.Text = name
    btn.TextColor3 = settings.currentTab == name and settings.menuTextColor or Color3.fromRGB(150, 150, 150)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 14
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, settings.menuButtonCornerRadius)
    
    btn.MouseButton1Click:Connect(function()
        settings.currentTab = name
        for _, v in pairs(tabContainer:GetChildren()) do
            if v:IsA("TextButton") then
                local isCurrent = (v.Text == settings.currentTab)
                tweenService:Create(v, TweenInfo.new(0.3), {BackgroundColor3 = isCurrent and settings.menuAccentColor or settings.menuButtonColor, TextColor3 = isCurrent and settings.menuTextColor or Color3.fromRGB(150, 150, 150)}):Play()
            end
        end
        updateMenu()
    end)
end

createTab("Visuals")
createTab("Movement")
createTab("Player")
createTab("Keybinds")
createTab("Misc")
updateMenu()

-- ==========================================
-- 3. ЛОГИКА (ОПТИМИЗИРОВАННАЯ)
-- ==========================================
local function checkVisibility(targetChar)
    local myChar = player.Character
    if not myChar or not myChar:FindFirstChild("Head") or not targetChar:FindFirstChild("HumanoidRootPart") then return false end
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {myChar, targetChar}
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    local result = workspace:Raycast(myChar.Head.Position, targetChar.HumanoidRootPart.Position - myChar.Head.Position, rayParams)
    return result == nil
end

local function createEsp(targetPlayer)
    if targetPlayer == player then return end
    local function setup(character)
        if not character then return end
        task.defer(function()
            local head = character:WaitForChild("Head", 10)
            local hum = character:WaitForChild("Humanoid", 10)
            if not head or not hum then return end
            if espObjects[targetPlayer] then pcall(function() espObjects[targetPlayer].Highlight:Destroy() espObjects[targetPlayer].Billboard:Destroy() end) end
            
            local highlight = Instance.new("Highlight", character)
            highlight.FillTransparency = 0.5
            highlight.Enabled = false
            
            local billboard = Instance.new("BillboardGui", head)
            billboard.Size = UDim2.new(0, 200, 0, 60)
            billboard.AlwaysOnTop = true
            billboard.StudsOffset = Vector3.new(0, 3, 0)
            billboard.Enabled = false
            
            local healthBg = Instance.new("Frame", billboard)
            healthBg.Size = UDim2.new(0, 60, 0, 6)
            healthBg.Position = UDim2.new(0.5, -30, 0, 0)
            healthBg.BackgroundColor3 = Color3.new(0, 0, 0)
            
            local healthMain = Instance.new("Frame", healthBg)
            healthMain.Size = UDim2.new(1, 0, 1, 0)
            healthMain.BackgroundColor3 = Color3.new(0, 1, 0)
            
            local label = Instance.new("TextLabel", billboard)
            label.Size = UDim2.new(1, 0, 0, 20)
            label.Position = UDim2.new(0, 0, 0, 10)
            label.BackgroundTransparency = 1
            label.TextColor3 = Color3.new(1, 1, 1)
            label.TextSize = 14
            label.Font = Enum.Font.SourceSansBold
            label.TextStrokeTransparency = 0.5
            label.Text = ""
            
            espObjects[targetPlayer] = { Highlight = highlight, Billboard = billboard, HealthBar = healthMain, Label = label, Char = character }
        end)
    end
    targetPlayer.CharacterAdded:Connect(setup)
    if targetPlayer.Character then setup(targetPlayer.Character) end
end

task_spawn(function() 
    for _, p in pairs(players:GetPlayers()) do 
        createEsp(p) 
        task_wait(0.05) 
    end 
end)
players.PlayerAdded:Connect(createEsp)

-- Главный цикл ESP и FOV
runService.RenderStepped:Connect(function()
    if not settings.active then return end
    
    -- FOV Update
    if workspace.CurrentCamera then
        workspace.CurrentCamera.FieldOfView = settings.fovValue
    end
    
    -- ESP Update
    if settings.espBoxes or settings.espNames or settings.espHealth then
        for targetPlayer, obj in pairs(espObjects) do
            if obj.Char and obj.Char.Parent then
                local hum = obj.Char:FindFirstChild("Humanoid")
                local root = obj.Char:FindFirstChild("HumanoidRootPart")
                if hum and root and hum.Health > 0 then
                    local isAlly = (targetPlayer.Team == player.Team)
                    local finalColor = settings.colorHidden
                    if settings.teamCheck and isAlly then 
                        finalColor = settings.colorAlly
                    else 
                        finalColor = checkVisibility(obj.Char) and settings.colorVisible or settings.colorHidden 
                    end
                    
                    obj.Highlight.Enabled = settings.espBoxes
                    obj.Highlight.FillColor = finalColor
                    obj.Billboard.Enabled = (settings.espNames or settings.espHealth)
                    obj.HealthBar.Parent.Visible = settings.espHealth
                    obj.HealthBar.Size = UDim2.new(hum.Health / hum.MaxHealth, 0, 1, 0)
                    
                    if settings.espNames then
                        local dist = math_floor((root.Position - player.Character.HumanoidRootPart.Position).Magnitude)
                        obj.Label.Text = targetPlayer.Name .. " [" .. dist .. "s]"
                        obj.Label.TextColor3 = finalColor
                    else 
                        obj.Label.Text = "" 
                    end
                else 
                    obj.Highlight.Enabled = false 
                    obj.Billboard.Enabled = false 
                end
            end
        end
    end
end)

-- Цикл Movement (Fly, WalkSpeed, JumpPower)
local bodyVelocity, bodyGyro
runService.RenderStepped:Connect(function()
    if not settings.active then return end
    
    if settings.flyEnabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = player.Character.HumanoidRootPart
        if not bodyVelocity then
            bodyVelocity = Instance.new("BodyVelocity", hrp)
            bodyVelocity.MaxForce = Vector3.new(1e6, 1e6, 1e6)
            bodyGyro = Instance.new("BodyGyro", hrp)
            bodyGyro.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
        end
        local moveDir = Vector3.new(0,0,0)
        local cam = workspace.CurrentCamera.CFrame
        if userInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.LookVector end
        if userInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.LookVector end
        if userInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.RightVector end
        if userInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.RightVector end
        if userInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0,1,0) end
        if userInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0,1,0) end
        bodyVelocity.Velocity = moveDir * settings.flySpeed
        bodyGyro.CFrame = cam
    else
        if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
        if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
    end

    if player.Character and player.Character:FindFirstChild("Humanoid") then
        local hum = player.Character.Humanoid
        hum.WalkSpeed = settings.walkSpeed
        hum.JumpPower = settings.jumpPower
    end
end)

-- NoClip Оптимизированный
runService.Stepped:Connect(function()
    if settings.noClipEnabled and player.Character then
        for _, part in pairs(player.Character:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            elseif part:IsA("Model") then
                for _, subpart in pairs(part:GetChildren()) do
                    if subpart:IsA("BasePart") then subpart.CanCollide = false end
                end
            end
        end
    end
end)

-- Infinite Jump
userInputService.JumpRequest:Connect(function()
    if settings.infiniteJumpEnabled and player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Anti-AFK
task_spawn(function()
    while task_wait(5) do
        if not settings.active then break end
        if settings.antiAfkEnabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            local currentPos = hrp.CFrame
            hrp.CFrame = currentPos * CFrame.new(0, 0.01, 0)
            task_wait(0.1)
            hrp.CFrame = currentPos
        end
    end
end)

-- Auto Clicker (Оптимизированный)
task_spawn(function()
    local vim = game:GetService("VirtualInputManager")
    while task_wait(0.1) do
        if not settings.active then break end
        if settings.autoClickerEnabled then
            vim:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            vim:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        end
    end
end)

-- Обработка клавиш
userInputService.InputBegan:Connect(function(input, gp)
    if not settings.keybindsEnabled then return end
    if not gp then
        if settings.keybinds.toggleMenu and input.KeyCode == settings.keybinds.toggleMenu then
            settings.menuVisible = not settings.menuVisible
            mainFrame.Visible = settings.menuVisible
        elseif settings.keybinds.toggleFly and input.KeyCode == settings.keybinds.toggleFly then
            settings.flyEnabled = not settings.flyEnabled
            updateMenu()
        elseif settings.keybinds.toggleNoClip and input.KeyCode == settings.keybinds.toggleNoClip then
            settings.noClipEnabled = not settings.noClipEnabled
            updateMenu()
        elseif settings.keybinds.toggleInfiniteJump and input.KeyCode == settings.keybinds.toggleInfiniteJump then
            settings.infiniteJumpEnabled = not settings.infiniteJumpEnabled
            updateMenu()
        elseif settings.keybinds.toggleAntiAfk and input.KeyCode == settings.keybinds.toggleAntiAfk then
            settings.antiAfkEnabled = not settings.antiAfkEnabled
            updateMenu()
        end
    end
end)
