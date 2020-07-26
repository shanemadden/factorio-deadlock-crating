-- globals container
local DCM = {}

-- print to log for non-errors?
DCM.LOGGING = false

-- default tier 1 belt speed in items/s. we assume other belt tiers are a multiple of this. if not, you'll have to tweak the machine yourself
DCM.BELT_SPEED = 15

-- size of machine icons and crate background
DCM.ITEM_ICON_SIZE = 64

-- size of vanilla's item icons
DCM.VANILLA_ICON_SIZE = 32

-- how many crates to use up a whole vanilla stack
DCM.STACK_DIVIDER = 5

-- how many tiers of tech?
DCM.TIERS = 3

-- which vanilla items are automatically crated, in which tier
DCM.VANILLA_ITEM_TIERS = {
    [1] = { "wood", "iron-ore", "copper-ore", "stone", "coal", "iron-plate", "copper-plate", "steel-plate", "stone-brick" },
    [2] = { "copper-cable", "iron-gear-wheel", "iron-stick", "sulfur", "plastic-bar", "solid-fuel", "electronic-circuit", "advanced-circuit" },
    [3] = { "processing-unit", "battery", "uranium-ore", "uranium-235", "uranium-238" },
}

-- machine colours
DCM.TIER_COLOURS = {
    [1] = {r=210, g=180, b=80},
    [2] = {r=210, g=60, b=60},
    [3] = {r=80, g=180, b=210},
}
DCM.DEFAULT_COLOUR = {r=1.0,g=0.75,b=0.75}

-- item/recipe/entity prefixes
DCM.CRATE_ITEM_PREFIX = "deadlock-crate-"
DCM.CRATE_PACK_RECIPE_PREFIX = "deadlock-packrecipe-"
DCM.CRATE_UNPACK_RECIPE_PREFIX = "deadlock-unpackrecipe-"
DCM.MACHINE_PREFIX = "deadlock-crating-machine-"
DCM.TECH_PREFIX = "deadlock-crating-"

-- research prerequisites per tier
DCM.TECH_PREREQUISITES = {
    [1] = {"automation", "electric-engine", "stack-inserter"},
    [2] = {"automation-2", "deadlock-crating-1"},
    [3] = {"automation-3", "deadlock-crating-2"},
}

-- copy and multiply research cost per tier from these vanilla techs
DCM.TECH_BASE = {
    [1] = "stack-inserter",
    [2] = "inserter-capacity-bonus-3",
    [3] = "inserter-capacity-bonus-5",
}

-- debug logging
function DCM.debug(message)
    if DCM.LOGGING then log(message) end
end

-- generate items and recipes for crated items
DCM.CRATE_ORDER = 0
function DCM.generate_crates(this_item, icon_size)
    if icon_size then
        if (icon_size ~= 32 and icon_size ~= 64 and icon_size ~= 128) then
            log("ERROR: DCM asked to use icon_size that is not 32, 64 or 128")
            return
        end
    else icon_size = DCM.ITEM_ICON_SIZE end
    -- The crated item
    local base_item = data.raw.item[this_item]
    if not base_item then
        log("ERROR: DCM asked to crate an item that doesn't exist ("..this_item..")")
        return
    end
    local items_per_crate = base_item.stack_size/DCM.STACK_DIVIDER
    -- stop stack multiplier mods from breaking everything
    if items_per_crate > 65535 then
        log("ABORT: DCM encountered a recipe with insane stack size ("..this_item..")")
        return
    end
    local icons = {
        {
            icon = "__DeadlockCrating__/graphics/icons/mipmaps/crate.png",
            icon_size = DCM.ITEM_ICON_SIZE,
            icon_mipmaps = 4,
            scale = 1, -- Force the base layer to be the reference scale
        }
    }
    -- Icons has priority over icon, check for icons definition first
    if base_item.icons then
        for _,icon in pairs(base_item.icons) do
            local temp_icon = table.deepcopy(icon)
            temp_icon.scale = 0.7 * (temp_icon.scale or 1)
            if not temp_icon.icon_size then temp_icon.icon_size = base_item.icon_size end
            table.insert(icons, temp_icon)
        end
    -- If no icons field, look for icon definition
    elseif base_item.icon then
            -- table.insert(icons, {
                -- icon = base_item.icon,
                -- scale = 0.7 * 32 / base_item.icon_size,
                -- icon_size = base_item.icon_size,
                -- icon_mipmaps = base_item.icon_mipmaps,
                -- tint = {0,0,0,0.75},
                -- shift = {2, 2},
            -- })
            table.insert(icons, {
                icon = base_item.icon,
                scale = 0.7 * 64 / base_item.icon_size, -- Base layer is 64 pixels, need to ensure scaling of the crated item is correct for its size
                icon_size = base_item.icon_size,
                icon_mipmaps = base_item.icon_mipmaps,
            })
    else
        log("ERROR: DCM asked to crate an item with no icon or icons properties ("..this_item..")")
        return
    end
    local packrecipeicons = table.deepcopy(icons)
    local unpackrecipeicons = table.deepcopy(icons)
    table.insert(packrecipeicons, { icon = "__DeadlockCrating__/graphics/icons/square/arrow-d-64.png", scale = 0.5, icon_size = 64, shift = {0, 8} } ) -- These should be inserted at the top of the stack, not beneath the rescaled item
    table.insert(unpackrecipeicons, { icon = "__DeadlockCrating__/graphics/icons/square/arrow-u-64.png", scale = 0.5, icon_size = 64, shift = {0, -8} } ) -- These should be inserted at the top of the stack, not beneath the rescaled item
    -- the item
    data:extend {
        -- the item
        {
            type = "item",
            name = DCM.CRATE_ITEM_PREFIX .. this_item,
            localised_name = {"item-name.deadlock-crate-item", items_per_crate, {"item-name." .. this_item}},
            stack_size = DCM.STACK_DIVIDER,
            order = string.format("%03d",DCM.CRATE_ORDER),
            subgroup = "deadlock-crates-pack",
            allow_decomposition = false,
            icons = icons,
            flags = {},
        },
        -- The packing recipe
        {
            type = "recipe",
            name = DCM.CRATE_PACK_RECIPE_PREFIX .. this_item,
            localised_name = {"recipe-name.deadlock-packing-recipe", {"item-name." .. this_item}},
            order = string.format("%03d",DCM.CRATE_ORDER),
            category = "packing",
            subgroup = "deadlock-crates-pack",
            enabled = false,
            ingredients = {
                {"wooden-chest", 1},
                {this_item, items_per_crate},
            },
            icons = packrecipeicons,
            result = DCM.CRATE_ITEM_PREFIX .. this_item,
            energy_required = items_per_crate/DCM.BELT_SPEED,
            allow_decomposition = false,
            allow_intermediates = false,
            allow_as_intermediate = false,
            hide_from_stats = true,
        },
        -- The unpacking recipe
        {
            type = "recipe",
            name = DCM.CRATE_UNPACK_RECIPE_PREFIX .. this_item,
            localised_name = {"recipe-name.deadlock-unpacking-recipe", {"item-name." .. this_item}},
            order = string.format("%03d",DCM.CRATE_ORDER),
            category = "packing",
            subgroup = "deadlock-crates-unpack",
            enabled = false,
            ingredients = {
                {DCM.CRATE_ITEM_PREFIX .. this_item, 1},
            },
            icons = unpackrecipeicons,
            results = {
                {"wooden-chest", 1},
                {this_item, items_per_crate},
            },
            energy_required = items_per_crate/DCM.BELT_SPEED,
            allow_decomposition = false,
            allow_intermediates = false,
            allow_as_intermediate = false,
            hide_from_stats = true,
        },
    }
    DCM.debug("DCM: crates created: "..this_item)
    DCM.CRATE_ORDER = DCM.CRATE_ORDER + 1
end

-- add recipe unlocks to a specified technology
function DCM.add_crates_to_tech(item_name, target_technology)
    if not target_technology then
        DCM.debug("DCM: Skipping technology insert, no tech specified ("..item_name..")")
        return
    end
    if not data.raw.recipe["deadlock-unpackrecipe-"..item_name] then
        log("ERROR: DCM asked to use non-existent uncrating recipe for tech ("..target_technology..")")
        return
    end
    if not data.raw.recipe["deadlock-packrecipe-"..item_name] then
        log("ERROR: DCM asked to use non-existent crating recipe for tech ("..target_technology..")")
        return
    end
    if not data.raw.technology[target_technology] then
        log("ERROR: DCM asked to use non-existent technology ("..target_technology..")")
        return
    end
    -- request by orzelek - remove previous recipe unlocks if we're re-adding something that was changed by another mod
    for i,effect in ipairs(data.raw.technology[target_technology].effects) do
        if effect.recipe and (effect.recipe == "deadlock-packrecipe-"..item_name or effect.recipe == "deadlock-unpackrecipe-"..item_name) then
            table.remove(data.raw.technology[target_technology].effects, i)
            DCM.debug("DCM: Removed previous recipe unlock ("..item_name..")")
            break
        end
    end
    -- crating recipe
    table.insert(data.raw.technology[target_technology].effects,
        {
            type = "unlock-recipe",
            recipe = "deadlock-packrecipe-"..item_name,
        }
    )
    -- uncrating recipe
    table.insert(data.raw.technology[target_technology].effects,
        {
            type = "unlock-recipe",
            recipe = "deadlock-unpackrecipe-"..item_name,
        }
    )
    DCM.debug("DCM: Modified technology: "..target_technology)
end

-- does a table of IngredientPrototypes or ProductPrototypes contain reference to an item?
local function product_prototype_uses_item(proto, item)
    for _,p in pairs(proto) do
        if p.name and p.name == item then return true
        elseif p[1] == item then return true end
    end
    return false
end

-- does a recipe reference an item in its ingredients?
local function uses_item_as_ingredient(recipe, item)
    if recipe.ingredients and product_prototype_uses_item(recipe.ingredients, item) then return true end
    if recipe.normal and recipe.normal.ingredients and product_prototype_uses_item(recipe.normal.ingredients, item) then return true end
    if recipe.expensive and recipe.expensive.ingredients and product_prototype_uses_item(recipe.expensive.ingredients, item) then return true end
    return false
end

-- does a recipe reference an item in its results?
local function uses_item_as_result(recipe, item)
    if recipe.result == item then return true end
    if recipe.normal and recipe.normal.result == item then return true end
    if recipe.expensive and recipe.expensive.result == item then return true end
    if recipe.results and product_prototype_uses_item(recipe.results, item) then return true end
    if recipe.normal and recipe.normal.results and product_prototype_uses_item(recipe.normal.results, item) then return true end
    if recipe.expensive and recipe.expensive.results and product_prototype_uses_item(recipe.expensive.results, item) then return true end
    return false
end

local function is_value_in_table(t, value)
    if not t or not value then return false end
    for k,v in pairs(t) do
        if value == v then return true end
    end
    return false
end

-- remove an item and any recipes and technologies that reference it
function DCM.destroy_crate(base_item_name)
    local item_name = DCM.CRATE_ITEM_PREFIX .. base_item_name
    local stack_recipe_name = DCM.CRATE_PACK_RECIPE_PREFIX .. base_item_name
    local unstack_recipe_name = DCM.CRATE_UNPACK_RECIPE_PREFIX .. base_item_name
    -- remove the item
    if data.raw.item[item_name] then
        DCM.debug("DCM: Removed item "..item_name)
        data.raw.item[item_name] = nil
    end
    -- remove all recipes that use stacks as either ingredient or result
    -- we don't only target native crate/uncrate recipes because other mods may have used crates as ingredients by now
    -- keep a list of which recipes got removed, so we can search tech unlocks
    local dead_recipes = {}
    for _,recipe in pairs(data.raw.recipe) do
        if uses_item_as_ingredient(recipe, item_name) or uses_item_as_result(recipe, item_name) then
            DCM.debug("DCM: Removed recipe "..recipe.name)
            data.raw.recipe[recipe.name] = nil
            table.insert(dead_recipes, recipe.name)
        end
    end
    -- remove all the removed recipe tech unlocks
    for _,tech in pairs(data.raw.technology) do
        if tech.effects then
            local temp = {}
            local found = false
            for _,effect in pairs(tech.effects) do
                if effect.type ~= "unlock-recipe" or not is_value_in_table(dead_recipes, effect.recipe) then
                    table.insert(temp,effect)
                else found = true end
            end
            if found then DCM.debug("DCM: Removed unlocks from "..tech.name) end
            tech.effects = table.deepcopy(temp)
        end
    end
end

-- brighter version of tier colour for working vis glow & lights
local function brighter_colour(c)
    local w = 255
    if c.r <= 1 and c.g <= 1 and c.b <= 1 then
        c.r = c.r * 255
        c.g = c.g * 255
        c.b = c.b * 255
        if not c.a then c.a = 255
        elseif c.a <=1 then c.a = c.a * 255 end
    end
    return { r = math.floor((c.r + w)/2), g = math.floor((c.g + w)/2), b = math.floor((c.b + w)/2), a = c.a }
end

-- for calculating scales of energy, health etc.
local function get_scale(this_tier, tiers, lowest, highest)
    return lowest + ((highest - lowest) * ((this_tier - 1) / (tiers - 1)))
end

-- energy use
local function get_energy_table(this_tier, tiers, lowest, highest, passive_multiplier)
    local total = get_scale(this_tier, tiers, lowest, highest)
    local passive_energy_usage = total * passive_multiplier
    local active_energy_usage = total * (1 - passive_multiplier)
    return {
        passive = passive_energy_usage .. "KW", -- passive energy drain as a string
        active = active_energy_usage .. "KW", -- active energy usage as a string
    }
end

-- create crating machine entities
-- tier (integer) - mandatory - numbered suffix appended to the name
-- colour (table) - optional - Factorio colour table - defaults to DCM-defined defaults if not specified, or pink if tier is outside of range
-- speed (float) - optional - machine crafting speed, default = tier if not specified
-- pollution (float) - optional - pollution produced by machine. defaults to (5 - tier) if tier is 1-3, 1 for any other value
-- energy (string) - mandatory if tier is not a number, otherwise optional - energy usage of the machine, e.g. "1MW", "750kW" etc. Defaults to vanilla tier scheme if not specified
-- drain (string) - mandatory if tier is not a number, otherwise optional - constant energy drain of the machine, e.g. "10kW" etc. Defaults to vanilla tier scheme if not specified
-- upgrade (string) - optional - the entity this machine will be automatically upgraded to by the upgrade planner.
-- health (integer) - mandatory if tier is not a number, otherwise optional - the max health of the machine. Defaults to vanilla tier scheme if not specified for numbered tiers.
function DCM.create_machine_entity(tier, colour, speed, pollution, energy, drain, upgrade, health)
    if not tier then error("DCM: tier not specified for crating machine entity") end
    if not speed then
        if type(tier) ~= "number" then error("DCM: speed not specified for crating machine entity with non-numeric tier suffix") end
        speed = tier
    end
    if not colour then
        if tier > 0 and tier <= DCM.TIERS then colour = DCM.TIER_COLOURS[tier]
        else colour = DCM.DEFAULT_COLOUR end
    end
    if not pollution then
        if type(tier) == "number" then
            if (tier < 1 or tier > DCM.TIERS) then pollution = 1
            else pollution = 5 - tier end
        else pollution = 1 end
    end
    if not energy then
        if type(tier) ~= "number" then error("DCM: energy usage not specified for crating machine entity with non-numeric tier suffix") end
        local energy_table = get_energy_table(tier, DCM.TIERS, 500, 1000, 0.1)
        energy = energy_table.active
    end
    if not drain then
        if type(tier) ~= "number" then error("DCM: energy drain not specified for crating machine entity with non-numeric tier suffix") end
        local energy_table = get_energy_table(tier, DCM.TIERS, 500, 1000, 0.1)
        drain = energy_table.passive
    end
    if not health and type(tier) ~= "number" then error("DCM: health not specified for crating machine entity with non-numeric tier suffix") end
    if not health then health = get_scale(tier, DCM.TIERS, 300, 400) end
    local machine = {
        name = DCM.MACHINE_PREFIX .. tier,
        type = "assembling-machine",
        next_upgrade = upgrade,
        fast_replaceable_group = "crating-machine",
        icons = {
            { icon = "__DeadlockCrating__/graphics/icons/mipmaps/crating-icon-base.png", icon_size = DCM.ITEM_ICON_SIZE, icon_mipmaps = 4 },
            { icon = "__DeadlockCrating__/graphics/icons/mipmaps/crating-icon-mask.png", icon_size = DCM.ITEM_ICON_SIZE, tint = colour, icon_mipmaps = 4 },
        },
        minable = {
            mining_time = 0.5,
            result = DCM.MACHINE_PREFIX .. tier,
        },
        crafting_speed = speed,
        module_specification = {
            module_info_icon_shift = { 0, 0.8 },
            module_slots = 1
        },
        allowed_effects = {"consumption"},
        crafting_categories = {"packing"},
        gui_title_key = "gui-title.crating",
        max_health = health,
        energy_usage = energy,
        energy_source = {
            type = "electric",
            usage_priority = "secondary-input",
            drain = drain,
            emissions_per_minute = pollution,
        },
        dying_explosion = "medium-explosion",
        resistances = {
            {
                type = "fire",
                percent = 90
            },
        },
        corpse = "big-remnants",
        flags = {
            "placeable-neutral",
            "placeable-player",
            "player-creation"
        },
        collision_box = { {-1.3,-1.3}, {1.3,1.3} },
        selection_box = { {-1.5,-1.5}, {1.5,1.5} },
        tile_width = 3,
        tile_height = 3,
        animation = {
            layers = {
                {
                    hr_version = {
                        filename = "__DeadlockCrating__/graphics/entities/high/crating-base.png",
                        animation_speed = 1 / speed,
                        priority = "high",
                        frame_count = 60,
                        line_length = 10,
                        height = 192,
                        scale = 0.5,
                        shift = {0, 0},
                        width = 192
                    },
                    filename = "__DeadlockCrating__/graphics/entities/low/crating-base.png",
                    animation_speed = 1 / speed,
                    priority = "high",
                    frame_count = 60,
                    line_length = 10,
                    height = 96,
                    scale = 1,
                    shift = {0, 0},
                    width = 96
                },
                {
                    hr_version = {
                        filename = "__DeadlockCrating__/graphics/entities/high/crating-mask.png",
                        animation_speed = 1 / speed,
                        priority = "high",
                        repeat_count = 60,
                        height = 192,
                        scale = 0.5,
                        shift = {0, 0},
                        width = 192,
                        tint = colour
                    },
                    filename = "__DeadlockCrating__/graphics/entities/low/crating-mask.png",
                    animation_speed = 1 / speed,
                    priority = "high",
                    repeat_count = 60,
                    height = 96,
                    scale = 1,
                    shift = {0, 0},
                    width = 96,
                    tint = colour,
                },
                {
                    hr_version = {
                        draw_as_shadow = true,
                        filename = "__DeadlockCrating__/graphics/entities/high/crating-shadow.png",
                        animation_speed = 1 / speed,
                        repeat_count = 60,
                        height = 192,
                        scale = 0.5,
                        shift = {1.5, 0},
                        width = 384
                    },
                    draw_as_shadow = true,
                    filename = "__DeadlockCrating__/graphics/entities/low/crating-shadow.png",
                    animation_speed = 1 / speed,
                    repeat_count = 60,
                    height = 96,
                    scale = 1,
                    shift = {1.5, 0},
                    width = 192
                }
            }
        },
        working_visualisations = {
            {
                animation = {
                    hr_version = {
                        animation_speed = 1 / speed,
                        blend_mode = "additive",
                        filename = "__DeadlockCrating__/graphics/entities/high/crating-working.png",
                        frame_count = 30,
                        line_length = 10,
                        height = 192,
                        priority = "high",
                        scale = 0.5,
                        tint = brighter_colour(colour),
                        width = 192
                    },
                    animation_speed = 1 / speed,
                    blend_mode = "additive",
                    filename = "__DeadlockCrating__/graphics/entities/low/crating-working.png",
                    frame_count = 30,
                    line_length = 10,
                    height = 96,
                    priority = "high",
                    tint = brighter_colour(colour),
                    width = 96
                },
                light = {
                    color = brighter_colour(colour),
                    intensity = 0.4,
                    size = 9,
                    shift = {0, 0},
                },
            },
        },
        working_sound = { filename = "__DeadlockCrating__/sounds/deadlock-crate-machine.ogg", volume = 0.7 },
        open_sound = {
            filename = "__base__/sound/machine-open.ogg",
            volume = 0.75
        },
        close_sound = {
            filename = "__base__/sound/machine-close.ogg",
            volume = 0.75
        },
        mined_sound = {
            filename = "__base__/sound/deconstruct-bricks.ogg"
        },
        vehicle_impact_sound = {
            filename = "__base__/sound/car-metal-impact.ogg",
            volume = 0.65
        },
    }
    data:extend({machine})
end

-- create crating machine items
-- tier (integer) - mandatory - numbered suffix appended to the name
-- colour (table) - optional - Factorio colour table - defaults to DCM-defined defaults if not specified, or pink if tier is outside of range
function DCM.create_machine_item(tier, colour)
    if not tier then error("DCM: tier not specified for crating machine item") end
    if not colour then
        if tier > 0 and tier <= DCM.TIERS then colour = DCM.TIER_COLOURS[tier]
        else colour = DCM.DEFAULT_COLOUR end
    end
    local order = type(tier) == "number" and string.format("%03d",tier) or tier
    data:extend {
        {
            type = "item",
            name = DCM.MACHINE_PREFIX .. tier,
            subgroup = "production-machine",
            stack_size = 50,
            icons = {
                { icon = "__DeadlockCrating__/graphics/icons/mipmaps/crating-icon-base.png", icon_size = DCM.ITEM_ICON_SIZE, icon_mipmaps = 4 },
                { icon = "__DeadlockCrating__/graphics/icons/mipmaps/crating-icon-mask.png", icon_size = DCM.ITEM_ICON_SIZE, tint = colour, icon_mipmaps = 4 },
            },
            icon_size = DCM.ITEM_ICON_SIZE,
            order = "z[crating-machine]-" .. order,
            place_result = DCM.MACHINE_PREFIX .. tier,
            flags = {},
        }
    }
end

-- create crating machine recipes
-- tier (integer) - mandatory - numbered suffix appended to the name
-- ingredients (table) - mandatory - table of IngredientPrototypes
function DCM.create_machine_recipe(tier, ingredients)
    if not tier then error("DCM: tier not specified for crating machine recipe") end
    if not ingredients then error("DCM: ingredients not specified for crating machine recipe") end
    data:extend({
        {
            type = "recipe",
            name = DCM.MACHINE_PREFIX .. tier,
            enabled = false,
            ingredients = ingredients,
            result = DCM.MACHINE_PREFIX .. tier,
            energy_required = 3.0,
        }
    })
end

-- create crating machine technologies - adds a new tech that unlocks a machine (crates added later on crate creation)
-- tier (integer) - mandatory - numbered suffix appended to the name
-- colour (table) - optional - Factorio colour table - defaults to DCM-defined defaults if not specified, or pink if tier is outside of range
-- prerequisites (table) - optional - prerequisites techs, defaults to DCM native spec if tier within range, otherwise no prereqs
-- unit (table) - mandatory if outside native tech tier range otherwise optional - unit spec for tech cost (see https://wiki.factorio.com/Prototype/Technology#unit)
function DCM.create_crating_technology(tier, colour, prerequisites, unit)
    if not tier then error("DCM: tier not specified for crating machine technology") end
    if not colour then
        if tier >= 1 and tier <= DCM.TIERS then colour = DCM.TIER_COLOURS[tier]
        else colour = DCM.DEFAULT_COLOUR end
    end
    if not prerequisites and tier >= 1 and tier <= DCM.TIERS then prerequisites = DCM.TECH_PREREQUISITES[tier] end
    if not unit then
        if tier < 1 or tier > DCM.TIERS then error("DCM: asked to create a technology outside of vanilla tier range, but research unit costs were not specified") end
        unit = table.deepcopy(data.raw.technology[DCM.TECH_BASE[tier]].unit)
        unit.count = unit.count * 2
    end
    local order = type(tier) == "number" and string.format("%03d",tier) or tier
    data:extend({
        {
            type = "technology",
            name = DCM.TECH_PREFIX .. tier,
            prerequisites = prerequisites,
            unit = unit,
            icons = {
                { icon = "__DeadlockCrating__/graphics/icons/square/crating-icon-base-128.png" },
                { icon = "__DeadlockCrating__/graphics/icons/square/crating-icon-mask-128.png", tint = colour },
            },
            icon_size = 128,
            order = order,
            effects = {
                {
                    type = "unlock-recipe",
                    recipe = DCM.MACHINE_PREFIX .. tier
                }
            },
        }
    })
end

return DCM
