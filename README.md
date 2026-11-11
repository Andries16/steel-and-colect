# Steal & Collect

A multiplayer Roblox collectible simulator, tycoon, base-defense, and PvP raiding game.

## Development setup

1. Install Roblox Studio and [Rojo](https://rojo.space/).
2. Clone this repository.
3. Run `rojo serve default.project.json` from the repository root.
4. Connect the Rojo Studio plugin and build/test in a private development experience.
5. Never use production player data for experiments.

## Repository layout

- `src/ReplicatedStorage`: shared config, definitions, and network response types.
- `src/ServerScriptService`: authoritative server bootstrap, services, and remotes.
- `src/ServerStorage`: server-only assets and templates.
- `src/StarterPlayer`: client bootstrap and controllers.
- `src/Workspace`: authored world content.
- `docs/`: design, architecture, security, data, networking, and roadmap.

## Status

This is the initial foundation scaffold. It is not yet a playable MVP. Persistence, economy, inventory, bases, raids, UI, validation, tests, and CI remain incomplete. In particular, do not treat the initial profile scaffold as production-safe or enable item theft/trading before durable transfer recovery is implemented.

See [the roadmap](docs/ROADMAP.md) for the current development sequence.
