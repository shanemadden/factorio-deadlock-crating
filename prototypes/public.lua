------------------------------------------------------------------------------------------------------------------------------------------------------

-- DEADLOCK'S CRATING MACHINE API

------------------------------------------------------------------------------------------------------------------------------------------------------

local DCM = require "prototypes.shared"
deadlock_crating = {}

------------------------------------------------------------------------------------------------------------------------------------------------------

-- deadlock_crating.add_crate()
-- Creates a new crated version of a specified item
-- item_name (string) - mandatory - name of the item prototype you want to be put into crates
-- target_tech (string) - optional - name of the technology you want to add the crating unlocks to. If this is unspecified/nil, they won't be unlocked at all and you must handle the unlocks yourself
-- Example: deadlock_crating.create("nuclear-laser-bomb", "deadlock-crating-3", 64)
function deadlock_crating.add_crate(item_name, target_tech)
	if not item_name then error("DCM: add_crate() given nil item name") end
	DCM.generate_crates(item_name)
	if target_tech then DCM.add_crates_to_tech(item_name, target_tech) end
end

-- deadlock_crating.destroy_crate(item_name)
-- destroys the crated version of an item, all recipes which use or produce it, and removes all references to its recipe unlocks from all technologies
-- item_name (string) - name of the item you no longer want to be crateable
-- Example: deadlock_crating.destroy_crate("copper-cable")
function deadlock_crating.destroy_crate(item_name)
	if not item_name then error("DCM: destroy_crate() given nil item name") end
	DCM.destroy_crate(item_name)
end

-- deadlock_crating.destroy_vanilla_crates()
-- No parameters. Destroys all the vanilla crates that are created by default, all recipes which use or produce them, and all references to any recipe unlocks
-- This is the same as calling destroy_crate() on every vanilla item the mod crates up by default
-- Example: deadlock_crating.destroy_vanilla_crates()
function deadlock_crating.destroy_vanilla_crates()
	for _,tier in pairs(DCM.VANILLA_ITEM_TIERS) do
		for _,item_name in pairs(tier) do
			DCM.destroy_crate(item_name)
		end
	end
end

-- deadlock_crating.add_tier()
-- This function will create a new tier of machine and a new technology that unlocks it. You can then add new crating recipes to it with deadlock_crating.create().
-- If you specify a tier that already exists, * it will be overwritten *, so you will also have to recreate any tech unlocks that you wanted to keep.
-- parameters (table) - Takes just one argument, a table with the following keys defined (in any order because it's a table):
-- .tier (integer/string) - mandatory - the tier suffix. This is usually an integer (1-3 for the vanilla tiers) but you can specify a string if you insist.
-- .ingredients (table) - mandatory - the ingredients for the crating machine (see https://wiki.factorio.com/Prototype/Recipe#ingredients).
-- .colour (table) - optional - the tier colour. Must be a colour table in the format {r=1,g=1,b=1} (a=optional). If not specified or nil, will use default tier colours if tier is 1-3, otherwise pink.
-- .upgrade (string) - optional - the entity this machine will be automatically upgraded to by the upgrade planner. Defaults to tier+1 for numbered tiers, nil for non-numbered, if not specified/nil. 
-- .speed (float) - mandatory if tier is not a number, otherwise optional - the speed of the crating machine. Speed 1 handles a compressed vanilla yellow belt, 2 a red belt, etc. Defaults to same value as tier as long as tier is a number.
-- .pollution (float) - optional - how much pollution the machine produces. Defaults to (5-tier) if tier is a number, 1 if tier is a string.
-- .energy (string) - mandatory if tier is not a number, otherwise optional - energy usage of the machine, e.g. "1MW", "750kW" etc. Defaults to vanilla tier scheme if not specified
-- .drain (string) - mandatory if tier is not a number, otherwise optional - constant energy drain of the machine, e.g. "10kW" etc. Defaults to vanilla tier scheme if not specified
-- .prerequisites (table) - optional - a list of technology prerequisites (see https://wiki.factorio.com/Prototype/Technology#prerequisites). Can be nil.
-- .unit (table) - mandatory if tier is not 1-3, otherwise optional - the unit cost for the technology (see https://wiki.factorio.com/Prototype/Technology#unit). Defaults to native tier scheme if not specified and tier is 1-3. Cannot be nil.
-- .health (integer) - mandatory if tier is not a number, otherwise optional - the max health of the machine. Defaults to vanilla tier scheme if not specified for numbered tiers. 
-- The resulting machine item, recipe and entity will be named deadlock-crating-machine-N where N = tier. The technology is named deadlock-crating-N.
function deadlock_crating.add_tier(parameters)
	if not parameters.tier then error("DCM: create_tier(): tier not specified") end
	if not parameters.ingredients then error("DCM: create_tier(): ingredients not specified") end
	if not parameters.speed and type(parameters.tier) ~= "number" then error("DCM: create_tier(): speed not specified for non-numeric tier") end
	if not parameters.energy and type(parameters.tier) ~= "number" then error("DCM: create_tier(): energy not specified for non-numeric tier") end
	if not parameters.drain and type(parameters.tier) ~= "number" then error("DCM: create_tier(): drain not specified for non-numeric tier") end
	if not parameters.unit and (type(parameters.tier) ~= "number" or parameters.tier < 1 or parameters.tier > DCM.TIERS) then error("DCM: create_tier(): unit not specified for non-numeric or non-vanilla tier") end
	if not parameters.health and type(parameters.tier) ~= "number" then error("DCM: create_tier(): health not specified for non-numeric tier") end
	if type(parameters.tier) ~= "string" and type(parameters.tier) ~= "number" then error("DCM: create_tier(): tier given as non-number and non-string") end
	if type(parameters.ingredients) ~= "table" then error("DCM: create_tier(): ingredients given as non-table") end
	if parameters.colour and type(parameters.colour) ~= "table" then error("DCM: create_tier(): colour given as non-table") end
	if parameters.upgrade and type(parameters.upgrade) ~= "string" then error("DCM: create_tier(): upgrade given as non-string") end
	if parameters.pollution and type(parameters.pollution) ~= "number" then error("DCM: create_tier(): pollution given as non-number") end
	if parameters.energy and type(parameters.energy) ~= "string" then error("DCM: create_tier(): energy given as non-string") end
	if parameters.drain and type(parameters.drain) ~= "string" then error("DCM: create_tier(): energy given as non-string") end
	if parameters.prerequisites and type(parameters.prerequisites) ~= "table" then error("DCM: create_tier(): prerequisites given as non-table") end
	if parameters.unit and type(parameters.unit) ~= "table" then error("DCM: create_tier(): unit given as non-table") end
	if parameters.health and type(parameters.health) ~= "number" then error("DCM: create_tier(): health given as non-number") end
	DCM.create_machine_item(parameters.tier, parameters.colour)
	DCM.create_machine_recipe(parameters.tier, parameters.ingredients)
	DCM.create_machine_entity(parameters.tier, parameters.colour, parameters.speed, parameters.pollution, parameters.energy, parameters.drain, parameters.upgrade, parameters.health)
	DCM.create_crating_technology(parameters.tier, parameters.colour, parameters.prerequisites, parameters.unit)
end

-- removes recipe unlocks for a specified item from all DCM native tiers 1-3
-- does not clean up items and recipes, just disassociates them from technologies
-- DEPRECATED
function deadlock_crating.remove(item_name)
	log("DCM: deadlock_crating.remove("..item_name..") - this function is deprecated, consider using deadlock_crating.destroy_crate() instead")
    for i=1,DCM.TIERS do
        local e = data.raw.technology[DCM.TECH_PREFIX..i].effects
        if e then 
            local j = 2
            while e[j] do
                if e[j].type == "unlock-recipe" and string.find(e[j].recipe, item_name, 1, true) then
                    DCM.debug("DCM: Recipe "..e[j].recipe.." cleared.")
                    table.remove(e,j)
                else
                    j = j + 1
                end
            end
        end
    end
end

-- removes all but the first unlock (supposedly the machine) from all native tech tiers 1-3
-- does not clean up items and recipes, just disassociates them from technologies
-- DEPRECATED
function deadlock_crating.reset()
	log("DCM: deadlock_crating.reset() - this function is deprecated, consider using deadlock_crating.destroy_vanilla_crates() instead")
    for i=1,DCM.TIERS do
        local e = data.raw.technology[DCM.TECH_PREFIX..i].effects
        if e then 
            while e[2] do table.remove(e,2) end
        end
    end
    DCM.debug("DCM: reset() - all vanilla crates removed from tech unlocks.")
end

-- deadlock_crating.create()
-- Creates a new crated version of a specified item
-- DEPRECATED
function deadlock_crating.create(item_name, target_tech, icon_size)
	log("DCM: deadlock_crating.create("..item_name..") - this function is deprecated, consider using deadlock_crating.add_crate() instead")
	if not item_name then error("DCM: create() given nil item name") end
	if not icon_size then icon_size = 32 end
	DCM.generate_crates(item_name, icon_size)
	if target_tech then DCM.add_crates_to_tech(item_name, target_tech) end
end

