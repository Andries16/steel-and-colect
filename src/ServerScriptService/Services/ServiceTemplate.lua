--!strict

-- Service contract: Init wires dependencies, Start begins runtime work, Destroy cleans up.
local Service = {}
function Service:Init() end
function Service:Start() end
function Service:Destroy() end
return Service
