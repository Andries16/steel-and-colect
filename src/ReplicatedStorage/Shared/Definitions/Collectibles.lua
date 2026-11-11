--!strict

export type CollectibleDefinition = {
    displayName: string,
    rarity: string,
    baseIncomePerSecond: number,
    acquisitionPrice: number,
}

-- Initial balancing values are placeholders and must be playtested.
local definitions: { [string]: CollectibleDefinition } = {
    sprout = { displayName = "Sprout", rarity = "Common", baseIncomePerSecond = 1, acquisitionPrice = 25 },
    pebble = { displayName = "Pebble", rarity = "Common", baseIncomePerSecond = 2, acquisitionPrice = 60 },
    firefly = { displayName = "Firefly", rarity = "Uncommon", baseIncomePerSecond = 5, acquisitionPrice = 150 },
    cloud_fox = { displayName = "Cloud Fox", rarity = "Uncommon", baseIncomePerSecond = 8, acquisitionPrice = 300 },
    coral_cat = { displayName = "Coral Cat", rarity = "Rare", baseIncomePerSecond = 15, acquisitionPrice = 750 },
    moon_moth = { displayName = "Moon Moth", rarity = "Rare", baseIncomePerSecond = 22, acquisitionPrice = 1200 },
    crystal_turtle = { displayName = "Crystal Turtle", rarity = "Epic", baseIncomePerSecond = 45, acquisitionPrice = 3000 },
    storm_owl = { displayName = "Storm Owl", rarity = "Epic", baseIncomePerSecond = 70, acquisitionPrice = 5000 },
    solar_dragon = { displayName = "Solar Dragon", rarity = "Legendary", baseIncomePerSecond = 150, acquisitionPrice = 12000 },
    void_whale = { displayName = "Void Whale", rarity = "Mythic", baseIncomePerSecond = 400, acquisitionPrice = 40000 },
}

return table.freeze(definitions)
