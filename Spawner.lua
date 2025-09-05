Grow a Garden Pet Spawner - DELTA ANDROID COMPATIBLE
-- Super basic version for Delta Android
-- NO GUI, NO COMPLEX FUNCTIONS - Just basic commands

print("🐾 Loading Delta Android Pet Spawner...")

local players = game:GetService("Players")
local player = players.LocalPlayer

-- Basic pet list
local pets = {"Chicken", "Cow", "Pig", "Sheep", "Horse", "Duck", "Goat", "Rabbit", "Dog", "Cat"}
local spawnedPets = {}

print("✅ Pet Spawner Loaded Successfully!")
print("📋 Available Commands:")
print("spawn() - Spawn a pet")
print("random() - Spawn random pet") 
print("clear() - Clear all pets")
print("list() - Show pet types")

-- Get player position function
local function getPlayerPos()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        return player.Character.HumanoidRootPart.Position
    end
    return Vector3.new(0, 10, 0)
end

-- Create basic pet function
local function createPet(petName, position, weight)
    weight = weight or 50
    
    -- Create simple pet model
    local pet = Instance.new("Model")
    pet.Name = petName
    
    -- Main body part
    local body = Instance.new("Part")
    body.Name = "Body"
    body.Size = Vector3.new(2, 1, 3)
    body.Material = Enum.Material.Neon
    body.BrickColor = BrickColor.Random()
    body.Anchored = false
    body.CanCollide = true
    body.Parent = pet
    
    -- Simple humanoid
    local humanoid = Instance.new("Humanoid")
    humanoid.MaxHealth = weight
    humanoid.Health = weight
    humanoid.Parent = pet
    
    -- Weight value
    local weightVal = Instance.new("NumberValue")
    weightVal.Name = "Weight"
    weightVal.Value = weight
    weightVal.Parent = pet
    
    -- Set position
    pet.PrimaryPart = body
    pet:SetPrimaryPartCFrame(CFrame.new(position))
    
    -- Add to workspace
    pet.Parent = workspace
    
    -- Track spawned pets
    table.insert(spawnedPets, pet)
    
    return pet
end

-- Spawn pet function
local function spawnPet(petType, petWeight)
    petType = petType or pets[math.random(1, #pets)]
    petWeight = petWeight or math.random(20, 200)
    
    local playerPos = getPlayerPos()
    local spawnPos = playerPos + Vector3.new(
        math.random(-5, 5),
        2,
        math.random(-5, 5)
    )
    
    local success, pet = pcall(createPet, petType, spawnPos, petWeight)
    
    if success then
        print("✅ Spawned " .. petType .. " with weight " .. petWeight)
        return pet
    else
        print("❌ Failed to spawn pet!")
        return nil
    end
end

-- Clear all pets function
local function clearAllPets()
    local count = 0
    for i, pet in pairs(spawnedPets) do
        if pet and pet.Parent then
            pet:Destroy()
            count = count + 1
        end
    end
    spawnedPets = {}
    print("🗑️ Cleared " .. count .. " pets")
end

-- List pets function
local function listPets()
    print("🐾 Available Pet Types:")
    for i, petName in pairs(pets) do
        print(i .. ". " .. petName)
    end
end

-- Modify all pets weight
local function modifyWeight(newWeight)
    if not newWeight or newWeight < 1 or newWeight > 1000 then
        print("❌ Invalid weight! Use 1-1000")
        return
    end
    
    local modified = 0
    for i, pet in pairs(spawnedPets) do
        if pet and pet.Parent then
            local weightVal = pet:FindFirstChild("Weight")
            if weightVal then
                weightVal.Value = newWeight
            end
            
            local humanoid = pet:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.MaxHealth = newWeight
                humanoid.Health = newWeight
            end
            
            modified = modified + 1
        end
    end
    
    print("⚡ Modified " .. modified .. " pets to weight " .. newWeight)
end

-- Global functions for easy access
_G.spawn = function(petNum, weight)
    if petNum then
        if petNum >= 1 and petNum <= #pets then
            return spawnPet(pets[petNum], weight)
        else
            print("❌ Invalid pet number! Use 1-" .. #pets)
        end
    else
        return spawnPet()
    end
end

_G.random = function()
    return spawnPet()
end

_G.clear = function()
    clearAllPets()
end

_G.list = function()
    listPets()
end

_G.modify = function(weight)
    modifyWeight(weight)
end

_G.help = function()
    print("🐾 DELTA ANDROID PET SPAWNER COMMANDS:")
    print("spawn() - Spawn random pet")
    print("spawn(1) - Spawn pet #1 (Chicken)")  
    print("spawn(2, 100) - Spawn pet #2 with weight 100")
    print("random() - Spawn random pet")
    print("clear() - Clear all pets")
    print("list() - Show all pet types")
    print("modify(200) - Change all pets weight to 200")
    print("help() - Show this help")
end

print("")
print("🎮 READY TO USE!")
print("Type: help() for commands")
print("")
