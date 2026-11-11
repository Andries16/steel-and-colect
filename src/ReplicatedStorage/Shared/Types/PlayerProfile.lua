--!strict

export type CollectibleRecord = {
    instanceId: string,
    definitionId: string,
    acquiredAt: number,
}

export type PlayerProfile = {
    meta: { schemaVersion: number, createdAt: number, lastSeenAt: number },
    economy: { currency: number, lifetimeEarned: number },
    collection: { owned: { CollectibleRecord } },
    base: { level: number, displaySlots: number, placedBySlot: { [number]: string }, defenseLevel: number },
    progression: { tutorialCompleted: boolean, level: number, experience: number },
    security: { lastRaidAt: number?, protectedUntil: number? },
    purchases: { processedPurchaseIds: { string } },
    statistics: { collectiblesCollected: number, successfulRaids: number, failedRaids: number },
}

return {}
