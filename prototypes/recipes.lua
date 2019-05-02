local DCM = require "prototypes.shared"

-- crafting tab groups
data:extend {
	{
		type = "item-group",
		name = "deadlock-crates",
		order = "z",
		icons = {
			{ icon = "__DeadlockCrating__/graphics/icons/crating-icon-base-128.png" },
			{ icon = "__DeadlockCrating__/graphics/icons/crating-icon-mask-128.png", tint = DCM.TIER_COLOURS[1] },
		},
		icon_size = 128,
	},
    {
        type = "item-subgroup",
        name = "deadlock-crates-pack",
        group = "deadlock-crates",
        order = "a",
    },
    {
        type = "item-subgroup",
        name = "deadlock-crates-unpack",
        group = "deadlock-crates",
        order = "b",
    },
}

-- any non-crate recipes
data:extend {
	{
	type = "recipe-category",
    name = "packing";
	},
}
table.insert(data.raw["character"]["character"].crafting_categories, "packing")

-- the machines
data:extend {
	{
	type = "recipe",
	name = "deadlock-machine-packer-recipe-1",
	enabled = false,
	ingredients = {
	 {"assembling-machine-1",1},
	 {"electric-engine-unit",1},
	 {"stack-inserter",2},
	 {"steel-plate",20},
	},
	result = "deadlock-machine-packer-item-1",
	energy_required = 5.0;
	},
	{
	type = "recipe",
	name = "deadlock-machine-packer-recipe-2",
	enabled = false,
	ingredients = {
	 {"deadlock-machine-packer-item-1",1},
	 {"electric-engine-unit",1},
	 {"stack-inserter",2},
	 {"steel-plate",30},
	},
	result = "deadlock-machine-packer-item-2",
	energy_required = 8.0;
	},
	{
	type = "recipe",
	name = "deadlock-machine-packer-recipe-3",
	enabled = false,
	ingredients = {
	 {"deadlock-machine-packer-item-2",1},
	 {"electric-engine-unit",1},
	 {"stack-inserter",2},
	 {"steel-plate",50},
	},
	result = "deadlock-machine-packer-item-3",
	energy_required = 12.0;
	},
 }