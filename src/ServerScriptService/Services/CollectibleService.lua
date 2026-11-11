--!strict

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local BaseService = require(ServerScriptService.Services.BaseService)

local Definitions = require(ReplicatedStorage.Shared.Definitions.Collectibles)
local Response = require(ReplicatedStorage.Shared.Network.Response)
local RemoteRegistry = require(ServerScriptService.Network.RemoteRegistry)
local ProfileService = require(ServerScriptService.Services.ProfileService)

local CollectibleService = {}
local lastRequestAt: { [number]: number } = {}
local REQUEST_COOLDOWN = 0.35

local function findOwned(profile: any, instanceId: string): number?
    for index, item in ipairs(profile.collection.owned) do
        if item.instanceId == instanceId then return index end
    end
    return nil
end

local function isPlaced(profile: any, instanceId: string): boolean
    for _, placedId in pairs(profile.base.placedBySlot) do
        if placedId == instanceId then return true end
    end
    return false
end

local function respond(remote: RemoteEvent, player: Player, requestId: string, ok: boolean, code: string, message: string, data: any?)
    local result = if ok then Response.success(requestId, data) else Response.failure(requestId, code, message)
    remote:FireClient(player, result)
end

local function isNearMarket(player: Player, collectibleId: string): boolean
    local market = Workspace:FindFirstChild("Marketplace")
    local pad = market and market:FindFirstChild(collectibleId)
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not pad or not pad:IsA("BasePart") or not root or not root:IsA("BasePart") then return false end
    return (root.Position - pad.Position).Magnitude <= 18
end

function CollectibleService:PurchaseFromWorld(player: Player, collectibleId: string)
    if not ProfileService:IsLoaded(player) then return end
    local profile = ProfileService:GetProfile(player)
    local definition = Definitions[collectibleId]
    if not profile or not definition or not isNearMarket(player, collectibleId) then return end
    if profile.economy.currency < definition.acquisitionPrice then
        RemoteRegistry.Get("Notification"):FireClient(player, { message = "Not enough coins." })
        return
    end
    profile.economy.currency -= definition.acquisitionPrice
    local item = {
        instanceId = HttpService:GenerateGUID(false),
        definitionId = collectibleId,
        acquiredAt = os.time(),
    }
    table.insert(profile.collection.owned, item)
    profile.statistics.collectiblesCollected += 1
    player:SetAttribute("Currency", profile.economy.currency)
    RemoteRegistry.Get("InventoryUpdated"):FireClient(player, profile.collection.owned)
    RemoteRegistry.Get("EconomyUpdated"):FireClient(player, { currency = profile.economy.currency })
    RemoteRegistry.Get("Notification"):FireClient(player, { message = "Collected " .. definition.displayName .. "!" })
end

function CollectibleService:Init() end

function CollectibleService:Start()
    local remote = RemoteRegistry.Get("CollectibleRequest")
    remote.OnServerEvent:Connect(function(player: Player, payload: any)
        if type(payload) ~= "table" then return end
        local requestId = if type(payload.requestId) == "string" and #payload.requestId <= 64
            then payload.requestId else ""
        local now = os.clock()
        local previous = lastRequestAt[player.UserId] or 0
        if now - previous < REQUEST_COOLDOWN then
            respond(remote, player, requestId, false, "RATE_LIMITED", "Please wait before sending another request.")
            return
        end
        lastRequestAt[player.UserId] = now

        if not ProfileService:IsLoaded(player) then
            respond(remote, player, requestId, false, "PROFILE_NOT_READY", "Your player data is still loading.")
            return
        end

        local profile = ProfileService:GetProfile(player)
        if not profile then
            respond(remote, player, requestId, false, "PROFILE_NOT_FOUND", "Your player data is unavailable.")
            return
        end

        if payload.action == "purchase" then
            if type(payload.collectibleId) ~= "string" or #payload.collectibleId > 48 then
                respond(remote, player, requestId, false, "INVALID_COLLECTIBLE", "Invalid collectible.")
                return
            end
            local definition = Definitions[payload.collectibleId]
            if not definition then
                respond(remote, player, requestId, false, "UNKNOWN_COLLECTIBLE", "That collectible does not exist.")
                return
            end
            if not isNearMarket(player, payload.collectibleId) then
                respond(remote, player, requestId, false, "TOO_FAR_FROM_MARKET", "Move closer to the marketplace stand.")
                return
            end
            if profile.economy.currency < definition.acquisitionPrice then
                respond(remote, player, requestId, false, "INSUFFICIENT_FUNDS", "You do not have enough currency.")
                return
            end

            profile.economy.currency -= definition.acquisitionPrice
            local item = {
                instanceId = HttpService:GenerateGUID(false),
                definitionId = payload.collectibleId,
                acquiredAt = os.time(),
            }
            table.insert(profile.collection.owned, item)
            profile.statistics.collectiblesCollected += 1
            player:SetAttribute("Currency", profile.economy.currency)
            remote:FireClient(player, Response.success(requestId, {
                action = "purchased",
                item = item,
                currency = profile.economy.currency,
            }))
            RemoteRegistry.Get("InventoryUpdated"):FireClient(player, profile.collection.owned)
            return
        end

        if payload.action == "place" then
            if type(payload.instanceId) ~= "string" or #payload.instanceId > 64
                or type(payload.slot) ~= "number" or payload.slot % 1 ~= 0 then
                respond(remote, player, requestId, false, "INVALID_PLACEMENT", "Invalid display slot or collectible.")
                return
            end
            local slot = payload.slot
            if slot < 1 or slot > profile.base.displaySlots then
                respond(remote, player, requestId, false, "SLOT_UNAVAILABLE", "That display slot is not unlocked.")
                return
            end
            if not BaseService:IsNearOwnPlot(player, 75) then
                respond(remote, player, requestId, false, "TOO_FAR_FROM_BASE", "You must be at your own base to manage displays.")
                return
            end
            if not findOwned(profile, payload.instanceId) then
                respond(remote, player, requestId, false, "NOT_OWNED", "You do not own that collectible.")
                return
            end
            if isPlaced(profile, payload.instanceId) then
                respond(remote, player, requestId, false, "ALREADY_PLACED", "That collectible is already displayed.")
                return
            end
            if profile.base.placedBySlot[slot] then
                respond(remote, player, requestId, false, "SLOT_OCCUPIED", "That display slot is occupied.")
                return
            end
            profile.base.placedBySlot[slot] = payload.instanceId
            respond(remote, player, requestId, true, "OK", "", {
                action = "placed",
                slot = slot,
                instanceId = payload.instanceId,
            })
            return
        end

        if payload.action == "unplace" then
            if type(payload.slot) ~= "number" or payload.slot % 1 ~= 0 then
                respond(remote, player, requestId, false, "INVALID_SLOT", "Invalid display slot.")
                return
            end
            if not BaseService:IsNearOwnPlot(player, 75) then
                respond(remote, player, requestId, false, "TOO_FAR_FROM_BASE", "You must be at your own base to manage displays.")
                return
            end
            local instanceId = profile.base.placedBySlot[payload.slot]
            if not instanceId then
                respond(remote, player, requestId, false, "SLOT_EMPTY", "That display slot is empty.")
                return
            end
            profile.base.placedBySlot[payload.slot] = nil
            respond(remote, player, requestId, true, "OK", "", {
                action = "unplaced",
                slot = payload.slot,
                instanceId = instanceId,
            })
            return
        end

        respond(remote, player, requestId, false, "UNKNOWN_ACTION", "Unsupported collectible action.")
    end)

    Players.PlayerRemoving:Connect(function(player)
        lastRequestAt[player.UserId] = nil
    end)
end

function CollectibleService:Destroy()
    table.clear(lastRequestAt)
end

return CollectibleService
