# Architecture

## Runtime boundaries
- ReplicatedStorage: shared immutable definitions, types, configuration, and remote interfaces. No secrets or authoritative mutable state.
- ServerScriptService: authoritative services, persistence, security, and bootstrap.
- ServerStorage: server-only templates/assets.
- StarterPlayerScripts: client controllers and presentation/input.
- Workspace: authored map geometry and spawn/interaction locations.

## Lifecycle
Services expose optional Init, Start, Destroy. Bootstrap uses explicit dependency order; never use pairs() for startup ordering. Init wires dependencies, Start connects runtime events, Destroy is idempotent.

## Planned service ownership
ProfileService (profile lifecycle); PlayerService (join/leave); EconomyService (currency); InventoryService (ownership); CollectibleService (acquisition); BaseService (plots/placement); IncomeService; RaidService (raid state machine); TransferService (durable item movement); ProgressionService; QuestService; PurchaseService; AnalyticsService.

## Persistence and transfer safety
DataStoreService persists profiles. MemoryStoreService may coordinate temporary cross-server locks; MessagingService is for notifications, not authoritative state. Roblox DataStore does not provide atomic transactions across two player keys. Cross-player theft/trading requires a durable transaction journal/coordinator, idempotent phases, join-time reconciliation, and failure-injection tests. Do not enable trading or claim atomic theft before that exists.

All current runtime files are scaffolding, not a production-ready implementation. Profile locking, migration, lease renewal, conflict handling, deep snapshots, autosave budgets, and shutdown behavior still need design and tests.
