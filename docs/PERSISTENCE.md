# Player persistence

## Current implementation

- Profiles are stored in the `PlayerProfiles_v1` DataStore.
- Each profile is wrapped in a session lease containing the owning server ID and expiry.
- A server may load a profile only when no lease exists, the lease expired, or the lease belongs to that same server.
- Autosave and lease renewal are attempted every 90 seconds; the lease duration is 180 seconds.
- A player is removed from the server if their profile cannot be loaded safely. The game must never silently create a fresh profile after a load failure.
- Profile schema reconciliation currently targets schema version 1.

## Important limitations

This is an initial single-key profile/session-lock implementation, not a fully battle-tested persistence library. It needs Studio integration tests, simulated DataStore failures, server shutdown tests, and concurrency tests before production use. The current save operation writes the in-memory profile snapshot and must not be treated as a cross-key transaction mechanism.

Item transfers, raids that move ownership, and trading remain disabled until a durable transaction journal with recovery/reconciliation is implemented. Do not enable those systems based only on profile session locking.

For Studio testing, publish a private development experience and enable API Services only for that development experience. Never test against production DataStore names.
