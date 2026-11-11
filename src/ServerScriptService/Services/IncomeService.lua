--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Definitions = require(ReplicatedStorage.Shared.Definitions.Collectibles)
local ProfileService = require(ServerScriptService.Services.ProfileService)
local RemoteRegistry = require(ServerScriptService.Network.RemoteRegistry)

local IncomeService = {}
local running = false
local fractionalIncome: { [number]: number } = {}
local TICK_SECONDS = 1
local MAX_ELAPSED_PER_TICK = 2

local function getIncomeRate(profile: any): number
    local rate = 0
    local ownedById = {}
    for _, item in ipairs(profile.collection.owned) do
        ownedById[item.instanceId] = item
    end

    for _, instanceId in pairs(profile.base.placedBySlot) do
        local item = ownedById[instanceId]
        if item then
            local definition = Definitions[item.definitionId]
            if definition then rate += definition.baseIncomePerSecond end
        end
    end
    return rate
end

function IncomeService:Init() end

function IncomeService:Start()
    running = true
    task.spawn(function()
        local previousTick = os.clock()
        while running do
            task.wait(TICK_SECONDS)
            local now = os.clock()
            local elapsed = math.min(now - previousTick, MAX_ELAPSED_PER_TICK)
            previousTick = now

            for _, player in ipairs(Players:GetPlayers()) do
                local profile = ProfileService:GetProfile(player)
                if profile and ProfileService:IsLoaded(player) then
                    local earned = getIncomeRate(profile) * elapsed
                    local accumulated = (fractionalIncome[player.UserId] or 0) + earned
                    local wholeCurrency = math.floor(accumulated)
                    fractionalIncome[player.UserId] = accumulated - wholeCurrency

                    if wholeCurrency > 0 then
                        profile.economy.currency += wholeCurrency
                        profile.economy.lifetimeEarned += wholeCurrency
                        player:SetAttribute("Currency", profile.economy.currency)
                        RemoteRegistry.Get("EconomyUpdated"):FireClient(player, {
                            earned = wholeCurrency,
                            balance = profile.economy.currency,
                        })
                    end
                end
            end
        end
    end)

    Players.PlayerRemoving:Connect(function(player)
        fractionalIncome[player.UserId] = nil
    end)
end

function IncomeService:Destroy()
    running = false
    table.clear(fractionalIncome)
end

return IncomeService
