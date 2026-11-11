--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteRegistry = {}
local folder: Folder?

local remoteNames = {
    "CollectibleRequest", "BaseRequest", "UpgradeRequest", "RaidRequest", "QuestRequest",
    "StateUpdated", "InventoryUpdated", "EconomyUpdated", "RaidUpdated", "Notification", "InteractionPrompt",
}

function RemoteRegistry.Init()
    local existing = ReplicatedStorage:FindFirstChild("Remotes")
    if existing then
        assert(existing:IsA("Folder"), "ReplicatedStorage.Remotes must be a Folder")
        folder = existing
    else
        local created = Instance.new("Folder")
        created.Name = "Remotes"
        created.Parent = ReplicatedStorage
        folder = created
    end
    for _, name in ipairs(remoteNames) do
        local remote = folder:FindFirstChild(name)
        if not remote then
            remote = Instance.new("RemoteEvent")
            remote.Name = name
            remote.Parent = folder
        end
        assert(remote:IsA("RemoteEvent"), name .. " must be a RemoteEvent")
    end
end

function RemoteRegistry.Get(name: string): RemoteEvent
    local currentFolder = folder
    assert(currentFolder, "RemoteRegistry.Init() must run first")
    local remote = currentFolder:FindFirstChild(name)
    assert(remote and remote:IsA("RemoteEvent"), "Unknown remote: " .. name)
    return remote
end

return table.freeze(RemoteRegistry)
