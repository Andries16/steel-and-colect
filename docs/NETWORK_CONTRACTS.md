# Network contracts

## Client → server

- `CollectibleRequest`: collectible purchase, display placement, and display removal.
- `BaseRequest`, `UpgradeRequest`, `RaidRequest`, `QuestRequest`: reserved for future systems; no gameplay handlers are implemented yet.

## Collectible request payloads

All requests use a table with a client-generated `requestId` string.

Purchase:

```lua
{
    requestId = "unique-request-id",
    action = "purchase",
    collectibleId = "sprout",
}
```

Place:

```lua
{
    requestId = "unique-request-id",
    action = "place",
    instanceId = "owned-instance-guid",
    slot = 1,
}
```

Unplace:

```lua
{
    requestId = "unique-request-id",
    action = "unplace",
    slot = 1,
}
```

The server derives prices and collectible definitions from shared server-loaded definitions. It checks profile readiness, request rate, ownership, currency, display-slot bounds, duplicate placement, and slot occupancy. The client must never submit a price, income amount, ownership flag, or success result.

## Server → client

- `CollectibleRequest`: response envelope for the request.
- `InventoryUpdated`: current owned collectible records.
- `StateUpdated`, `EconomyUpdated`, `RaidUpdated`, `Notification`, `InteractionPrompt`: reserved for future systems.

## Response envelope

Every handled request receives `requestId`, `success`, `code`, `message`, and optional `data`. The shared Response module defines the shape.

## Validation and remaining work

Validate payload type/size/shape/enums; rate-limit per player; reject unknown actions and stale/replayed IDs where appropriate. Derive price, reward, rarity, ownership, target eligibility, distance, and raid result on the server. Validate character state, proximity, plot ownership, cooldowns, and current server state. A client boolean such as `raidSucceeded` is never proof of success.

The current collectible purchase handler does not yet validate physical marketplace proximity because marketplace geometry has not been implemented. Add server-side proximity checks before exposing purchase requests in a public game. Request-ID replay caching is also still pending.
