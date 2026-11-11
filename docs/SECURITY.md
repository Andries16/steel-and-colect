# Security requirements

Treat every client request as untrusted. The server owns currency, inventory, IDs, placement, progression, purchase grants, and raid outcomes.

- Validate payload type, size, shape, enums, and state transitions.
- Rate-limit every action per player.
- Derive prices/rewards/rarity/ownership/target eligibility/distance/results on the server.
- Validate character state, proximity, plot ownership, cooldowns, and current server state.
- Use unique collectible IDs and idempotent mutations/transfers.
- Verify MarketplaceService receipts server-side and process idempotently.
- Use safe session locking; fail closed when profile loading fails.
- Test forged prices, negative/overflow amounts, duplicate/replayed requests, receipt replay, spoofed targets, proximity bypass, concurrent raids, disconnects during transfers, and DataStore failures.
- Keep telemetry bounded and privacy-conscious; do not punish based on one noisy signal.
- Do not enable trading/cross-server transfers until journal/reconciliation is proven.
