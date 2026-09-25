local GameConfig = {
    StartingCredits = 600,
    StartingLevel = 1,
    StartingGlitch = 0,

    Glitch = {
        Max = 100,
        WarningThreshold = 70,
        CriticalThreshold = 90,
        RaidIncrease = 4,
        PassiveDecay = 1,
    },

    Rewards = {
        NyxRaid = {
            Credits = 350,
            Experience = 100,
            FirstClearBonus = 250,
        },
    },

    Weapons = {
        StartingWeapon = "Rasetsu",
        FreeUnlocks = {
            "Rasetsu",
        },
    },
}

return GameConfig
