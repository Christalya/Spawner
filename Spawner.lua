-- Grow a Garden - Pet Spawner & Weight Modifier Script
-- Created for Roblox Game: Grow a Garden
-- Features: Spawn pets/animals, modify weight, GUI interface

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Configuration
local CONFIG = {
    -- Animal/Pet Types (customize based on game)
    ANIMALS = {
        "Chicken", "Cow", "Pig", "Sheep", "Horse", "Duck", "Goat", 
        "Rabbit", "Dog", "Cat", "Turkey", "Llama", "Goose"
    },
    
    -- Weight ranges
    MIN_WEIGHT = 1,
    MAX_WEIGHT = 1000,
    DEFAULT_WEIGHT = 50,
    
    -- Spawn settings
    SPAWN_DISTANCE = 10,
    MAX_ANIMALS = 50,
    
    -- GUI Colors
    MAIN_COLOR = Color3.fromRGB(85, 170, 85),
    ACCENT_COLOR = Color3.fromRGB(107, 142, 35),
    TEXT_COLOR = Color3.fromRGB(255, 255, 255),
    ERROR_COLOR = Color3.fromRGB(220, 20, 60)
}

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
