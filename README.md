# Steal & Collect

A multiplayer Roblox collectible simulator, tycoon, base-defense, and PvP raiding game.

## Development setup

1. Install Roblox Studio and [Rojo](https://rojo.space/).
2. Clone this repository.
3. Run `rojo serve default.project.json` from the repository root.
4. Connect the Rojo Studio plugin and build/test in a private development experience.
5. Enable Studio API Services only in that private development experience when testing persistence.
6. Never use production player data for experiments.

## Repository layout

- `src/ReplicatedStorage`: shared config, definitions, and network response types.
- `src/ServerScriptService`: authoritative server bootstrap, services, and remotes.
- `src/ServerStorage`: server-only assets and templates.
- `src/StarterPlayer`: client bootstrap and controllers.
- `src/Workspace`: authored world content.
- `docs/`: design, architecture, security, data, networking, persistence, and roadmap.

## Implemented foundation

- Profile DataStore loading with a server-session lease, schema reconciliation, autosave, and shutdown save attempts.
- Base plot allocation for up to eight players per server.
- A starter Sprout collectible for newly created profiles, with server-calculated passive income when displayed.
- Server-validated collectible purchase, placement, and removal requests, including ownership, balance, slot, and request-rate checks.

## Known limitations

This is not yet a playable MVP. There is no authored base/world geometry, client UI, marketplace proximity validation, raid gameplay, durable cross-profile transfer journal, automated tests, or CI. Passive income is calculated server-side from collectibles assigned to display slots, but there is not yet a player-facing way to manage those slots. The collectible actions are a server-side foundation, not a complete game loop.

The profile/session implementation is an initial scaffold and has not been verified in Roblox Studio. Test DataStore behavior, shutdowns, session contention, and failure recovery in a private development experience before production. Do not enable item theft or trading until durable transfer recovery is implemented.

See [the roadmap](docs/ROADMAP.md) and [persistence notes](docs/PERSISTENCE.md).
