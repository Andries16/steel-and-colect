--!strict

local GameConfig = {
    MAX_PLAYERS = 8,
    BASE_PLOT_COUNT = 8,
    STARTING_CURRENCY = 0,
    STARTING_DISPLAY_SLOTS = 5,
    OFFLINE_INCOME_CAP_SECONDS = 4 * 60 * 60,
    RAID = {
        DURATION_SECONDS = 90,
        PREPARATION_SECONDS = 10,
        TARGET_SHIELD_SECONDS = 5 * 60,
        ATTACKER_COOLDOWN_SECONDS = 3 * 60,
        NEW_PLAYER_PROTECTION_SECONDS = 15 * 60,
        MAX_STOLEN_COLLECTIBLES = 1,
    },
}

return table.freeze(GameConfig)
