--!strict

local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local Services = ServerScriptService:WaitForChild("Services")
local ProfileService = require(Services:WaitForChild("ProfileService"))
local BaseService = require(Services:WaitForChild("BaseService"))

local PlayerService = {}

local function initializePlayer(player: Player)
    if not ProfileService:IsLoaded(player) then return end
    local plotId = BaseService:Allocate(player)
    if not plotId then
        player:Kick("This server is full. Please join another server.")
        return
    end
    local profile = ProfileService:GetProfile(player)
    if profile then
        player:SetAttribute("PlayerLevel", profile.progression.level)
        player:SetAttribute("Currency", profile.economy.currency)
    end
end

function PlayerService:Init() end

function PlayerService:Start()
    Players.PlayerAdded:Connect(function(player)
        task.spawn(function()
            local deadline = os.clock() + 90
            while player.Parent == Players and not ProfileService:IsLoaded(player) and os.clock() < deadline do
                task.wait(0.25)
            end
            if player.Parent == Players then initializePlayer(player) end
        end)
    end)
    Players.PlayerRemoving:Connect(function(player)
        BaseService:Release(player)
    end)
    for _, player in ipairs(Players:GetPlayers()) do
        task.spawn(initializePlayer, player)
    end
end

function PlayerService:Destroy()
    for _, player in ipairs(Players:GetPlayers()) do BaseService:Release(player) end
end

return PlayerService
