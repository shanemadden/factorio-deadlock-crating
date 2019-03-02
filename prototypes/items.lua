local DCM = require "prototypes.shared"

-- crating machines
for i=1,DCM.TIERS do
	local item = table.deepcopy(data.raw.item["assembling-machine-"..i])
	item.name = "deadlock-machine-packer-item-"..i
	item.subgroup = "production-machine"
	item.icon = "__DeadlockCrating__/graphics/crate-machine-"..i..".png"
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