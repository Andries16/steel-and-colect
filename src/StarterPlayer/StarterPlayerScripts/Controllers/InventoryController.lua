--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local CollectibleRequest = Remotes:WaitForChild("CollectibleRequest") :: RemoteEvent
local InventoryUpdated = Remotes:WaitForChild("InventoryUpdated") :: RemoteEvent
local StateUpdated = Remotes:WaitForChild("StateUpdated") :: RemoteEvent
local EconomyUpdated = Remotes:WaitForChild("EconomyUpdated") :: RemoteEvent
local Definitions = require(ReplicatedStorage.Shared.Definitions.Collectibles)

local InventoryController = {}
local owned: { any } = {}
local placedBySlot: { [number]: string } = {}
local displaySlots = 5
local inventoryList: ScrollingFrame?
local slotsList: Frame?
local statusLabel: TextLabel?
local currencyLabel: TextLabel?

local function send(action: string, payload: { [string]: any })
    payload.requestId = HttpService:GenerateGUID(false)
    payload.action = action
    CollectibleRequest:FireServer(payload)
end

local function createText(parent: Instance, name: string, text: string, size: UDim2, position: UDim2): TextLabel
    local label = Instance.new("TextLabel")
    label.Name = name
    label.Size = size
    label.Position = position
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(245, 245, 245)
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = parent
    return label
end

local function createButton(parent: Instance, name: string, text: string, callback: () -> ()): TextButton
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(1, -8, 0, 34)
    button.BackgroundColor3 = Color3.fromRGB(57, 91, 112)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Text = text
    button.Font = Enum.Font.GothamBold
    button.TextSize = 13
    button.AutoButtonColor = true
    button.Parent = parent
    button.Activated:Connect(callback)
    return button
end

local function render()
    local list = inventoryList
    local slots = slotsList
    if not list or not slots then return end
    for _, child in ipairs(list:GetChildren()) do
        if child:IsA("GuiObject") then child:Destroy() end
    end
    for _, child in ipairs(slots:GetChildren()) do
        if child:IsA("GuiObject") then child:Destroy() end
    end

    local y = 0
    for _, item in ipairs(owned) do
        local definition = Definitions[item.definitionId]
        local displayName = if definition then definition.displayName else item.definitionId
        local alreadyPlaced = false
        for _, instanceId in pairs(placedBySlot) do
            if instanceId == item.instanceId then alreadyPlaced = true break end
        end
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -8, 0, 40)
        row.Position = UDim2.fromOffset(0, y)
        row.BackgroundTransparency = 1
        row.Parent = list
        local label = createText(row, "ItemName", displayName, UDim2.new(0.58, 0, 1, 0), UDim2.fromOffset(4, 0))
        label.TextTruncate = Enum.TextTruncate.AtEnd
        if not alreadyPlaced then
            local button = createButton(row, "Place", "Place", function()
                for slot = 1, displaySlots do
                    if not placedBySlot[slot] then
                        send("place", { instanceId = item.instanceId, slot = slot })
                        return
                    end
                end
                if statusLabel then statusLabel.Text = "All display slots are occupied." end
            end)
            button.Size = UDim2.fromOffset(76, 30)
            button.Position = UDim2.new(1, -80, 0, 5)
        else
            createText(row, "Placed", "Displayed", UDim2.fromOffset(76, 30), UDim2.new(1, -80, 0, 5))
        end
        y += 42
    end
    list.CanvasSize = UDim2.fromOffset(0, y)

    for slot = 1, displaySlots do
        local instanceId = placedBySlot[slot]
        local displayName = "Empty"
        if instanceId then
            for _, item in ipairs(owned) do
                if item.instanceId == instanceId then
                    local definition = Definitions[item.definitionId]
                    displayName = if definition then definition.displayName else item.definitionId
                    break
                end
            end
        end
        local button = createButton(slots, "Slot" .. slot, "Slot " .. slot .. ": " .. displayName .. (if instanceId then "  •  Remove" else ""), function()
            if instanceId then
                send("unplace", { slot = slot })
            end
        end)
        button.Position = UDim2.fromOffset(0, (slot - 1) * 36)
        button.Size = UDim2.new(1, -8, 0, 32)
        button.BackgroundColor3 = if instanceId then Color3.fromRGB(112, 79, 56) else Color3.fromRGB(52, 76, 65)
        button.Active = instanceId ~= nil
        button.AutoButtonColor = instanceId ~= nil
    end
end

function InventoryController:Init()
    local playerGui = player:WaitForChild("PlayerGui")
    local screen = Instance.new("ScreenGui")
    screen.Name = "StealCollectHUD"
    screen.ResetOnSpawn = false
    screen.IgnoreGuiInset = false
    screen.Parent = playerGui

    local panel = Instance.new("Frame")
    panel.Name = "InventoryPanel"
    panel.Size = UDim2.fromOffset(300, 360)
    panel.Position = UDim2.new(1, -316, 0, 20)
    panel.BackgroundColor3 = Color3.fromRGB(26, 34, 43)
    panel.BackgroundTransparency = 0.08
    panel.Parent = screen

    createText(panel, "Title", "COLLECTION", UDim2.new(1, -20, 0, 28), UDim2.fromOffset(12, 8)).Font = Enum.Font.GothamBold
    currencyLabel = createText(panel, "Currency", "Coins: " .. tostring(player:GetAttribute("Currency") or 0), UDim2.new(1, -20, 0, 22), UDim2.fromOffset(12, 36))
    createText(panel, "OwnedTitle", "Owned collectibles", UDim2.new(1, -20, 0, 20), UDim2.fromOffset(12, 62))
    local list = Instance.new("ScrollingFrame")
    list.Name = "OwnedList"
    list.Size = UDim2.new(1, -24, 0, 118)
    list.Position = UDim2.fromOffset(12, 84)
    list.BackgroundColor3 = Color3.fromRGB(35, 45, 56)
    list.BorderSizePixel = 0
    list.ScrollBarThickness = 5
    list.Parent = panel
    inventoryList = list

    createText(panel, "SlotsTitle", "Base display slots", UDim2.new(1, -20, 0, 20), UDim2.fromOffset(12, 210))
    local slotFrame = Instance.new("Frame")
    slotFrame.Name = "DisplaySlots"
    slotFrame.Size = UDim2.new(1, -24, 0, 148)
    slotFrame.Position = UDim2.fromOffset(12, 232)
    slotFrame.BackgroundTransparency = 1
    slotFrame.Parent = panel
    slotsList = slotFrame
    statusLabel = createText(panel, "Status", "Buy collectibles at the central marketplace.", UDim2.new(1, -20, 0, 18), UDim2.fromOffset(12, 338))
    statusLabel.TextSize = 11
    render()

    InventoryUpdated.OnClientEvent:Connect(function(items)
        if type(items) == "table" then owned = items render() end
    end)
    StateUpdated.OnClientEvent:Connect(function(state)
        if type(state) == "table" then
            if type(state.placedBySlot) == "table" then placedBySlot = state.placedBySlot end
            if type(state.displaySlots) == "number" then displaySlots = math.clamp(state.displaySlots, 1, 9) end
            render()
        end
    end)
    EconomyUpdated.OnClientEvent:Connect(function(state)
        if type(state) == "table" and type(state.currency) == "number" and currencyLabel then
            currencyLabel.Text = "Coins: " .. tostring(math.floor(state.currency))
        end
    end)
    CollectibleRequest.OnClientEvent:Connect(function(response)
        if type(response) == "table" and response.success == false and statusLabel then
            statusLabel.Text = tostring(response.message or "Request failed.")
        elseif type(response) == "table" and response.success == true and statusLabel then
            statusLabel.Text = if response.data and response.data.action == "synced" then "Collection synchronized." else "Display updated."
        end
    end)
    send("sync", {})
end

return InventoryController
