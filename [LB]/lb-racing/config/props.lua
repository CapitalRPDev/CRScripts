---@class PropParticle
---@field ptfx string
---@field effectName string
---@field offset? vector3
---@field rotation? vector3
---@field scale? number
---@field color? { r: number, g: number, b: number }

---@class Prop
---@field name string
---@field model string | number
---@field headingOffset? number
---@field particle? PropParticle

---@type { Checkpoint: Prop[], Barrier: Prop[] }
Config.Props = {}

Config.Props.Checkpoint = {
    {
        name = "Black Flag",
        model = `prop_beachflag_01`,
        headingOffset = 45.0,
        image = "./assets/img/props/prop_beachflag_01.webp"
    },
    {
        name = "Tyres",
        model = `prop_offroad_tyres02`,
        image = "./assets/img/props/prop_offroad_tyres02.webp"
    },
    {
        name = "Barrel",
        model = `prop_offroad_barrel01`,
        image = "./assets/img/props/prop_offroad_barrel01.webp"
    },
    {
        name = "Flare",
        model = `prop_flare_01`,
        particle = {
            -- ptfx = "core",
            -- effectName = "exp_grd_flare",
            ptfx = "scr_ba_bb",
            effectName = "scr_ba_bb_package_flare",
            offset = vector3(0.0, 0.0, 0.08),
            color = { r = 55, g = 125, b = 255 }
        }
    }
}

Config.Props.Barrier = {
    {
        name = "Tyres (stacked)",
        model = `prop_offroad_tyres01_tu`,
        image = "./assets/img/props/prop_offroad_tyres01_tu.webp"
    },
    {
        name = "Tyres (sideways)",
        model = `prop_offroad_tyres01`,
        image = "./assets/img/props/prop_offroad_tyres01.webp"
    },
    {
        name = "Barrels",
        model = `prop_offroad_barrel02`,
        image = "./assets/img/props/prop_offroad_barrel02.webp"
    },
    {
        name = "Bale",
        model = `prop_offroad_bale01`,
        image = "./assets/img/props/prop_offroad_bale01.webp"
    },
    -- {
    --     name = "Flare",
    --     model = `prop_flare_01`,
    --     particle = {
    --         -- ptfx = "core",
    --         -- effectName = "exp_grd_flare",
    --         ptfx = "scr_ba_bb",
    --         effectName = "scr_ba_bb_package_flare",
    --         offset = vector3(0.0, 0.0, 0.08),
    --         color = { r = 55, g = 125, b = 255 }
    --     }
    -- }
}
