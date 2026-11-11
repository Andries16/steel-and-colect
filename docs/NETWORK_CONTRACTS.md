# Network contracts

## Client → server

- `CollectibleRequest`: initial state synchronization, collectible purchase, display placement, and display removal.
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

Initial state sync:

```lua
{
    requestId = "unique-request-id",
    action = "sync",
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

The starter HUD requests an initial state snapshot after connecting its listeners. The server returns owned items and occupied display slots. The server derives prices and collectible definitions from shared server-loaded definitions. It checks profile readiness, request rate, ownership, currency, display-slot bounds, duplicate placement, and slot occupancy. The client must never submit a price, income amount, ownership flag, or success result.

## Server → client

- `CollectibleRequest`: response envelope for the request.
- `InventoryUpdated`: current owned collectible records.
- `StateUpdated`, `EconomyUpdated`, `RaidUpdated`, `Notification`, `InteractionPrompt`: reserved for future systems.

## Response envelope

Every handled request receives `requestId`, `success`, `code`, `message`, and optional `data`. The shared Response module defines the shape.

## Validation and remaining work

Validate payload type/size/shape/enums; rate-limit per player; reject unknown actions and stale/replayed IDs where appropriate. Derive price, reward, rarity, ownership, target eligibility, distance, and raid result on the server. Validate character state, proximity, plot ownership, cooldowns, and current server state. A client boolean such as `raidSucceeded` is never proof of success.

Marketplace purchases through the ProximityPrompt or request remote now require the player character to be within 18 studs of the matching server-generated marketplace stand. Placement and removal require the player to be within 75 studs of their assigned plot. The marketplace ProximityPrompt invokes the same server-side purchase path. Request-ID replay caching is still pending; prompts are a functional blockout rather than final UI.
