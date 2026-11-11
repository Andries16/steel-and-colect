# Development roadmap

## Milestone 1 — Foundation
- [x] Initialize repository and Rojo project mapping.
- [x] Add shared configuration, initial collectible definitions, and response type.
- [x] Add deterministic server/client entry points and remote/service scaffolds.
- [ ] Validate Rojo build in Roblox Studio.
- [ ] Add automated formatting, linting, and CI.

## Milestone 2 — Player data and world
- [ ] Harden profile lifecycle, session locking, migrations, autosave, and shutdown.
- [ ] Build eight base plots and deterministic assignment/release.
- [ ] Implement inventory invariants and collectible marketplace.

## Milestone 3 — Core loop
- [ ] Implement acquisition, placement, passive income, upgrades, tutorial, and UI.
- [ ] Add server validation, rate limits, and economy audit events.
- [ ] Add unit and integration tests.

## Milestone 4 — Raids
- [ ] Implement raid eligibility and state machine.
- [ ] Implement durable transfer journal/recovery before enabling theft.
- [ ] Add multiplayer, disconnect, concurrency, and exploit tests.

## Milestone 5 — Launch
- [ ] Add quests, progression, analytics, and compliant monetization.
- [ ] Test PC, mobile, and console input/UI.
- [ ] Profile performance and complete release checklist.

## Next engineering slice
1. Build the Rojo project in Studio and fix mapping issues.
2. Review/rework persistence and session locking before depending on it.
3. Implement BaseService plot allocation.
4. Implement server-authoritative acquisition and inventory mutations.
5. Add tests and CI before expanding gameplay scope.
