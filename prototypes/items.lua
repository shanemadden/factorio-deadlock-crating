local DCM = require "prototypes.shared"

-- crating machines
for i=1,DCM.TIERS do
	local item = table.deepcopy(data.raw.item["assembling-machine-"..i])
	item.name = "deadlock-machine-packer-item-"..i
	item.subgroup = "production-machine"
	item.icons = {
		{ icon = "__DeadlockCrating__/graphics/icons/crating-icon-base-64.png" },
		{ icon = "__DeadlockCrating__/graphics/icons/crating-icon-mask-64.png", tint = DCM.TIER_COLOURS[i] },
	}
	item.icon_size = 64
	item.order = "z"..i
	item.place_result = "deadlock-machine-packer-entity-"..i
	data:extend{item}
end

-- generate vanilla crates
for i=1,DCM.TIERS do
	for _,item in pairs(DCM.ITEM_TIER[i]) do
		DCM.generate_crates(item, i)
	end
end