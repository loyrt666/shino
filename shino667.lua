-- Ссылки на сервисы
local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local userInputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local players = game:GetService("Players")

-- Состояние функций и цветов
local settings = {
    active = true, -- Флаг работы скрипта
    menuVisible = true,
    espBoxes = false,
    espNames = false,
    teamCheck = true,
    
    -- Настраиваемые цвета
    colorVisible = Color3.fromRGB(255, 255, 255), -- Белый
    colorHidden = Color3.fromRGB(170, 0, 255),    -- Фиолетовый
    colorAlly = Color3.fromRGB(0, 255, 120)       -- Зеленый
}

local espObjects = {}
local connections = {} -- Для хранения событий

-- ==========================================
-- 1. ИНТЕРФЕЙС (UI)
-- ==========================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RobloxMaster_SHINO"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 320, 0, 460) -- Увеличил высоту для новой кнопки
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -230)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "SHINO MENU [Insert]"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 16
title.Font = Enum.Font.SourceSansBold
title.Parent = mainFrame

-- Функция создания переключателя
local function createToggle(name, settingKey, position)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 280, 0, 35)
    btn.Position = position
    btn.BackgroundColor3 = settings[settingKey] and Color3.fromRGB(0, 140, 70) or Color3.fromRGB(50, 50, 50)
    btn.Text = name .. ": " .. (settings[settingKey] and "ON" or "OFF")
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Parent = mainFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

    btn.MouseButton1Click:Connect(function()
        settings[settingKey] = not settings[settingKey]
        btn.Text = name .. ": " .. (settings[settingKey] and "ON" or "OFF")
        btn.BackgroundColor3 = settings[settingKey] and Color3.fromRGB(0, 140, 70) or Color3.fromRGB(50, 50, 50)
    end)
end

-- Функция создания выбора цвета
local function createColorPicker(label, settingKey, position, colors)
    local labelObj = Instance.new("TextLabel")
    labelObj.Size = UDim2.new(0, 280, 0, 20)
    labelObj.Position = position
    labelObj.BackgroundTransparency = 1
    labelObj.Text = label
    labelObj.TextColor3 = Color3.fromRGB(200, 200, 200)
    labelObj.TextSize = 14
    labelObj.Parent = mainFrame

    for i, color in ipairs(colors) do
        local colorBtn = Instance.new("TextButton")
        colorBtn.Size = UDim2.new(0, 40, 0, 25)
        colorBtn.Position = position + UDim2.new(0, (i-1)*45, 0, 25)
        colorBtn.BackgroundColor3 = color
        colorBtn.Text = ""
        colorBtn.Parent = mainFrame
        Instance.new("UICorner", colorBtn).CornerRadius = UDim.new(0, 4)

        colorBtn.MouseButton1Click:Connect(function()
            settings[settingKey] = color
        end)
    end
end

-- Кнопка ВЫГРУЗКИ (Unload)
local unloadBtn = Instance.new("TextButton")
unloadBtn.Size = UDim2.new(0, 280, 0, 40)
unloadBtn.Position = UDim2.new(0, 20, 0, 400)
unloadBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
unloadBtn.Text = "UNLOAD SCRIPT"
unloadBtn.TextColor3 = Color3.new(1, 1, 1)
unloadBtn.Font = Enum.Font.SourceSansBold
unloadBtn.Parent = mainFrame
Instance.new("UICorner", unloadBtn).CornerRadius = UDim.new(0, 5)

-- Настройки
createToggle("ESP Boxes", "espBoxes", UDim2.new(0, 20, 0, 50))
createToggle("ESP Names", "espNames", UDim2.new(0, 20, 0, 90))
createToggle("Team Check", "teamCheck", UDim2.new(0, 20, 0, 130))

local presetColors = {
    Color3.fromRGB(255, 255, 255), Color3.fromRGB(255, 0, 0), Color3.fromRGB(0, 255, 0),
    Color3.fromRGB(0, 255, 255), Color3.fromRGB(255, 255, 0), Color3.fromRGB(170, 0, 255)
}
createColorPicker("Visible Enemy Color:", "colorVisible", UDim2.new(0, 20, 0, 180), presetColors)
createColorPicker("Hidden Enemy Color:", "colorHidden", UDim2.new(0, 20, 0, 240), presetColors)
createColorPicker("Ally Color:", "colorAlly", UDim2.new(0, 20, 0, 300), presetColors)

-- ==========================================
-- 2. ЛОГИКА ESP
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

local function updateEsp()
    if not settings.active then return end
    local myChar = player.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end

    for targetPlayer, objects in pairs(espObjects) do
        local char = targetPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChild("Humanoid")

        if char and root and hum and hum.Health > 0 then
            local isAlly = (targetPlayer.Team == player.Team)
            local finalColor = settings.colorHidden
            
            if settings.teamCheck and isAlly then
                finalColor = settings.colorAlly
            else
                local visible = checkVisibility(char)
                finalColor = visible and settings.colorVisible or settings.colorHidden
            end

            objects.Highlight.Enabled = settings.espBoxes
            objects.Highlight.FillColor = finalColor
            objects.Highlight.OutlineColor = finalColor

            objects.Billboard.Enabled = settings.espNames
            objects.NameLabel.TextColor3 = finalColor
            local dist = math.floor((root.Position - myChar.HumanoidRootPart.Position).Magnitude)
            objects.NameLabel.Text = targetPlayer.Name .. " [" .. dist .. "s]"
        else
            objects.Highlight.Enabled = false
            objects.Billboard.Enabled = false
        end
    end
end

local function createEsp(targetPlayer)
    if targetPlayer == player then return end
    local function setup(character)
        if not settings.active then return end
        if espObjects[targetPlayer] then
            pcall(function() espObjects[targetPlayer].Highlight:Destroy() espObjects[targetPlayer].Billboard:Destroy() end)
        end
        local highlight = Instance.new("Highlight", character)
        highlight.FillTransparency = 0.6
        highlight.Enabled = false
        local billboard = Instance.new("BillboardGui", character:WaitForChild("Head", 5) or character:WaitForChild("HumanoidRootPart"))
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.AlwaysOnTop = true
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.Enabled = false
        local label = Instance.new("TextLabel", billboard)
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.TextSize = 14
        label.Font = Enum.Font.SourceSansBold
        label.TextStrokeTransparency = 0.5
        espObjects[targetPlayer] = { Highlight = highlight, Billboard = billboard, NameLabel = label }
    end
    table.insert(connections, targetPlayer.CharacterAdded:Connect(setup))
    if targetPlayer.Character then setup(targetPlayer.Character) end
end

-- Инициализация
table.insert(connections, players.PlayerAdded:Connect(createEsp))
for _, p in pairs(players:GetPlayers()) do createEsp(p) end
local mainLoop = runService.RenderStepped:Connect(updateEsp)
table.insert(connections, mainLoop)

-- Управление клавишей Insert
table.insert(connections, userInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.Insert then
        settings.menuVisible = not settings.menuVisible
        mainFrame.Visible = settings.menuVisible
    end
end))

-- ЛОГИКА ВЫГРУЗКИ
unloadBtn.MouseButton1Click:Connect(function()
    settings.active = false
    -- Отключаем все события
    for _, conn in pairs(connections) do
        if conn then conn:Disconnect() end
    end
    -- Удаляем интерфейс
    screenGui:Destroy()
    -- Удаляем все ESP объекты
    for targetPlayer, objects in pairs(espObjects) do
        pcall(function()
            objects.Highlight:Destroy()
            objects.Billboard:Destroy()
        end)
    end
    espObjects = {}
    print("Script Unloaded Successfully")
end)
