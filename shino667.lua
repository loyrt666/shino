-- Ссылки на сервисы
local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local userInputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local players = game:GetService("Players")
local httpService = game:GetService("HttpService" )

-- Состояние функций
local settings = {
    active = true,
    menuVisible = true,
    currentTab = "Visuals",
    
    -- Visuals
    espBoxes = false,
    espNames = false,
    espHealth = false,
    teamCheck = true,
    
    -- Настраиваемые цвета
    colorVisible = Color3.fromRGB(255, 255, 255), -- Белый
    colorHidden = Color3.fromRGB(170, 0, 255),    -- Фиолетовый
    colorAlly = Color3.fromRGB(0, 255, 120),       -- Зеленый
    
    -- Movement
    flyEnabled = false,
    flySpeed = 50,
    noClipEnabled = false,
    
    -- Config
    configName = "ShinoConfig.json"
}

local espObjects = {}
local connections = {}

-- ==========================================
-- 1. ИНТЕРФЕЙС (UI с вкладками и цветами)
-- ==========================================
local screenGui = Instance.new("ScreenGui", playerGui)
screenGui.Name = "ShinoPremiumMenu"
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 420, 0, 400)
mainFrame.Position = UDim2.new(0.5, -210, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.Active = true
mainFrame.Draggable = true
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)

-- Боковая панель вкладок
local tabHolder = Instance.new("Frame", mainFrame)
tabHolder.Size = UDim2.new(0, 100, 1, 0)
tabHolder.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Instance.new("UICorner", tabHolder).CornerRadius = UDim.new(0, 10)

-- Контейнер для контента (со скроллом, если функций много)
local contentFrame = Instance.new("ScrollingFrame", mainFrame)
contentFrame.Size = UDim2.new(1, -115, 1, -20)
contentFrame.Position = UDim2.new(0, 110, 0, 10)
contentFrame.BackgroundTransparency = 1
contentFrame.ScrollBarThickness = 2
contentFrame.CanvasSize = UDim2.new(0, 0, 1.2, 0)

local function clearContent()
    for _, child in pairs(contentFrame:GetChildren()) do 
        if not child:IsA("UIListLayout") then child:Destroy() end 
    end
end

local layout = Instance.new("UIListLayout", contentFrame)
layout.Padding = UDim.new(0, 8)

-- Вспомогательные функции UI
local function createToggle(name, settingKey, parent)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, -10, 0, 35)
    btn.BackgroundColor3 = settings[settingKey] and Color3.fromRGB(0, 140, 70) or Color3.fromRGB(50, 50, 50)
    btn.Text = name .. ": " .. (settings[settingKey] and "ON" or "OFF")
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSansBold
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    btn.MouseButton1Click:Connect(function()
        settings[settingKey] = not settings[settingKey]
        btn.Text = name .. ": " .. (settings[settingKey] and "ON" or "OFF")
        btn.BackgroundColor3 = settings[settingKey] and Color3.fromRGB(0, 140, 70) or Color3.fromRGB(50, 50, 50)
    end)
    return btn
end

local function createColorPicker(label, settingKey, parent)
    local container = Instance.new("Frame", parent)
    container.Size = UDim2.new(1, -10, 0, 55)
    container.BackgroundTransparency = 1
    
    local txt = Instance.new("TextLabel", container)
    txt.Size = UDim2.new(1, 0, 0, 20)
    txt.Text = label
    txt.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    txt.BackgroundTransparency = 1
    txt.TextXAlignment = Enum.TextXAlignment.Left
    
    local colors = {
        Color3.fromRGB(255, 255, 255), Color3.fromRGB(255, 0, 0), Color3.fromRGB(0, 255, 0),
        Color3.fromRGB(0, 255, 255), Color3.fromRGB(255, 255, 0), Color3.fromRGB(170, 0, 255)
    }
    
    for i, color in ipairs(colors) do
        local cBtn = Instance.new("TextButton", container)
        cBtn.Size = UDim2.new(0, 35, 0, 25)
        cBtn.Position = UDim2.new(0, (i-1)*40, 0, 22)
        cBtn.BackgroundColor3 = color
        cBtn.Text = ""
        Instance.new("UICorner", cBtn).CornerRadius = UDim.new(0, 4)
        cBtn.MouseButton1Click:Connect(function() settings[settingKey] = color end)
    end
end

-- Отрисовка вкладок
local function showTab(tabName)
    settings.currentTab = tabName
    clearContent()

    if tabName == "Visuals" then
        createToggle("ESP Boxes", "espBoxes", contentFrame)
        createToggle("ESP Names", "espNames", contentFrame)
        createToggle("Health Bar", "espHealth", contentFrame)
        createToggle("Team Check", "teamCheck", contentFrame)
        
        Instance.new("Frame", contentFrame).Size = UDim2.new(1,0,0,5) -- Разделитель
        
        createColorPicker("Visible Enemy Color:", "colorVisible", contentFrame)
        createColorPicker("Hidden Enemy Color:", "colorHidden", contentFrame)
        createColorPicker("Ally Color:", "colorAlly", contentFrame)
        
    elseif tabName == "Movement" then
        createToggle("NoClip", "noClipEnabled", contentFrame)
        createToggle("Fly", "flyEnabled", contentFrame)
        
        local speedTxt = Instance.new("TextLabel", contentFrame)
        speedTxt.Size = UDim2.new(1, -10, 0, 30)
        speedTxt.Text = "Fly Speed: " .. settings.flySpeed
        speedTxt.TextColor3 = Color3.new(1,1,1)
        speedTxt.BackgroundTransparency = 1
        
    elseif tabName == "Config" then
        local saveBtn = Instance.new("TextButton", contentFrame)
        saveBtn.Size = UDim2.new(1, -10, 0, 40)
        saveBtn.Text = "SAVE CONFIG"
        saveBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
        saveBtn.TextColor3 = Color3.new(1, 1, 1)
        saveBtn.MouseButton1Click:Connect(function()
            if writefile then
                local data = httpService:JSONEncode(settings )
                writefile(settings.configName, data)
                saveBtn.Text = "SAVED!"
                wait(1) saveBtn.Text = "SAVE CONFIG"
            end
        end)

        local loadBtn = Instance.new("TextButton", contentFrame)
        loadBtn.Size = UDim2.new(1, -10, 0, 40)
        loadBtn.Text = "LOAD CONFIG"
        loadBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 200)
        loadBtn.TextColor3 = Color3.new(1, 1, 1)
        loadBtn.MouseButton1Click:Connect(function()
            if isfile and isfile(settings.configName) then
                local data = httpService:JSONDecode(readfile(settings.configName ))
                for k, v in pairs(data) do settings[k] = v end
                showTab("Config")
            end
        end)
        
        local unloadBtn = Instance.new("TextButton", contentFrame)
        unloadBtn.Size = UDim2.new(1, -10, 0, 40)
        unloadBtn.Text = "UNLOAD SCRIPT"
        unloadBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
        unloadBtn.TextColor3 = Color3.new(1, 1, 1)
        unloadBtn.MouseButton1Click:Connect(function() screenGui:Destroy() settings.active = false end)
    end
end

-- Создание кнопок вкладок
local tabs = {"Visuals", "Movement", "Config"}
for i, name in ipairs(tabs) do
    local btn = Instance.new("TextButton", tabHolder)
    btn.Size = UDim2.new(1, -10, 0, 40)
    btn.Position = UDim2.new(0, 5, 0, (i-1)*45 + 10)
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSansBold
    Instance.new("UICorner", btn)
    btn.MouseButton1Click:Connect(function() showTab(name) end)
end

showTab("Visuals")

-- ==========================================
-- 2. ЛОГИКА (Movement & ESP)
-- ==========================================

-- Проверка видимости
local function checkVisibility(targetChar)
    local myChar = player.Character
    if not myChar or not myChar:FindFirstChild("Head") or not targetChar:FindFirstChild("HumanoidRootPart") then return false end
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {myChar, targetChar}
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    local result = workspace:Raycast(myChar.Head.Position, targetChar.HumanoidRootPart.Position - myChar.Head.Position, rayParams)
    return result == nil
end

-- NoClip Logic
runService.Stepped:Connect(function()
    if settings.noClipEnabled and player.Character then
        for _, part in pairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

-- Fly Logic
local bodyVelocity, bodyGyro
runService.RenderStepped:Connect(function()
    if settings.flyEnabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = player.Character.HumanoidRootPart
        if not bodyVelocity then
            bodyVelocity = Instance.new("BodyVelocity", hrp)
            bodyVelocity.MaxForce = Vector3.new(1e6, 1e6, 1e6)
            bodyGyro = Instance.new("BodyGyro", hrp)
            bodyGyro.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
        end
        local moveDir = Vector3.new(0,0,0)
        if userInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + workspace.CurrentCamera.CFrame.LookVector end
        if userInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - workspace.CurrentCamera.CFrame.LookVector end
        if userInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - workspace.CurrentCamera.CFrame.LookVector.Unit:Cross(Vector3.new(0,1,0)) end
        if userInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + workspace.CurrentCamera.CFrame.LookVector.Unit:Cross(Vector3.new(0,1,0)) end
        if userInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0,1,0) end
        if userInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0,1,0) end
        bodyVelocity.Velocity = moveDir * settings.flySpeed
        bodyGyro.CFrame = workspace.CurrentCamera.CFrame
    else
        if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
        if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
    end
end)

-- ESP & Health Bar
local function createEsp(targetPlayer)
    if targetPlayer == player then return end
    local function setup(character)
        if not settings.active then return end
        local head = character:WaitForChild("Head", 5)
        local highlight = Instance.new("Highlight", character)
        highlight.FillTransparency = 0.6
        
        local billboard = Instance.new("BillboardGui", head or character:WaitForChild("HumanoidRootPart"))
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.AlwaysOnTop = true
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        
        local healthBg = Instance.new("Frame", billboard)
        healthBg.Size = UDim2.new(0, 50, 0, 4)
        healthBg.Position = UDim2.new(0.5, -25, 0, -5)
        healthBg.BackgroundColor3 = Color3.new(0, 0, 0)
        local healthMain = Instance.new("Frame", healthBg)
        healthMain.Size = UDim2.new(1, 0, 1, 0)
        healthMain.BackgroundColor3 = Color3.new(0, 1, 0)
        healthMain.BorderSizePixel = 0
        
        local label = Instance.new("TextLabel", billboard)
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.new(1, 1, 1)
        label.TextStrokeTransparency = 0.5
        label.Font = Enum.Font.SourceSansBold

        espObjects[targetPlayer] = { Highlight = highlight, Billboard = billboard, HealthBar = healthMain, Label = label, Char = character }
    end
    targetPlayer.CharacterAdded:Connect(setup)
    if targetPlayer.Character then setup(targetPlayer.Character) end
end

players.PlayerAdded:Connect(createEsp)
for _, p in pairs(players:GetPlayers()) do createEsp(p) end

runService.RenderStepped:Connect(function()
    if not settings.active then return end
    for targetPlayer, obj in pairs(espObjects) do
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
            obj.Billboard.Enabled = settings.espNames or settings.espHealth
            obj.HealthBar.Parent.Visible = settings.espHealth
            obj.HealthBar.Size = UDim2.new(hum.Health / hum.MaxHealth, 0, 1, 0)
            obj.Label.TextColor3 = finalColor
            local dist = math.floor((root.Position - player.Character.HumanoidRootPart.Position).Magnitude)
            obj.Label.Text = settings.espNames and targetPlayer.Name .. " [" .. dist .. "s]" or ""
        else
            obj.Highlight.Enabled = false
            obj.Billboard.Enabled = false
        end
    end
end)

-- Insert to Hide
userInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.Insert then
        settings.menuVisible = not settings.menuVisible
        mainFrame.Visible = settings.menuVisible
    end
end)
