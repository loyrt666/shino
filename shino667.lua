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
    colorVisible = Color3.fromRGB(255, 255, 255),
    colorHidden = Color3.fromRGB(170, 0, 255),
    colorAlly = Color3.fromRGB(0, 255, 120),
    
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
-- 1. ИНТЕРФЕЙС (UI с вкладками)
-- ==========================================
local screenGui = Instance.new("ScreenGui", playerGui)
screenGui.Name = "ShinoPremiumMenu"
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 400, 0, 350)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -175)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.Active = true
mainFrame.Draggable = true
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)

-- Боковая панель вкладок
local tabHolder = Instance.new("Frame", mainFrame)
tabHolder.Size = UDim2.new(0, 100, 1, 0)
tabHolder.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Instance.new("UICorner", tabHolder).CornerRadius = UDim.new(0, 10)

-- Контейнер для контента
local contentFrame = Instance.new("Frame", mainFrame)
contentFrame.Size = UDim2.new(1, -110, 1, -10)
contentFrame.Position = UDim2.new(0, 105, 0, 5)
contentFrame.BackgroundTransparency = 1

local function clearContent()
    for _, child in pairs(contentFrame:GetChildren()) do child:Destroy() end
end

-- Вспомогательные функции UI
local function createToggle(name, settingKey, parent)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.BackgroundColor3 = settings[settingKey] and Color3.fromRGB(0, 140, 70) or Color3.fromRGB(50, 50, 50)
    btn.Text = name .. ": " .. (settings[settingKey] and "ON" or "OFF")
    btn.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    btn.MouseButton1Click:Connect(function()
        settings[settingKey] = not settings[settingKey]
        btn.Text = name .. ": " .. (settings[settingKey] and "ON" or "OFF")
        btn.BackgroundColor3 = settings[settingKey] and Color3.fromRGB(0, 140, 70) or Color3.fromRGB(50, 50, 50)
    end)
    return btn
end

-- Отрисовка вкладок
local function showTab(tabName)
    settings.currentTab = tabName
    clearContent()
    local layout = Instance.new("UIListLayout", contentFrame)
    layout.Padding = UDim.new(0, 5)

    if tabName == "Visuals" then
        createToggle("ESP Boxes", "espBoxes", contentFrame)
        createToggle("ESP Names", "espNames", contentFrame)
        createToggle("Health Bar", "espHealth", contentFrame)
        createToggle("Team Check", "teamCheck", contentFrame)
    elseif tabName == "Movement" then
        createToggle("NoClip", "noClipEnabled", contentFrame)
        createToggle("Fly", "flyEnabled", contentFrame)
    elseif tabName == "Config" then
        local saveBtn = Instance.new("TextButton", contentFrame)
        saveBtn.Size = UDim2.new(1, 0, 0, 40)
        saveBtn.Text = "SAVE CONFIG"
        saveBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
        saveBtn.TextColor3 = Color3.new(1, 1, 1)
        saveBtn.MouseButton1Click:Connect(function()
            local data = httpService:JSONEncode(settings )
            writefile(settings.configName, data)
            saveBtn.Text = "SAVED!"
            wait(1) saveBtn.Text = "SAVE CONFIG"
        end)

        local loadBtn = Instance.new("TextButton", contentFrame)
        loadBtn.Size = UDim2.new(1, 0, 0, 40)
        loadBtn.Text = "LOAD CONFIG"
        loadBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 200)
        loadBtn.TextColor3 = Color3.new(1, 1, 1)
        loadBtn.MouseButton1Click:Connect(function()
            if isfile(settings.configName) then
                local data = httpService:JSONDecode(readfile(settings.configName ))
                for k, v in pairs(data) do settings[k] = v end
                showTab("Config")
            end
        end)
        
        local unloadBtn = Instance.new("TextButton", contentFrame)
        unloadBtn.Size = UDim2.new(1, 0, 0, 40)
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
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    btn.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", btn)
    btn.MouseButton1Click:Connect(function() showTab(name) end)
end

showTab("Visuals")

-- ==========================================
-- 2. ЛОГИКА (Movement & ESP)
-- ==========================================

-- NoClip Logic
runService.Stepped:Connect(function()
    if settings.noClipEnabled and player.Character then
        for _, part in pairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

-- Fly Logic (Упрощенная)
local bodyVelocity, bodyGyro
runService.RenderStepped:Connect(function()
    if settings.flyEnabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = player.Character.HumanoidRootPart
        if not bodyVelocity then
            bodyVelocity = Instance.new("BodyVelocity", hrp)
            bodyVelocity.MaxForce = Vector3.new(1e6, 1e6, 1e6)
            bodyGyro = Instance.new("BodyGyro", hrp)
            bodyGyro.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
            bodyGyro.CFrame = hrp.CFrame
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

-- ESP Health Bar Logic
local function createEsp(targetPlayer)
    if targetPlayer == player then return end
    local function setup(character)
        local head = character:WaitForChild("Head", 5)
        if not head then return end
        
        local billboard = Instance.new("BillboardGui", head)
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.AlwaysOnTop = true
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        
        -- Health Bar Container
        local healthBg = Instance.new("Frame", billboard)
        healthBg.Size = UDim2.new(0, 50, 0, 5)
        healthBg.Position = UDim2.new(0.5, -25, 0, -10)
        healthBg.BackgroundColor3 = Color3.new(0, 0, 0)
        
        local healthMain = Instance.new("Frame", healthBg)
        healthMain.Size = UDim2.new(1, 0, 1, 0)
        healthMain.BackgroundColor3 = Color3.new(0, 1, 0)
        
        local label = Instance.new("TextLabel", billboard)
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.new(1, 1, 1)
        label.TextStrokeTransparency = 0.5

        espObjects[targetPlayer] = { Billboard = billboard, HealthBar = healthMain, Label = label, Char = character }
    end
    targetPlayer.CharacterAdded:Connect(setup)
    if targetPlayer.Character then setup(targetPlayer.Character) end
end

players.PlayerAdded:Connect(createEsp)
for _, p in pairs(players:GetPlayers()) do createEsp(p) end

runService.RenderStepped:Connect(function()
    for targetPlayer, obj in pairs(espObjects) do
        local hum = obj.Char:FindFirstChild("Humanoid")
        if hum and hum.Health > 0 then
            obj.Billboard.Enabled = settings.espNames or settings.espHealth
            obj.HealthBar.Parent.Visible = settings.espHealth
            obj.HealthBar.Size = UDim2.new(hum.Health / hum.MaxHealth, 0, 1, 0)
            obj.Label.Text = settings.espNames and targetPlayer.Name or ""
        else
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
