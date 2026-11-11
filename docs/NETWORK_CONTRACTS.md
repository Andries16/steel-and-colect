# Network contracts

## Client → server
CollectibleRequest, BaseRequest, UpgradeRequest, RaidRequest, QuestRequest.

## Server → client
StateUpdated, InventoryUpdated, EconomyUpdated, RaidUpdated, Notification, InteractionPrompt.

## Response envelope
Every request should receive requestId, success, code, message, and optional data. The shared Response module defines the initial shape.

## Validation
Validate payload type/size/shape/enums; rate-limit per player; reject unknown actions and stale/replayed IDs where appropriate. Derive price, reward, rarity, ownership, target eligibility, distance, and raid result on the server. Validate character state, proximity, plot ownership, cooldowns, and current server state. A client boolean such as raidSucceeded is never proof of success.
