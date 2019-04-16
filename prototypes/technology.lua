local DCM = require "prototypes.shared"

-- research prerequisites per tier
local prereqs = {
	[1] = {"automation", "electric-engine", "stack-inserter"},
	[2] = {"automation-2", "deadlock-crating-1"},
	[3] = {"automation-3", "deadlock-crating-2"},
}

-- copy and multiply research cost per tier from these vanilla techs
local baseresearch = {
	[1] = "stack-inserter",
	[2] = "inserter-capacity-bonus-3",
	[3] = "inserter-capacity-bonus-5",
}

-- research
for i=1,3 do
	local recipeeffects = {
		{
			type = "unlock-recipe",
			recipe = "deadlock-machine-packer-recipe-"..i
		},
	}
	local research = table.deepcopy(data.raw.technology[baseresearch[i]])
	research.effects = recipeeffects
	research.icons = {
		{ icon = "__DeadlockCrating__/graphics/icons/crating-icon-base-128.png" },
		{ icon = "__DeadlockCrating__/graphics/icons/crating-icon-mask-128.png", tint = DCM.TIER_COLOURS[i] },
	}
	research.name = DCM.TECH_PREFIX..i
	research.unit.count = research.unit.count * 2
	research.prerequisites = prereqs[i]
	research.upgrade = false
	data:extend({research})
end
