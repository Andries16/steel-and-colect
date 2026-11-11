--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local Definitions = require(ReplicatedStorage.Shared.Definitions.Collectibles)
local CollectibleService = require(ServerScriptService.Services.CollectibleService)

local MarketplaceService = {}
local marketFolder: Folder?

local function makeStand(parent: Instance, collectibleId: string, definition: any, index: number): Part
    local angle = ((index - 1) / 10) * math.pi * 2
    local position = Vector3.new(math.cos(angle) * 24, 2, math.sin(angle) * 24)
    local stand = Instance.new("Part")
    stand.Name = collectibleId
    stand.Size = Vector3.new(7, 4, 7)
    stand.Position = position
    stand.Anchored = true
    stand.Material = Enum.Material.Neon
    stand.Color = Color3.fromRGB(72, 146, 173)
    stand.Parent = parent
    stand:SetAttribute("CollectibleId", collectibleId)

    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Buy for " .. tostring(definition.acquisitionPrice) .. " coins"
    prompt.ObjectText = definition.displayName
    prompt.HoldDuration = 0.25
    prompt.MaxActivationDistance = 12
    prompt.RequiresLineOfSight = false
    prompt.Parent = stand
    prompt.Triggered:Connect(function(player: Player)
        CollectibleService:PurchaseFromWorld(player, collectibleId)
    end)
    return stand
end

function MarketplaceService:Init()
    local existing = Workspace:FindFirstChild("Marketplace")
    if existing and existing:IsA("Folder") then
        marketFolder = existing
    else
        marketFolder = Instance.new("Folder")
        marketFolder.Name = "Marketplace"
        marketFolder.Parent = Workspace
    end
    local floor = Workspace:FindFirstChild("MarketplaceFloor")
    if not floor then
        local plaza = Instance.new("Part")
        plaza.Name = "MarketplaceFloor"
        plaza.Size = Vector3.new(76, 2, 76)
        plaza.Position = Vector3.new(0, -1, 0)
        plaza.Anchored = true
        plaza.Material = Enum.Material.Slate
        plaza.Color = Color3.fromRGB(49, 57, 72)
        plaza.Parent = Workspace
    end
    local index = 0
    for collectibleId, definition in pairs(Definitions) do
        index += 1
        if not marketFolder:FindFirstChild(collectibleId) then
            makeStand(marketFolder, collectibleId, definition, index)
        end
    end
end

function MarketplaceService:Start() end
function MarketplaceService:Destroy() end

return MarketplaceService
