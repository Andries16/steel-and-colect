# Steal & Collect — Game Design

## Product
A multiplayer collectible simulator combining collection, passive-income tycoon progression, base customization/defense, and opt-in PvP raids. Target platforms: PC, mobile, and console.

## MVP
- One world with central plaza, marketplace, upgrade center, base zone, and raid gate.
- Eight players and eight personal base plots per server.
- Ten collectible definitions, five initial display slots, inventory, placement, and passive income.
- Base/defense upgrades, tutorial, persistence, and basic analytics.
- Same-server raids with explicit eligibility, preparation, duration, cooldown, and protection rules.

## Core loop
Acquire collectibles → place them in the base → earn passive currency → upgrade the base and defenses → raid eligible rivals → expand the collection.

## Initial raid tuning values
90-second duration; 10-second preparation warning; five-minute target shield; three-minute attacker cooldown; maximum one stolen collectible per raid; first 15 minutes protected for new players. These are playtest starting points, not final balance. Offline income is capped at four hours.

Trading stays disabled until durable transaction/recovery infrastructure has passed failure testing. Monetization should favor cosmetics/convenience and avoid pay-to-win or guaranteed raid success.

## MVP acceptance
A new player can complete the tutorial, acquire and place a collectible, earn/spend currency, upgrade a base, rejoin without losing progress, and complete a valid raid without item duplication/loss under tested failure scenarios.
