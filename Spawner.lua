-- Grow a Garden Pet Spawner
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local pets = {"Chicken", "Cow", "Pig", "Sheep", "Horse", "Duck", "Goat", "Rabbit", "Dog", "Cat"}
local spawnedPets = {}

local function notify(msg)
    game.StarterGui:SetCore("ChatMakeSystemMessage", {
        Text = "[Pet Spawner] " .. msg;
        Color = Color3.fromRGB(0, 255, 0);
    })
end

local function getPos()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        return player.Character.HumanoidRootPart.Position
    end
    return Vector3.new(0, 10, 0)
end

local function makePet(name, pos, weight)
    local pet = Instance.new("Model")
    pet.Name = name
    local body = Instance.new("Part")
    body.Name = "Body"
    body.Size = Vector3.new(2, 1, 3)
    body.Material = Enum.Material.Neon
    body.BrickColor = BrickColor.Random()
    body.Parent = pet
    local humanoid = Instance.new("Humanoid")
    humanoid.MaxHealth = weight or 50
    humanoid.Health = weight or 50
    humanoid.Parent = pet
    pet.PrimaryPart = body
    pet:MoveTo(pos)
    pet.Parent = workspace
    table.insert(spawnedPets, pet)
    return pet
end

_G.spawn = function(num, weight)
    num = num or math.random(1, #pets)
    weight = weight or math.random(20, 200)
    local pos = getPos() + Vector3.new(math.random(-5,5), 2, math.random(-5,5))
    makePet(pets[num], pos, weight)
    notify("Spawned " .. pets[num] .. " (" .. weight .. "kg)")
end

_G.clear = function()
    for _, pet in pairs(spawnedPets) do
        if pet and pet.Parent then pet:Destroy() end
    end
    spawnedPets = {}
    notify("Cleared all pets!")
end

notify("Pet Spawner Loaded!")
notify("Commands: spawn(), spawn(1), spawn(2,100), clear()")
