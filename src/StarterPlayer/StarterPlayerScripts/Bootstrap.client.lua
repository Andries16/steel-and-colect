--!strict

local controllersFolder = script.Parent:WaitForChild("Controllers")
local controllerNames = {
    "NotificationController", "InputController", "InteractionController",
    "InventoryController", "BaseController", "RaidController", "UIController",
}

for _, name in ipairs(controllerNames) do
    local module = controllersFolder:FindFirstChild(name)
    if module then
        local controller = require(module)
        if type(controller.Init) == "function" then controller:Init() end
    end
end
