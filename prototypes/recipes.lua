local DCM = require "prototypes.shared"

-- the machines
DCM.create_machine_recipe(1, {
	{"assembling-machine-1",1},
	{"electric-engine-unit",1},
	{"stack-inserter",2},
	{"steel-plate",20},
})

DCM.create_machine_recipe(2, {
	{"deadlock-crating-machine-1",1},
	{"electric-engine-unit",1},
	{"stack-inserter",2},
	{"steel-plate",30},
})

DCM.create_machine_recipe(3, {
	{"deadlock-crating-machine-2",1},
	{"electric-engine-unit",1},
	{"stack-inserter",2},
	{"steel-plate",50},
})

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

-- crafting category for packing/unpacking
data:extend {
    {
        type = "recipe-category",
        name = "packing",
    },
}

-- player character can pack and unpack
table.insert(data.raw["character"]["character"].crafting_categories, "packing")
