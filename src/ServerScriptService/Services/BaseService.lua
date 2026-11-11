--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage.Shared.Config.GameConfig)
local Definitions = require(ReplicatedStorage.Shared.Definitions.Collectibles)

local BaseService = {}
local assignments: { [number]: number } = {}
local occupied: { [number]: number } = {}
local plotsFolder: Folder?
local plotParts: { [number]: Model } = {}

local PLOT_RADIUS = 105
local PLOT_SIZE = Vector3.new(54, 1, 54)
local SLOT_OFFSETS = {
    Vector3.new(-15, 1, -15),
    Vector3.new(0, 1, -15),
    Vector3.new(15, 1, -15),
    Vector3.new(-15, 1, 5),
    Vector3.new(0, 1, 5),
    Vector3.new(15, 1, 5),
    Vector3.new(-15, 1, 20),
    Vector3.new(0, 1, 20),
    Vector3.new(15, 1, 20),
}

local function makePart(parent: Instance, name: string, size: Vector3, position: Vector3, color: Color3, material: Enum.Material): Part
    local part = Instance.new("Part")
    part.Name = name
    part.Size = size
    part.Position = position
    part.Anchored = true
    part.TopSurface = Enum.SurfaceType.Smooth
    part.BottomSurface = Enum.SurfaceType.Smooth
    part.Color = color
    part.Material = material
    part.Parent = parent
    return part
end

local function buildPlot(plotId: number): Model
    local angle = ((plotId - 1) / Config.BASE_PLOT_COUNT) * math.pi * 2
    local center = Vector3.new(math.cos(angle) * PLOT_RADIUS, 0, math.sin(angle) * PLOT_RADIUS)
    local model = Instance.new("Model")
    model.Name = "Plot" .. plotId
    model:SetAttribute("PlotId", plotId)
    model.Parent = plotsFolder

    local floor = makePart(model, "Floor", PLOT_SIZE, center, Color3.fromRGB(48, 93, 75), Enum.Material.Grass)
    model.PrimaryPart = floor
    makePart(model, "BackWall", Vector3.new(54, 12, 1), center + Vector3.new(0, 6, -27), Color3.fromRGB(37, 59, 67), Enum.Material.Slate)
    makePart(model, "LeftWall", Vector3.new(1, 12, 54), center + Vector3.new(-27, 6, 0), Color3.fromRGB(37, 59, 67), Enum.Material.Slate)
    makePart(model, "RightWall", Vector3.new(1, 12, 54), center + Vector3.new(27, 6, 0), Color3.fromRGB(37, 59, 67), Enum.Material.Slate)

    local sign = makePart(model, "OwnerSign", Vector3.new(12, 5, 1), center + Vector3.new(0, 5, -26), Color3.fromRGB(25, 35, 45), Enum.Material.SmoothPlastic)
    local surface = Instance.new("SurfaceGui")
    surface.Face = Enum.NormalId.Front
    surface.Parent = sign
    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.Text = "UNCLAIMED BASE"
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Parent = surface

    local slots = Instance.new("Folder")
    slots.Name = "DisplaySlots"
    slots.Parent = model
    for slot = 1, Config.STARTING_DISPLAY_SLOTS do
        local offset = SLOT_OFFSETS[slot]
        local pad = makePart(slots, "Slot" .. slot, Vector3.new(8, 1, 8), center + offset, Color3.fromRGB(218, 184, 91), Enum.Material.Metal)
        pad:SetAttribute("Slot", slot)
        pad:SetAttribute("PlotId", plotId)
        local prompt = Instance.new("ProximityPrompt")
        prompt.ActionText = "Manage display"
        prompt.ObjectText = "Display slot " .. slot
        prompt.HoldDuration = 0
        prompt.MaxActivationDistance = 10
        prompt.RequiresLineOfSight = false
        prompt.Enabled = false
        prompt.Parent = pad
    end
    return model
end

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
    for plotId = 1, Config.BASE_PLOT_COUNT do
        local existing = plotsFolder:FindFirstChild("Plot" .. plotId)
        if existing and existing:IsA("Model") then
            plotParts[plotId] = existing
        else
            plotParts[plotId] = buildPlot(plotId)
        end
    end
end

function BaseService:Allocate(player: Player): number?
    local existing = assignments[player.UserId]
    if existing then return existing end
    for plotId = 1, Config.BASE_PLOT_COUNT do
        if not occupied[plotId] then
            occupied[plotId] = player.UserId
            assignments[player.UserId] = plotId
            player:SetAttribute("BasePlotId", plotId)
            local model = plotParts[plotId]
            if model then
                local sign = model:FindFirstChild("OwnerSign")
                local surface = sign and sign:FindFirstChildOfClass("SurfaceGui")
                local label = surface and surface:FindFirstChildOfClass("TextLabel")
                if label then label.Text = player.DisplayName .. "'s BASE" end
                local floor = model.PrimaryPart
                if floor then
                    local character = player.Character
                    if character then character:PivotTo(floor.CFrame + Vector3.new(0, 5, 0)) end
                end
            end
            return plotId
        end
    end
    return nil
end

function BaseService:GetPlotId(player: Player): number?
    return assignments[player.UserId]
end

function BaseService:GetPlotModel(player: Player): Model?
    local plotId = assignments[player.UserId]
    return if plotId then plotParts[plotId] else nil
end

function BaseService:IsNearOwnPlot(player: Player, maxDistance: number): boolean
    local model = self:GetPlotModel(player)
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local floor = model and model.PrimaryPart
    if not root or not root:IsA("BasePart") or not floor then return false end
    return (root.Position - floor.Position).Magnitude <= maxDistance
end

function BaseService:Release(player: Player)
    local plotId = assignments[player.UserId]
    if not plotId then return end
    if occupied[plotId] == player.UserId then occupied[plotId] = nil end
    assignments[player.UserId] = nil
    player:SetAttribute("BasePlotId", nil)
    local model = plotParts[plotId]
    local sign = model and model:FindFirstChild("OwnerSign")
    local surface = sign and sign:FindFirstChildOfClass("SurfaceGui")
    local label = surface and surface:FindFirstChildOfClass("TextLabel")
    if label then label.Text = "UNCLAIMED BASE" end
end

function BaseService:Start()
    assert(plotsFolder, "BaseService.Init() must run before Start()")
end

function BaseService:Destroy()
    table.clear(assignments)
    table.clear(occupied)
end

return BaseService
