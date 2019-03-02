-- globals container
local DCM = {}

-- print to log for non-errors
DCM.LOGGING = false

-- how many crates to use up a whole vanilla stack
DCM.STACK_DIVIDER = 5

-- how many tiers of tech?
DCM.TIERS = 3
-- there are kind-of 4 tiers - all imported mod items go in tier 4 - only affects crafting tab
DCM.TAB_TIERS = DCM.TIERS + 1

-- which items can be crated, in which tier
DCM.ITEM_TIER = {
	[1] = { "wood", "iron-ore", "copper-ore", "stone", "coal", "iron-plate", "copper-plate", "steel-plate", "stone-brick" },
	[2] = { "copper-cable", "iron-gear-wheel", "iron-stick", "sulfur", "plastic-bar", "solid-fuel", "electronic-circuit", "advanced-circuit" },
	[3] = { "processing-unit", "battery", "uranium-ore", "uranium-235", "uranium-238" },
}

DCM.TECH_PREFIX = "deadlock-crating-"

-- DCM.debug logging
function DCM.debug(message)
	if DCM.LOGGING then log(message) end
end

-- generate items and recipes for crated vanilla items
DCM.CRATE_ORDER = 0
function DCM.generate_crates(this_item, subgroup, icon_size)
    if icon_size and (icon_size ~= 32 and icon_size ~= 64 and icon_size ~= 128) then
		log("ERROR: DCM asked to use icon_size that is not 32, 64 or 128")
		return
    end
    if not icon_size then icon_size = 32 end
	-- The crated item
	local base_item = data.raw.item[this_item]
	if not base_item then
		log("ERROR: DCM asked to crate an item that doesn't exist ("..this_item..")")
		return
	end
	local items_per_crate = base_item.stack_size/DCM.STACK_DIVIDER
    local crateitem = "__DeadlockCrating__/graphics/wooden-chest-dark.png"
    local icons
	if base_item.icon then
		icons = {
			{ icon = crateitem, icon_size = 32 },
			{
				icon = base_item.icon,
				scale = 0.7 * 32 / icon_size,
				shift = {0, 0},
                icon_size = icon_size,
			},
		}
	elseif base_item.icons then
		local tempcopy = table.deepcopy(base_item.icons)
		icons = { { icon = crateitem, icon_size = 32 } }
		local c = 2
		for i,v in ipairs(tempcopy) do
			icons[c] = table.deepcopy(v)
			icons[c].scale = 0.7 * 32 / icon_size
            icons[c].icon_size = icon_size
			c = c + 1
		end
	else
		log("ERROR: DCM asked to crate an item with no icon or icons properties ("..this_item..")")
		return
	end
	local packrecipeicons = table.deepcopy(icons)
	local unpackrecipeicons = table.deepcopy(icons)
	table.insert(packrecipeicons, 2, { icon = "__DeadlockCrating__/graphics/arrow-d-"..icon_size..".png", scale = 0.5 * 32 / icon_size, icon_size = icon_size, shift = {0, 8} } ) 
	table.insert(unpackrecipeicons, 2, { icon = "__DeadlockCrating__/graphics/arrow-u-"..icon_size..".png", scale = 0.5 * 32 / icon_size, icon_size = icon_size, shift = {0, -8} } ) 
	-- the item
	data:extend { 
        -- the item
        {
            type = "item",
            name = "deadlock-crate-" .. this_item,
            localised_name = {"item-name.deadlock-crate-item", items_per_crate, {"item-name." .. this_item}},
            stack_size = DCM.STACK_DIVIDER,
            order = string.format("%03d",DCM.CRATE_ORDER),
            subgroup = "deadlock-crates-pack",
            allow_decomposition = false,
            icons = icons,
            icon_size = icon_size, 
            flags = {},
        },
		-- The packing recipe
		{
			type = "recipe",
			name = "deadlock-packrecipe-"..this_item,
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
            icon_size = icon_size, 
			result = "deadlock-crate-"..this_item,
			energy_required = 3*items_per_crate/40,
			allow_decomposition = false,
            allow_intermediates = false,
            allow_as_intermediate = false,
            hide_from_stats = true,
			main_product = nil,
		},
		-- The unpacking recipe
		{
			type = "recipe",
			name = "deadlock-unpackrecipe-"..this_item,
			localised_name = {"recipe-name.deadlock-unpacking-recipe", {"item-name." .. this_item}},
			order = string.format("%03d",DCM.CRATE_ORDER),
			category = "packing",
			subgroup = "deadlock-crates-unpack",
			enabled = false,
			ingredients = {
				{"deadlock-crate-"..this_item, 1},
			},
			icons = unpackrecipeicons,
            icon_size = icon_size, 
			results = {
				{"wooden-chest", 1},
				{this_item, items_per_crate},
			},
			energy_required = 3*items_per_crate/40,
			allow_decomposition = false,
            allow_intermediates = false,
            allow_as_intermediate = false,
            hide_from_stats = true,
			main_product = nil,
		},
	}
	DCM.debug("DCM: crates created: "..this_item)
	DCM.CRATE_ORDER = DCM.CRATE_ORDER + 1	
end

-- make the stacking recipes depend on a technology
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

return DCM