# Player data schema

Schema version 1 is an initial contract, not a migration-complete production format.

- meta: schemaVersion, createdAt, lastSeenAt
- economy: currency, lifetimeEarned
- collection: owned collectible records with unique instanceId and definitionId
- base: level, displaySlots, placedBySlot, defenseLevel
- progression: tutorialCompleted, level, experience
- security: raid timestamps and protection windows
- purchases: bounded recent receipt IDs or preferably a dedicated durable receipt ledger
- statistics: collection and raid counters

## Invariants
1. Currency is a non-negative integer; all mutations are server-authoritative.
2. Every collectible has a unique instance ID and exactly one owner/location.
3. A placed collectible must exist in the owner's collection.
4. Slot indices must be within unlocked slots.
5. Every load validates schema version and applies explicit migrations.
6. Receipt processing and transfers are idempotent.
7. Never keep an unbounded receipt-ID list in a profile; use a dedicated durable ledger.

Do not rename/remove persisted fields without a versioned migration.
