--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage.Shared.Config.GameConfig)
local BaseService = {}
local assignments: { [number]: number } = {}
local occupied: { [number]: number } = {}
local plotsFolder: Folder?

local function getPlotsFolder(): Folder
    local existing = Workspace:FindFirstChild("BasePlots")
    if existing and existing:IsA("Folder") then return existing end
    local folder = Instance.new("Folder")
    folder.Name = "BasePlots"
    folder.Parent = Workspace
    return folder
end

function BaseService:Init()
    plotsFolder = getPlotsFolder()
end

function BaseService:Allocate(player: Player): number?
    local existing = assignments[player.UserId]
    if existing then return existing end
    for plotId = 1, Config.BASE_PLOT_COUNT do
        if not occupied[plotId] then
            occupied[plotId] = player.UserId
            assignments[player.UserId] = plotId
            player:SetAttribute("BasePlotId", plotId)
            return plotId
        end
    end
    return nil
end

function BaseService:GetPlotId(player: Player): number?
    return assignments[player.UserId]
end

function BaseService:Release(player: Player)
    local plotId = assignments[player.UserId]
    if not plotId then return end
    if occupied[plotId] == player.UserId then occupied[plotId] = nil end
    assignments[player.UserId] = nil
    player:SetAttribute("BasePlotId", nil)
end

function BaseService:Start()
    -- Plot geometry is intentionally generated in a later world-building milestone.
    assert(plotsFolder, "BaseService.Init() must run before Start()")
end

function BaseService:Destroy()
    table.clear(assignments)
    table.clear(occupied)
end

return BaseService
