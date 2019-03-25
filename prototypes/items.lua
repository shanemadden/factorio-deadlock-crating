local DCM = require "prototypes.shared"

-- crating machines
for i=1,DCM.TIERS do
	data:extend {
		{
			type = "item",
			name = "deadlock-machine-packer-item-"..i,
			subgroup = "production-machine",
			stack_size = 50,
			icons = {
				{ icon = "__DeadlockCrating__/graphics/icons/crating-icon-base-"..DCM.ITEM_ICON_SIZE..".png" },
				{ icon = "__DeadlockCrating__/graphics/icons/crating-icon-mask-"..DCM.ITEM_ICON_SIZE..".png", tint = DCM.TIER_COLOURS[i] },
			},
			icon_size = DCM.ITEM_ICON_SIZE,
			order = "z"..i,
			place_result = "deadlock-machine-packer-entity-"..i,
			flags = {},
		}
	}
end

-- generate vanilla crates
for i=1,DCM.TIERS do
	for _,item in pairs(DCM.ITEM_TIER[i]) do
		DCM.generate_crates(item, i)
	end
end