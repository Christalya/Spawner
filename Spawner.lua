Action: 'file_editor create /app/grow_garden_mobile_script.lua --file-text -- Grow a Garden - Mobile Pet Spawner Script (Android)\n-- Optimized for mobile executors like Fluxus, KRNL Mobile, etc.\n-- Features: Touch-friendly GUI, spawn pets, modify weight\n\nlocal Players = game:GetService("Players")\nlocal ReplicatedStorage = game:GetService("ReplicatedStorage")\nlocal RunService = game:GetService("RunService")\nlocal TweenService = game:GetService("TweenService")\nlocal UserInputService = game:GetService("UserInputService")\n\nlocal player = Players.LocalPlayer\nlocal playerGui = player:WaitForChild("PlayerGui")\n\n-- Mobile Configuration\nlocal CONFIG = {\n    -- Animal/Pet Types\n    ANIMALS = {\n        "Chicken", "Cow", "Pig", "Sheep", "Horse", "Duck", "Goat", \n        "Rabbit", "Dog", "Cat", "Turkey", "Llama", "Goose"\n    },\n    \n    -- Weight settings\n    MIN_WEIGHT = 1,\n    MAX_WEIGHT = 1000,\n    DEFAULT_WEIGHT = 50,\n    \n    -- Mobile optimized settings\n    SPAWN_DISTANCE = 8,\n    MAX_ANIMALS = 30, -- Reduced for mobile performance\n    \n    -- Mobile-friendly colors\n    MAIN_COLOR = Color3.fromRGB(85, 170, 85),\n    ACCENT_COLOR = Color3.fromRGB(107, 142, 35),\n    TEXT_COLOR = Color3.fromRGB(255, 255, 255),\n    ERROR_COLOR = Color3.fromRGB(220, 20, 60),\n    BUTTON_COLOR = Color3.fromRGB(34, 139, 34)\n}\n\n-- Global variables\nlocal spawnedAnimals = {}\nlocal gui = nil\nlocal currentAnimalIndex = 1\n\n-- Utility Functions\nlocal function createMobileNotification(message, color)\n    color = color or CONFIG.MAIN_COLOR\n    \n    local notification = Instance.new("ScreenGui")\n    notification.Name = "MobileNotification"\n    notification.Parent = playerGui\n    \n    local frame = Instance.new("Frame")\n    frame.Size = UDim2.new(0, 280, 0, 45)\n    frame.Position = UDim2.new(0.5, -140, 0, 20)\n    frame.BackgroundColor3 = color\n    frame.BorderSizePixel = 0\n    frame.Parent = notification\n    \n    local corner = Instance.new("UICorner")\n    corner.CornerRadius = UDim.new(0, 12)\n    corner.Parent = frame\n    \n    local label = Instance.new("TextLabel")\n    label.Size = UDim2.new(1, -20, 1, 0)\n    label.Position = UDim2.new(0, 10, 0, 0)\n    label.BackgroundTransparency = 1\n    label.Text = message\n    label.TextColor3 = CONFIG.TEXT_COLOR\n    label.TextScaled = true\n    label.Font = Enum.Font.SourceSansBold\n    label.Parent = frame\n    \n    -- Mobile animation\n    frame:TweenPosition(UDim2.new(0.5, -140, 0, 20), "Out", "Quad", 0.3, true)\n    \n    -- Auto remove\n    game:GetService("Debris"):AddItem(notification, 2.5)\nend\n\n-- Animal Functions (same as PC version but optimized)\nlocal function getPlayerPosition()\n    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then\n        return player.Character.HumanoidRootPart.Position\n    end\n    return Vector3.new(0, 10, 0)\nend\n\nlocal function createAnimal(animalType, position, weight)\n    weight = weight or CONFIG.DEFAULT_WEIGHT\n    local animal = nil\n    \n    -- Try to find existing models\n    local animalModels = ReplicatedStorage:FindFirstChild("Animals") \n                      or ReplicatedStorage:FindFirstChild("Pets")\n                      or ReplicatedStorage:FindFirstChild("Models")\n    \n    if animalModels and animalModels:FindFirstChild(animalType) then\n        animal = animalModels[animalType]:Clone()\n    else\n        -- Create simple mobile-optimized model\n        animal = Instance.new("Model")\n        animal.Name = animalType\n        \n        local body = Instance.new("Part")\n        body.Name = "Body"\n        body.Size = Vector3.new(1.5, 0.8, 2) -- Smaller for mobile\n        body.Material = Enum.Material.Neon\n        body.BrickColor = BrickColor.Random()\n        body.Shape = Enum.PartType.Block\n        body.Parent = animal\n        \n        local humanoid = Instance.new("Humanoid")\n        humanoid.MaxHealth = weight\n        humanoid.Health = weight\n        humanoid.Parent = animal\n        \n        animal.PrimaryPart = body\n    end\n    \n    -- Position the animal\n    if animal.PrimaryPart then\n        animal:SetPrimaryPartCFrame(CFrame.new(position))\n    else\n        animal:MoveTo(position)\n    end\n    \n    -- Apply weight\n    local success = false\n    if animal:FindFirstChild("Weight") then\n        animal.Weight.Value = weight\n        success = true\n    end\n    \n    local stats = animal:FindFirstChild("Stats")\n    if stats and stats:FindFirstChild("Weight") then\n        stats.Weight.Value = weight\n        success = true\n    end\n    \n    local humanoid = animal:FindFirstChildOfClass("Humanoid")\n    if humanoid then\n        humanoid.MaxHealth = weight\n        humanoid.Health = weight\n        success = true\n    end\n    \n    if not success then\n        animal:SetAttribute("Weight", weight)\n    end\n    \n    animal.Parent = workspace\n    table.insert(spawnedAnimals, animal)\n    return animal\nend\n\nlocal function spawnAnimal(animalType, weight)\n    if #spawnedAnimals >= CONFIG.MAX_ANIMALS then\n        createMobileNotification("Max animals reached!", CONFIG.ERROR_COLOR)\n        return\n    end\n    \n    local playerPos = getPlayerPosition()\n    local spawnPos = playerPos + Vector3.new(\n        math.random(-CONFIG.SPAWN_DISTANCE, CONFIG.SPAWN_DISTANCE),\n        2,\n        math.random(-CONFIG.SPAWN_DISTANCE, CONFIG.SPAWN_DISTANCE)\n    )\n    \n    local success, animal = pcall(createAnimal, animalType, spawnPos, weight)\n    \n    if success and animal then\n        createMobileNotification(string.format("Spawned %s (%.0f kg)", animalType, weight))\n    else\n        createMobileNotification("Failed to spawn!", CONFIG.ERROR_COLOR)\n    end\nend\n\nlocal function modifyAllAnimalsWeight(newWeight)\n    local modified = 0\n    for i, animal in ipairs(spawnedAnimals) do\n        if animal and animal.Parent then\n            if animal:FindFirstChild("Weight") then\n                animal.Weight.Value = newWeight\n                modified = modified + 1\n            elseif animal:FindFirstChild("Stats") and animal.Stats:FindFirstChild("Weight") then\n                animal.Stats.Weight.Value = newWeight\n                modified = modified + 1\n            elseif animal:FindFirstChildOfClass("Humanoid") then\n                local humanoid = animal:FindFirstChildOfClass("Humanoid")\n                humanoid.MaxHealth = newWeight\n                humanoid.Health = newWeight\n                modified = modified + 1\n            else\n                animal:SetAttribute("Weight", newWeight)\n                modified = modified + 1\n            end\n        end\n    end\n    return modified\nend\n\nlocal function clearAllAnimals()\n    for i, animal in ipairs(spawnedAnimals) do\n        if animal and animal.Parent then\n            animal:Destroy()\n        end\n    end\n    spawnedAnimals = {}\n    createMobileNotification("All animals cleared!")\nend\n\n-- Mobile GUI Creation\nlocal function createMobileGUI()\n    -- Main GUI optimized for mobile\n    local screenGui = Instance.new("ScreenGui")\n    screenGui.Name = "MobilePetSpawner"\n    screenGui.ResetOnSpawn = false\n    screenGui.Parent = playerGui\n    \n    -- Compact main frame for mobile\n    local mainFrame = Instance.new("Frame")\n    mainFrame.Name = "MainFrame"\n    mainFrame.Size = UDim2.new(0, 320, 0, 400) -- Smaller for mobile\n    mainFrame.Position = UDim2.new(0.5, -160, 0.5, -200)\n    mainFrame.BackgroundColor3 = CONFIG.MAIN_COLOR\n    mainFrame.BorderSizePixel = 0\n    mainFrame.Active = true\n    mainFrame.Draggable = true\n    mainFrame.Parent = screenGui\n    \n    local corner = Instance.new("UICorner")\n    corner.CornerRadius = UDim.new(0, 15)\n    corner.Parent = mainFrame\n    \n    -- Title\n    local title = Instance.new("TextLabel")\n    title.Size = UDim2.new(1, -20, 0, 35)\n    title.Position = UDim2.new(0, 10, 0, 5)\n    title.BackgroundTransparency = 1\n    title.Text = "🐾 Pet Spawner Mobile"\n    title.TextColor3 = CONFIG.TEXT_COLOR\n    title.TextScaled = true\n    title.Font = Enum.Font.SourceSansBold\n    title.Parent = mainFrame\n    \n    -- Animal selector (touch-friendly)\n    local animalFrame = Instance.new("Frame")\n    animalFrame.Size = UDim2.new(1, -20, 0, 50)\n    animalFrame.Position = UDim2.new(0, 10, 0, 50)\n    animalFrame.BackgroundColor3 = CONFIG.ACCENT_COLOR\n    animalFrame.BorderSizePixel = 0\n    animalFrame.Parent = mainFrame\n    \n    local animalCorner = Instance.new("UICorner")\n    animalCorner.CornerRadius = UDim.new(0, 10)\n    animalCorner.Parent = animalFrame\n    \n    local animalLabel = Instance.new("TextLabel")\n    animalLabel.Size = UDim2.new(0.7, 0, 1, 0)\n    animalLabel.Position = UDim2.new(0, 10, 0, 0)\n    animalLabel.BackgroundTransparency = 1\n    animalLabel.Text = CONFIG.ANIMALS[1]\n    animalLabel.TextColor3 = CONFIG.TEXT_COLOR\n    animalLabel.TextScaled = true\n    animalLabel.Font = Enum.Font.SourceSansBold\n    animalLabel.TextXAlignment = Enum.TextXAlignment.Left\n    animalLabel.Parent = animalFrame\n    \n    local nextAnimalBtn = Instance.new("TextButton")\n    nextAnimalBtn.Name = "NextAnimal"\n    nextAnimalBtn.Size = UDim2.new(0.25, -5, 0.8, 0)\n    nextAnimalBtn.Position = UDim2.new(0.75, 0, 0.1, 0)\n    nextAnimalBtn.BackgroundColor3 = CONFIG.BUTTON_COLOR\n    nextAnimalBtn.Text = "Next"\n    nextAnimalBtn.TextColor3 = CONFIG.TEXT_COLOR\n    nextAnimalBtn.TextScaled = true\n    nextAnimalBtn.Font = Enum.Font.SourceSansBold\n    nextAnimalBtn.Parent = animalFrame\n    \n    local nextCorner = Instance.new("UICorner")\n    nextCorner.CornerRadius = UDim.new(0, 8)\n    nextCorner.Parent = nextAnimalBtn\n    \n    -- Weight input (mobile-friendly)\n    local weightFrame = Instance.new("Frame")\n    weightFrame.Size = UDim2.new(1, -20, 0, 45)\n    weightFrame.Position = UDim2.new(0, 10, 0, 110)\n    weightFrame.BackgroundColor3 = CONFIG.ACCENT_COLOR\n    weightFrame.BorderSizePixel = 0\n    weightFrame.Parent = mainFrame\n    \n    local weightCorner = Instance.new("UICorner")\n    weightCorner.CornerRadius = UDim.new(0, 10)\n    weightCorner.Parent = weightFrame\n    \n    local weightInput = Instance.new("TextBox")\n    weightInput.Name = "WeightInput"\n    weightInput.Size = UDim2.new(1, -20, 1, -10)\n    weightInput.Position = UDim2.new(0, 10, 0, 5)\n    weightInput.BackgroundTransparency = 1\n    weightInput.Text = tostring(CONFIG.DEFAULT_WEIGHT)\n    weightInput.TextColor3 = CONFIG.TEXT_COLOR\n    weightInput.TextScaled = true\n    weightInput.Font = Enum.Font.SourceSans\n    weightInput.PlaceholderText = "Weight (1-1000)"\n    weightInput.Parent = weightFrame\n    \n    -- Large spawn button for touch\n    local spawnButton = Instance.new("TextButton")\n    spawnButton.Name = "SpawnButton"\n    spawnButton.Size = UDim2.new(1, -20, 0, 50)\n    spawnButton.Position = UDim2.new(0, 10, 0, 170)\n    spawnButton.BackgroundColor3 = CONFIG.BUTTON_COLOR\n    spawnButton.Text = "🐄 SPAWN ANIMAL"\n    spawnButton.TextColor3 = CONFIG.TEXT_COLOR\n    spawnButton.TextScaled = true\n    spawnButton.Font = Enum.Font.SourceSansBold\n    spawnButton.Parent = mainFrame\n    \n    local spawnCorner = Instance.new("UICorner")\n    spawnCorner.CornerRadius = UDim.new(0, 12)\n    spawnCorner.Parent = spawnButton\n    \n    -- Quick action buttons (2 columns)\n    local randomButton = Instance.new("TextButton")\n    randomButton.Name = "RandomButton"\n    randomButton.Size = UDim2.new(0.48, -5, 0, 45)\n    randomButton.Position = UDim2.new(0, 10, 0, 235)\n    randomButton.BackgroundColor3 = Color3.fromRGB(138, 43, 226)\n    randomButton.Text = "🎲 Random"\n    randomButton.TextColor3 = CONFIG.TEXT_COLOR\n    randomButton.TextScaled = true\n    randomButton.Font = Enum.Font.SourceSansBold\n    randomButton.Parent = mainFrame\n    \n    local randomCorner = Instance.new("UICorner")\n    randomCorner.CornerRadius = UDim.new(0, 10)\n    randomCorner.Parent = randomButton\n    \n    local clearButton = Instance.new("TextButton")\n    clearButton.Name = "ClearButton"\n    clearButton.Size = UDim2.new(0.48, -5, 0, 45)\n    clearButton.Position = UDim2.new(0.52, 5, 0, 235)\n    clearButton.BackgroundColor3 = CONFIG.ERROR_COLOR\n    clearButton.Text = "🗑️ Clear"\n    clearButton.TextColor3 = CONFIG.TEXT_COLOR\n    clearButton.TextScaled = true\n    clearButton.Font = Enum.Font.SourceSansBold\n    clearButton.Parent = mainFrame\n    \n    local clearCorner = Instance.new("UICorner")\n    clearCorner.CornerRadius = UDim.new(0, 10)\n    clearCorner.Parent = clearButton\n    \n    -- Modify weight section\n    local modifyFrame = Instance.new("Frame")\n    modifyFrame.Size = UDim2.new(1, -20, 0, 40)\n    modifyFrame.Position = UDim2.new(0, 10, 0, 295)\n    modifyFrame.BackgroundTransparency = 1\n    modifyFrame.Parent = mainFrame\n    \n    local modifyInput = Instance.new("TextBox")\n    modifyInput.Name = "ModifyInput"\n    modifyInput.Size = UDim2.new(0.6, -5, 1, 0)\n    modifyInput.Position = UDim2.new(0, 0, 0, 0)\n    modifyInput.BackgroundColor3 = CONFIG.ACCENT_COLOR\n    modifyInput.Text = "100"\n    modifyInput.TextColor3 = CONFIG.TEXT_COLOR\n    modifyInput.TextScaled = true\n    modifyInput.Font = Enum.Font.SourceSans\n    modifyInput.PlaceholderText = "New weight"\n    modifyInput.Parent = modifyFrame\n    \n    local modifyInputCorner = Instance.new("UICorner")\n    modifyInputCorner.CornerRadius = UDim.new(0, 8)\n    modifyInputCorner.Parent = modifyInput\n    \n    local modifyButton = Instance.new("TextButton")\n    modifyButton.Name = "ModifyButton"\n    modifyButton.Size = UDim2.new(0.4, -5, 1, 0)\n    modifyButton.Position = UDim2.new(0.6, 5, 0, 0)\n    modifyButton.BackgroundColor3 = Color3.fromRGB(255, 140, 0)\n    modifyButton.Text = "⚡ Modify All"\n    modifyButton.TextColor3 = CONFIG.TEXT_COLOR\n    modifyButton.TextScaled = true\n    modifyButton.Font = Enum.Font.SourceSansBold\n    modifyButton.Parent = modifyFrame\n    \n    local modifyBtnCorner = Instance.new("UICorner")\n    modifyBtnCorner.CornerRadius = UDim.new(0, 8)\n    modifyBtnCorner.Parent = modifyButton\n    \n    -- Stats display\n    local statsLabel = Instance.new("TextLabel")\n    statsLabel.Name = "StatsLabel"\n    statsLabel.Size = UDim2.new(1, -20, 0, 25)\n    statsLabel.Position = UDim2.new(0, 10, 0, 345)\n    statsLabel.BackgroundTransparency = 1\n    statsLabel.Text = "Animals: 0 / " .. CONFIG.MAX_ANIMALS\n    statsLabel.TextColor3 = CONFIG.TEXT_COLOR\n    statsLabel.TextScaled = true\n    statsLabel.Font = Enum.Font.SourceSans\n    statsLabel.Parent = mainFrame\n    \n    -- Close button\n    local closeButton = Instance.new("TextButton")\n    closeButton.Name = "CloseButton"\n    closeButton.Size = UDim2.new(0, 25, 0, 25)\n    closeButton.Position = UDim2.new(1, -35, 0, 10)\n    closeButton.BackgroundColor3 = CONFIG.ERROR_COLOR\n    closeButton.Text = "✕"\n    closeButton.TextColor3 = CONFIG.TEXT_COLOR\n    closeButton.TextScaled = true\n    closeButton.Font = Enum.Font.SourceSansBold\n    closeButton.Parent = mainFrame\n    \n    local closeBtnCorner = Instance.new("UICorner")\n    closeBtnCorner.CornerRadius = UDim.new(0, 12)\n    closeBtnCorner.Parent = closeButton\n    \n    return screenGui, {\n        mainFrame = mainFrame,\n        animalLabel = animalLabel,\n        nextAnimalBtn = nextAnimalBtn,\n        weightInput = weightInput,\n        spawnButton = spawnButton,\n        randomButton = randomButton,\n        clearButton = clearButton,\n        modifyInput = modifyInput,\n        modifyButton = modifyButton,\n        closeButton = closeButton,\n        statsLabel = statsLabel\n    }\nend\n\n-- Mobile Event Handlers\nlocal function setupMobileEvents(elements)\n    -- Next animal button\n    elements.nextAnimalBtn.MouseButton1Click:Connect(function()\n        currentAnimalIndex = currentAnimalIndex + 1\n        if currentAnimalIndex > #CONFIG.ANIMALS then\n            currentAnimalIndex = 1\n        end\n        elements.animalLabel.Text = CONFIG.ANIMALS[currentAnimalIndex]\n    end)\n    \n    -- Spawn button\n    elements.spawnButton.MouseButton1Click:Connect(function()\n        local weight = tonumber(elements.weightInput.Text) or CONFIG.DEFAULT_WEIGHT\n        weight = math.clamp(weight, CONFIG.MIN_WEIGHT, CONFIG.MAX_WEIGHT)\n        spawnAnimal(CONFIG.ANIMALS[currentAnimalIndex], weight)\n    end)\n    \n    -- Random spawn\n    elements.randomButton.MouseButton1Click:Connect(function()\n        local randomAnimal = CONFIG.ANIMALS[math.random(1, #CONFIG.ANIMALS)]\n        local randomWeight = math.random(CONFIG.MIN_WEIGHT, CONFIG.MAX_WEIGHT)\n        spawnAnimal(randomAnimal, randomWeight)\n    end)\n    \n    -- Clear all\n    elements.clearButton.MouseButton1Click:Connect(function()\n        clearAllAnimals()\n    end)\n    \n    -- Modify weight\n    elements.modifyButton.MouseButton1Click:Connect(function()\n        local newWeight = tonumber(elements.modifyInput.Text)\n        if not newWeight then\n            createMobileNotification("Invalid weight!", CONFIG.ERROR_COLOR)\n            return\n        end\n        \n        newWeight = math.clamp(newWeight, CONFIG.MIN_WEIGHT, CONFIG.MAX_WEIGHT)\n        local modified = modifyAllAnimalsWeight(newWeight)\n        \n        if modified > 0 then\n            createMobileNotification(string.format("Modified %d animals", modified))\n        else\n            createMobileNotification("No animals to modify!", CONFIG.ERROR_COLOR)\n        end\n    end)\n    \n    -- Close button\n    elements.closeButton.MouseButton1Click:Connect(function()\n        gui:Destroy()\n    end)\n    \n    -- Update stats\n    RunService.Heartbeat:Connect(function()\n        -- Clean up destroyed animals\n        for i = #spawnedAnimals, 1, -1 do\n            if not spawnedAnimals[i] or not spawnedAnimals[i].Parent then\n                table.remove(spawnedAnimals, i)\n            end\n        end\n        \n        if elements.statsLabel then\n            elements.statsLabel.Text = string.format("Animals: %d / %d", #spawnedAnimals, CONFIG.MAX_ANIMALS)\n        end\n    end)\nend\n\n-- Mobile touch shortcuts\nlocal function setupMobileShortcuts()\n    -- Double tap to spawn random\n    local lastTap = 0\n    UserInputService.TouchTap:Connect(function(touchPositions, gameProcessed)\n        if gameProcessed then return end\n        \n        local currentTime = tick()\n        if currentTime - lastTap < 0.5 then -- Double tap\n            local randomAnimal = CONFIG.ANIMALS[math.random(1, #CONFIG.ANIMALS)]\n            local randomWeight = math.random(CONFIG.MIN_WEIGHT, CONFIG.MAX_WEIGHT)\n            spawnAnimal(randomAnimal, randomWeight)\n            createMobileNotification("Double-tap spawn!")\n        end\n        lastTap = currentTime\n    end)\nend\n\n-- Main mobile execution\nlocal function initMobile()\n    -- Clean up existing\n    local existing = playerGui:FindFirstChild("MobilePetSpawner")\n    if existing then existing:Destroy() end\n    \n    -- Create mobile GUI\n    local screenGui, elements = createMobileGUI()\n    gui = screenGui\n    \n    setupMobileEvents(elements)\n    setupMobileShortcuts()\n    \n    -- Welcome message for mobile\n    createMobileNotification("🐾 Mobile Pet Spawner Ready!")\n    \n    print("=== Mobile Pet Spawner Loaded ===")\n    print("- Touch GUI to control")\n    print("- Double-tap screen for random spawn")\n    print("- Optimized for Android executors")\n    print("================================")\nend\n\n-- Auto-start\ninitMobile()\n\n-- Global functions for mobile\n_G.MobilePetSpawner = {\n    spawn = function(animal, weight)\n        spawnAnimal(animal or CONFIG.ANIMALS[1], weight or CONFIG.DEFAULT_WEIGHT)\n    end,\n    clear = clearAllAnimals,\n    random = function()\n        local animal = CONFI
-- Global variables
local spawnedAnimals = {}
local gui = nil

-- Utility Functions
local function createNotification(message, color)
    color = color or CONFIG.MAIN_COLOR
    
    local notification = Instance.new("ScreenGui")
    notification.Name = "Notification"
    notification.Parent = playerGui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 50)
    frame.Position = UDim2.new(1, -320, 0, 20)
    frame.BackgroundColor3 = color
    frame.BorderSizePixel = 0
    frame.Parent = notification
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = message
    label.TextColor3 = CONFIG.TEXT_COLOR
    label.TextScaled = true
    label.Font = Enum.Font.SourceSansBold
    label.Parent = frame
    
    -- Animate in
    frame:TweenPosition(UDim2.new(1, -320, 0, 20), "Out", "Quad", 0.3, true)
    
    -- Auto remove after 3 seconds
    game:GetService("Debris"):AddItem(notification, 3)
end

-- Animal Management Functions
local function getPlayerPosition()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        return player.Character.HumanoidRootPart.Position
    end
    return Vector3.new(0, 10, 0)
end

local function createAnimal(animalType, position, weight)
    weight = weight or CONFIG.DEFAULT_WEIGHT
    
    -- Try different methods to create animals based on common Roblox patterns
    local animal = nil
    
    -- Method 1: Try to find and clone from ReplicatedStorage
    local animalModels = ReplicatedStorage:FindFirstChild("Animals") 
                      or ReplicatedStorage:FindFirstChild("Pets")
                      or ReplicatedStorage:FindFirstChild("Models")
    
    if animalModels and animalModels:FindFirstChild(animalType) then
        animal = animalModels[animalType]:Clone()
    else
        -- Method 2: Create basic animal model
        animal = Instance.new("Model")
        animal.Name = animalType
        
        -- Create basic parts
        local body = Instance.new("Part")
        body.Name = "Body"
        body.Size = Vector3.new(2, 1, 3)
        body.Material = Enum.Material.Neon
        body.BrickColor = BrickColor.Random()
        body.Shape = Enum.PartType.Block
        body.TopSurface = Enum.SurfaceType.Smooth
        body.BottomSurface = Enum.SurfaceType.Smooth
        body.Parent = animal
        
        -- Add humanoid for weight property
        local humanoid = Instance.new("Humanoid")
        humanoid.MaxHealth = weight
        humanoid.Health = weight
        humanoid.Parent = animal
        
        -- Make it the primary part
        animal.PrimaryPart = body
    end
    
    -- Set position
    if animal.PrimaryPart then
        animal:SetPrimaryPartCFrame(CFrame.new(position))
    else
        animal:MoveTo(position)
    end
    
    -- Apply weight (try different methods)
    local success = false
    
    -- Method 1: Direct weight property
    if animal:FindFirstChild("Weight") then
        animal.Weight.Value = weight
        success = true
    end
    
    -- Method 2: Stats folder
    local stats = animal:FindFirstChild("Stats")
    if stats and stats:FindFirstChild("Weight") then
        stats.Weight.Value = weight
        success = true
    end
    
    -- Method 3: Humanoid health as weight
    local humanoid = animal:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.MaxHealth = weight
        humanoid.Health = weight
        success = true
    end
    
    -- Method 4: Create custom weight attribute
    if not success then
        animal:SetAttribute("Weight", weight)
    end
    
    -- Parent to workspace
    animal.Parent = workspace
    
    -- Add to tracking
    table.insert(spawnedAnimals, animal)
    
    return animal
end

local function spawnAnimal(animalType, weight)
    if #spawnedAnimals >= CONFIG.MAX_ANIMALS then
        createNotification("Maximum animals reached!", CONFIG.ERROR_COLOR)
        return
    end
    
    local playerPos = getPlayerPosition()
    local spawnPos = playerPos + Vector3.new(
        math.random(-CONFIG.SPAWN_DISTANCE, CONFIG.SPAWN_DISTANCE),
        2,
        math.random(-CONFIG.SPAWN_DISTANCE, CONFIG.SPAWN_DISTANCE)
    )
    
    local success, animal = pcall(createAnimal, animalType, spawnPos, weight)
    
    if success and animal then
        createNotification(string.format("Spawned %s (Weight: %.1f)", animalType, weight))
    else
        createNotification("Failed to spawn animal!", CONFIG.ERROR_COLOR)
    end
end

local function modifyAnimalWeight(animal, newWeight)
    if not animal or not animal.Parent then
        return false
    end
    
    local success = false
    
    -- Try different weight modification methods
    if animal:FindFirstChild("Weight") then
        animal.Weight.Value = newWeight
        success = true
    end
    
    local stats = animal:FindFirstChild("Stats")
    if stats and stats:FindFirstChild("Weight") then
        stats.Weight.Value = newWeight
        success = true
    end
    
    local humanoid = animal:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.MaxHealth = newWeight
        humanoid.Health = newWeight
        success = true
    end
    
    if not success then
        animal:SetAttribute("Weight", newWeight)
        success = true
    end
    
    return success
end

local function clearAllAnimals()
    for i, animal in ipairs(spawnedAnimals) do
        if animal and animal.Parent then
            animal:Destroy()
        end
    end
    spawnedAnimals = {}
    createNotification("Cleared all spawned animals")
end

-- GUI Creation Functions
local function createGUI()
    -- Main GUI
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PetSpawnerGUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui
    
    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 400, 0, 500)
    mainFrame.Position = UDim2.new(0, 20, 0, 20)
    mainFrame.BackgroundColor3 = CONFIG.MAIN_COLOR
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = mainFrame
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -20, 0, 40)
    title.Position = UDim2.new(0, 10, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = "🐾 Grow a Garden - Pet Spawner"
    title.TextColor3 = CONFIG.TEXT_COLOR
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = mainFrame
    
    -- Animal Selection
    local animalLabel = Instance.new("TextLabel")
    animalLabel.Size = UDim2.new(1, -20, 0, 25)
    animalLabel.Position = UDim2.new(0, 10, 0, 60)
    animalLabel.BackgroundTransparency = 1
    animalLabel.Text = "Select Animal:"
    animalLabel.TextColor3 = CONFIG.TEXT_COLOR
    animalLabel.TextScaled = true
    animalLabel.Font = Enum.Font.SourceSans
    animalLabel.TextXAlignment = Enum.TextXAlignment.Left
    animalLabel.Parent = mainFrame
    
    local animalDropdown = Instance.new("TextButton")
    animalDropdown.Name = "AnimalDropdown"
    animalDropdown.Size = UDim2.new(1, -20, 0, 35)
    animalDropdown.Position = UDim2.new(0, 10, 0, 90)
    animalDropdown.BackgroundColor3 = CONFIG.ACCENT_COLOR
    animalDropdown.Text = CONFIG.ANIMALS[1]
    animalDropdown.TextColor3 = CONFIG.TEXT_COLOR
    animalDropdown.TextScaled = true
    animalDropdown.Font = Enum.Font.SourceSans
    animalDropdown.Parent = mainFrame
    
    local dropdownCorner = Instance.new("UICorner")
    dropdownCorner.CornerRadius = UDim.new(0, 5)
    dropdownCorner.Parent = animalDropdown
    
    -- Weight Input
    local weightLabel = Instance.new("TextLabel")
    weightLabel.Size = UDim2.new(1, -20, 0, 25)
    weightLabel.Position = UDim2.new(0, 10, 0, 140)
    weightLabel.BackgroundTransparency = 1
    weightLabel.Text = "Weight:"
    weightLabel.TextColor3 = CONFIG.TEXT_COLOR
    weightLabel.TextScaled = true
    weightLabel.Font = Enum.Font.SourceSans
    weightLabel.TextXAlignment = Enum.TextXAlignment.Left
    weightLabel.Parent = mainFrame
    
    local weightInput = Instance.new("TextBox")
    weightInput.Name = "WeightInput"
    weightInput.Size = UDim2.new(1, -20, 0, 35)
    weightInput.Position = UDim2.new(0, 10, 0, 170)
    weightInput.BackgroundColor3 = CONFIG.ACCENT_COLOR
    weightInput.Text = tostring(CONFIG.DEFAULT_WEIGHT)
    weightInput.TextColor3 = CONFIG.TEXT_COLOR
    weightInput.TextScaled = true
    weightInput.Font = Enum.Font.SourceSans
    weightInput.PlaceholderText = "Enter weight (1-1000)"
    weightInput.Parent = mainFrame
    
    local weightCorner = Instance.new("UICorner")
    weightCorner.CornerRadius = UDim.new(0, 5)
    weightCorner.Parent = weightInput
    
    -- Spawn Button
    local spawnButton = Instance.new("TextButton")
    spawnButton.Name = "SpawnButton"
    spawnButton.Size = UDim2.new(1, -20, 0, 45)
    spawnButton.Position = UDim2.new(0, 10, 0, 220)
    spawnButton.BackgroundColor3 = Color3.fromRGB(34, 139, 34)
    spawnButton.Text = "🐄 Spawn Animal"
    spawnButton.TextColor3 = CONFIG.TEXT_COLOR
    spawnButton.TextScaled = true
    spawnButton.Font = Enum.Font.SourceSansBold
    spawnButton.Parent = mainFrame
    
    local spawnCorner = Instance.new("UICorner")
    spawnCorner.CornerRadius = UDim.new(0, 8)
    spawnCorner.Parent = spawnButton
    
    -- Modify Weight Section
    local modifyLabel = Instance.new("TextLabel")
    modifyLabel.Size = UDim2.new(1, -20, 0, 25)
    modifyLabel.Position = UDim2.new(0, 10, 0, 280)
    modifyLabel.BackgroundTransparency = 1
    modifyLabel.Text = "Modify All Animals Weight:"
    modifyLabel.TextColor3 = CONFIG.TEXT_COLOR
    modifyLabel.TextScaled = true
    modifyLabel.Font = Enum.Font.SourceSans
    modifyLabel.TextXAlignment = Enum.TextXAlignment.Left
    modifyLabel.Parent = mainFrame
    
    local modifyInput = Instance.new("TextBox")
    modifyInput.Name = "ModifyInput"
    modifyInput.Size = UDim2.new(0.6, -10, 0, 35)
    modifyInput.Position = UDim2.new(0, 10, 0, 310)
    modifyInput.BackgroundColor3 = CONFIG.ACCENT_COLOR
    modifyInput.Text = "100"
    modifyInput.TextColor3 = CONFIG.TEXT_COLOR
    modifyInput.TextScaled = true
    modifyInput.Font = Enum.Font.SourceSans
    modifyInput.PlaceholderText = "New weight"
    modifyInput.Parent = mainFrame
    
    local modifyInputCorner = Instance.new("UICorner")
    modifyInputCorner.CornerRadius = UDim.new(0, 5)
    modifyInputCorner.Parent = modifyInput
    
    local modifyButton = Instance.new("TextButton")
    modifyButton.Name = "ModifyButton"
    modifyButton.Size = UDim2.new(0.4, -10, 0, 35)
    modifyButton.Position = UDim2.new(0.6, 10, 0, 310)
    modifyButton.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
    modifyButton.Text = "⚡ Modify"
    modifyButton.TextColor3 = CONFIG.TEXT_COLOR
    modifyButton.TextScaled = true
    modifyButton.Font = Enum.Font.SourceSansBold
    modifyButton.Parent = mainFrame
    
    local modifyCorner = Instance.new("UICorner")
    modifyCorner.CornerRadius = UDim.new(0, 5)
    modifyCorner.Parent = modifyButton
    
    -- Random Spawn Button
    local randomButton = Instance.new("TextButton")
    randomButton.Name = "RandomButton"
    randomButton.Size = UDim2.new(0.48, -5, 0, 40)
    randomButton.Position = UDim2.new(0, 10, 0, 360)
    randomButton.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
    randomButton.Text = "🎲 Random Spawn"
    randomButton.TextColor3 = CONFIG.TEXT_COLOR
    randomButton.TextScaled = true
    randomButton.Font = Enum.Font.SourceSansBold
    randomButton.Parent = mainFrame
    
    local randomCorner = Instance.new("UICorner")
    randomCorner.CornerRadius = UDim.new(0, 8)
    randomCorner.Parent = randomButton
    
    -- Clear Button
    local clearButton = Instance.new("TextButton")
    clearButton.Name = "ClearButton"
    clearButton.Size = UDim2.new(0.48, -5, 0, 40)
    clearButton.Position = UDim2.new(0.52, 5, 0, 360)
    clearButton.BackgroundColor3 = CONFIG.ERROR_COLOR
    clearButton.Text = "🗑️ Clear All"
    clearButton.TextColor3 = CONFIG.TEXT_COLOR
    clearButton.TextScaled = true
    clearButton.Font = Enum.Font.SourceSansBold
    clearButton.Parent = mainFrame
    
    local clearCorner = Instance.new("UICorner")
    clearCorner.CornerRadius = UDim.new(0, 8)
    clearCorner.Parent = clearButton
    
    -- Stats Label
    local statsLabel = Instance.new("TextLabel")
    statsLabel.Name = "StatsLabel"
    statsLabel.Size = UDim2.new(1, -20, 0, 30)
    statsLabel.Position = UDim2.new(0, 10, 0, 415)
    statsLabel.BackgroundTransparency = 1
    statsLabel.Text = "Spawned Animals: 0"
    statsLabel.TextColor3 = CONFIG.TEXT_COLOR
    statsLabel.TextScaled = true
    statsLabel.Font = Enum.Font.SourceSans
    statsLabel.Parent = mainFrame
    
    -- Close Button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -40, 0, 10)
    closeButton.BackgroundColor3 = CONFIG.ERROR_COLOR
    closeButton.Text = "✕"
    closeButton.TextColor3 = CONFIG.TEXT_COLOR
    closeButton.TextScaled = true
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.Parent = mainFrame
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 15)
    closeCorner.Parent = closeButton
    
    return screenGui, {
        mainFrame = mainFrame,
        animalDropdown = animalDropdown,
        weightInput = weightInput,
        spawnButton = spawnButton,
        modifyInput = modifyInput,
        modifyButton = modifyButton,
        randomButton = randomButton,
        clearButton = clearButton,
        closeButton = closeButton,
        statsLabel = statsLabel
    }
end

-- Event Handlers
local function setupEventHandlers(elements)
    local currentAnimalIndex = 1
    
    -- Animal dropdown cycling
    elements.animalDropdown.MouseButton1Click:Connect(function()
        currentAnimalIndex = currentAnimalIndex + 1
        if currentAnimalIndex > #CONFIG.ANIMALS then
            currentAnimalIndex = 1
        end
        elements.animalDropdown.Text = CONFIG.ANIMALS[currentAnimalIndex]
    end)
    
    -- Spawn button
    elements.spawnButton.MouseButton1Click:Connect(function()
        local weight = tonumber(elements.weightInput.Text) or CONFIG.DEFAULT_WEIGHT
        weight = math.clamp(weight, CONFIG.MIN_WEIGHT, CONFIG.MAX_WEIGHT)
        
        spawnAnimal(CONFIG.ANIMALS[currentAnimalIndex], weight)
        
        -- Update stats
        elements.statsLabel.Text = string.format("Spawned Animals: %d", #spawnedAnimals)
    end)
    
    -- Modify weight button
    elements.modifyButton.MouseButton1Click:Connect(function()
        local newWeight = tonumber(elements.modifyInput.Text)
        if not newWeight then
            createNotification("Invalid weight value!", CONFIG.ERROR_COLOR)
            return
        end
        
        newWeight = math.clamp(newWeight, CONFIG.MIN_WEIGHT, CONFIG.MAX_WEIGHT)
        local modifiedCount = 0
        
        for i, animal in ipairs(spawnedAnimals) do
            if animal and animal.Parent then
                if modifyAnimalWeight(animal, newWeight) then
                    modifiedCount = modifiedCount + 1
                end
            end
        end
        
        if modifiedCount > 0 then
            createNotification(string.format("Modified %d animals to weight %.1f", modifiedCount, newWeight))
        else
            createNotification("No animals to modify!", CONFIG.ERROR_COLOR)
        end
    end)
    
    -- Random spawn button
    elements.randomButton.MouseButton1Click:Connect(function()
        local randomAnimal = CONFIG.ANIMALS[math.random(1, #CONFIG.ANIMALS)]
        local randomWeight = math.random(CONFIG.MIN_WEIGHT, CONFIG.MAX_WEIGHT)
        
        spawnAnimal(randomAnimal, randomWeight)
        elements.statsLabel.Text = string.format("Spawned Animals: %d", #spawnedAnimals)
    end)
    
    -- Clear button
    elements.clearButton.MouseButton1Click:Connect(function()
        clearAllAnimals()
        elements.statsLabel.Text = "Spawned Animals: 0"
    end)
    
    -- Close button
    elements.closeButton.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)
    
    -- Update stats periodically
    RunService.Heartbeat:Connect(function()
        -- Clean up destroyed animals
        for i = #spawnedAnimals, 1, -1 do
            if not spawnedAnimals[i] or not spawnedAnimals[i].Parent then
                table.remove(spawnedAnimals, i)
            end
        end
        
        if elements.statsLabel then
            elements.statsLabel.Text = string.format("Spawned Animals: %d", #spawnedAnimals)
        end
    end)
end

-- Keyboard shortcuts
local function setupKeyboardShortcuts()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.P then -- P to spawn random
            local randomAnimal = CONFIG.ANIMALS[math.random(1, #CONFIG.ANIMALS)]
            local randomWeight = math.random(CONFIG.MIN_WEIGHT, CONFIG.MAX_WEIGHT)
            spawnAnimal(randomAnimal, randomWeight)
        elseif input.KeyCode == Enum.KeyCode.C then -- C to clear all
            clearAllAnimals()
        elseif input.KeyCode == Enum.KeyCode.M then -- M to toggle GUI
            if gui then
                gui.MainFrame.Visible = not gui.MainFrame.Visible
            end
        end
    end)
end

-- Main execution
local function main()
    -- Clean up existing GUI
    local existingGui = playerGui:FindFirstChild("PetSpawnerGUI")
    if existingGui then
        existingGui:Destroy()
    end
    
    -- Create and setup GUI
    local screenGui, elements = createGUI()
    gui = screenGui
    
    setupEventHandlers(elements)
    setupKeyboardShortcuts()
    
    -- Welcome message
    createNotification("🐾 Pet Spawner Loaded! Press M to toggle GUI")
    
    print("=== Grow a Garden Pet Spawner ===")
    print("Controls:")
    print("P - Spawn random animal")
    print("C - Clear all animals")
    print("M - Toggle GUI")
    print("=================================")
end

-- Auto-execute when script loads
main()

-- Export functions for external use
_G.PetSpawner = {
    spawnAnimal = spawnAnimal,
    modifyAnimalWeight = modifyAnimalWei
