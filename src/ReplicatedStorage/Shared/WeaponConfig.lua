local WeaponConfig = {
    Rasetsu = {
        Id = "Rasetsu",
        DisplayName = "RASETSU",
        Description = "A segmented blade built for close-range pressure.",
        Rarity = "Rare",
        Damage = 25,
        AttackCooldown = 0.42,
        Range = 8,
        ComboCount = 3,
        Color = Color3.fromRGB(220, 65, 255),
        Abilities = {
            "Slash",
            "Dash Slash",
            "Rasetsu Break",
        },
    },

    AeterTwins = {
        Id = "AeterTwins",
        DisplayName = "AETER TWINS",
        Description = "Twin pistols that fire condensed glitch energy.",
        Rarity = "Epic",
        Damage = 18,
        AttackCooldown = 0.28,
        Range = 70,
        ComboCount = 2,
        Color = Color3.fromRGB(60, 210, 255),
        Abilities = {
            "Twin Shot",
            "Backstep",
            "Aeter Barrage",
        },
    },

    Mugen = {
        Id = "Mugen",
        DisplayName = "MUGEN",
        Description = "Floating cubes that distort space around the wielder.",
        Rarity = "Legendary",
        Damage = 32,
        AttackCooldown = 0.75,
        Range = 18,
        ComboCount = 1,
        Color = Color3.fromRGB(255, 185, 45),
        Abilities = {
            "Pulse",
            "Barrier",
            "Mugen Collapse",
        },
    },
}

return WeaponConfig
