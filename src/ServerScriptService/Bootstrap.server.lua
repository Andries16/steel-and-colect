--!strict

local ServerScriptService = game:GetService("ServerScriptService")
local Services = ServerScriptService:WaitForChild("Services")
local RemoteRegistry = require(ServerScriptService.Network.RemoteRegistry)

-- Dependencies are initialized in this explicit order.
local serviceNames = {
    "ProfileService", "BaseService", "PlayerService", "EconomyService",
    "InventoryService", "CollectibleService", "IncomeService", "RaidService",
    "TransferService", "ProgressionService", "QuestService", "PurchaseService",
    "AnalyticsService",
}

RemoteRegistry.Init()
local loaded = {}
for _, name in ipairs(serviceNames) do
    local module = Services:FindFirstChild(name)
    if module then
        local service = require(module)
        table.insert(loaded, service)
        if type(service.Init) == "function" then service:Init() end
    end
end
for _, service in ipairs(loaded) do
    if type(service.Start) == "function" then service:Start() end
end

game:BindToClose(function()
    for index = #loaded, 1, -1 do
        local service = loaded[index]
        if type(service.Destroy) == "function" then service:Destroy() end
    end
end)
