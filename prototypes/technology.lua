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
		[1] = {type = "unlock-recipe",
			recipe = "deadlock-machine-packer-recipe-"..i
		},
	}
	for i,recipe in pairs(DCM.ITEM_TIER[i]) do
		table.insert(recipeeffects,   
			{type = "unlock-recipe",
				recipe = "deadlock-packrecipe-"..recipe
			}
		)
		table.insert(recipeeffects,   
			{type = "unlock-recipe",
				recipe = "deadlock-unpackrecipe-"..recipe
			}
		)
		--[[
		if data.raw.item["deadlock-stack-"..recipe] then
			table.insert(recipeeffects,   
				{type = "unlock-recipe",
					recipe = "deadlock-packrecipe-deadlock-stack-"..recipe
				}
			)
		end
		]]--
	end
	local research = table.deepcopy(data.raw.technology[baseresearch[i]])
	research.effects = recipeeffects
	research.icon = "__DeadlockCrating__/graphics/deadlock-crating.png"
	research.name = DCM.TECH_PREFIX..i
	research.unit.count = research.unit.count * 2
	research.prerequisites = prereqs[i]
	research.upgrade = false
	data:extend({research})
end
