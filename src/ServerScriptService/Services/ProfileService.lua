--!strict

local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local SCHEMA_VERSION = 1
local STORE_NAME = "PlayerProfiles_v1"
local AUTOSAVE_INTERVAL = 90
local LEASE_SECONDS = 180
local LEASE_RENEW_INTERVAL = 60
local LOAD_ATTEMPTS = 12

type Profile = {
    meta: { schemaVersion: number, createdAt: number, lastSeenAt: number },
    economy: { currency: number, lifetimeEarned: number },
    collection: { owned: { any } },
    base: { level: number, displaySlots: number, placedBySlot: { [number]: string }, defenseLevel: number },
    progression: { tutorialCompleted: boolean, level: number, experience: number },
    security: { lastRaidAt: number?, protectedUntil: number? },
    purchases: { processedPurchaseIds: { string } },
    statistics: { collectiblesCollected: number, successfulRaids: number, failedRaids: number },
}

local ProfileService = {}
local store = DataStoreService:GetDataStore(STORE_NAME)
local profiles: { [number]: Profile } = {}
local saving: { [number]: boolean } = {}
local loaded: { [number]: boolean } = {}
local shuttingDown = false
local sessionId = if game.JobId ~= "" then game.JobId else HttpService:GenerateGUID(false)

local function makeDefaultProfile(): Profile
    local now = os.time()
    return {
        meta = { schemaVersion = SCHEMA_VERSION, createdAt = now, lastSeenAt = now },
        economy = { currency = 0, lifetimeEarned = 0 },
        collection = { owned = { { instanceId = HttpService:GenerateGUID(false), definitionId = "sprout", acquiredAt = now } } },
        base = { level = 1, displaySlots = 5, placedBySlot = {}, defenseLevel = 0 },
        progression = { tutorialCompleted = false, level = 1, experience = 0 },
        security = {},
        purchases = { processedPurchaseIds = {} },
        statistics = { collectiblesCollected = 1, successfulRaids = 0, failedRaids = 0 },
    }
end

local function reconcile(data: any): Profile
    local defaults = makeDefaultProfile()
    if type(data) ~= "table" then return defaults end
    for key, value in pairs(defaults) do
        if type(data[key]) ~= "table" then data[key] = value end
    end
    data.meta.schemaVersion = SCHEMA_VERSION
    data.meta.createdAt = tonumber(data.meta.createdAt) or defaults.meta.createdAt
    data.meta.lastSeenAt = os.time()
    data.economy.currency = math.max(0, tonumber(data.economy.currency) or 0)
    data.economy.lifetimeEarned = math.max(0, tonumber(data.economy.lifetimeEarned) or 0)
    data.collection.owned = if type(data.collection.owned) == "table" then data.collection.owned else {}
    data.base.level = math.max(1, tonumber(data.base.level) or 1)
    data.base.displaySlots = math.max(1, tonumber(data.base.displaySlots) or 5)
    data.base.placedBySlot = if type(data.base.placedBySlot) == "table" then data.base.placedBySlot else {}
    data.base.defenseLevel = math.max(0, tonumber(data.base.defenseLevel) or 0)
    data.progression.tutorialCompleted = data.progression.tutorialCompleted == true
    data.progression.level = math.max(1, tonumber(data.progression.level) or 1)
    data.progression.experience = math.max(0, tonumber(data.progression.experience) or 0)
    data.purchases.processedPurchaseIds = if type(data.purchases.processedPurchaseIds) == "table" then data.purchases.processedPurchaseIds else {}
    data.statistics.collectiblesCollected = math.max(0, tonumber(data.statistics.collectiblesCollected) or 0)
    data.statistics.successfulRaids = math.max(0, tonumber(data.statistics.successfulRaids) or 0)
    data.statistics.failedRaids = math.max(0, tonumber(data.statistics.failedRaids) or 0)
    return data :: Profile
end

local function keyFor(userId: number): string
    return "player_" .. tostring(userId)
end

function ProfileService:GetProfile(player: Player): Profile?
    return profiles[player.UserId]
end

function ProfileService:IsLoaded(player: Player): boolean
    return loaded[player.UserId] == true
end

function ProfileService:Load(player: Player): (boolean, string?)
    local key = keyFor(player.UserId)
    for attempt = 1, LOAD_ATTEMPTS do
        if player.Parent ~= Players or shuttingDown then return false, "Player left during profile load" end
        local now = os.time()
        local ok, record = pcall(function()
            return store:UpdateAsync(key, function(current)
                current = if type(current) == "table" then current else {}
                local session = current.session
                local leaseAvailable = type(session) ~= "table"
                    or session.owner == sessionId
                    or (tonumber(session.expiresAt) or 0) <= now
                if not leaseAvailable then return nil end
                current.data = reconcile(current.data)
                current.session = {
                    owner = sessionId,
                    placeId = game.PlaceId,
                    expiresAt = now + LEASE_SECONDS,
                }
                return current
            end)
        end)
        if ok and type(record) == "table" and type(record.data) == "table"
            and type(record.session) == "table" and record.session.owner == sessionId then
            profiles[player.UserId] = reconcile(record.data)
            loaded[player.UserId] = true
            return true
        end
        if not ok then
            warn("Profile load failed for", player.UserId, record)
        end
        task.wait(math.min(attempt * 2, 10))
    end
    return false, "Profile is unavailable or active in another server"
end

function ProfileService:Save(player: Player, release: boolean?): boolean
    local userId = player.UserId
    local profile = profiles[userId]
    if not profile or saving[userId] then return false end
    saving[userId] = true
    profile.meta.lastSeenAt = os.time()
    local snapshot = profile
    local ok, result = pcall(function()
        return store:UpdateAsync(keyFor(userId), function(current)
            if type(current) ~= "table" or type(current.session) ~= "table"
                or current.session.owner ~= sessionId then
                return nil
            end
            current.data = snapshot
            if release then
                current.session = nil
            else
                current.session.expiresAt = os.time() + LEASE_SECONDS
            end
            return current
        end)
    end)
    saving[userId] = nil
    local saved = ok and type(result) == "table"
    if not saved then
        warn("Profile save failed or session ownership lost for", userId, result)
    end
    if saved and release then
        profiles[userId] = nil
        loaded[userId] = nil
    end
    return saved
end

function ProfileService:Start()
    Players.PlayerAdded:Connect(function(player)
        local ok, reason = self:Load(player)
        if not ok then
            if player.Parent == Players then
                player:Kick("Your data could not be loaded safely. Please rejoin. " .. (reason or ""))
            end
        end
    end)
    Players.PlayerRemoving:Connect(function(player)
        if loaded[player.UserId] then
            self:Save(player, true)
        end
    end)

    for _, player in ipairs(Players:GetPlayers()) do
        task.spawn(function()
            local ok, reason = self:Load(player)
            if not ok and player.Parent == Players then
                player:Kick("Your data could not be loaded safely. Please rejoin. " .. (reason or ""))
            end
        end)
    end

    task.spawn(function()
        while not shuttingDown do
            task.wait(AUTOSAVE_INTERVAL)
            for _, player in ipairs(Players:GetPlayers()) do
                if loaded[player.UserId] then self:Save(player, false) end
            end
        end
    end)

    task.spawn(function()
        while not shuttingDown do
            task.wait(LEASE_RENEW_INTERVAL)
            for _, player in ipairs(Players:GetPlayers()) do
                if loaded[player.UserId] then self:Save(player, false) end
            end
        end
    end)
end

function ProfileService:Destroy()
    shuttingDown = true
    for _, player in ipairs(Players:GetPlayers()) do
        if loaded[player.UserId] then self:Save(player, true) end
    end
end

return ProfileService
