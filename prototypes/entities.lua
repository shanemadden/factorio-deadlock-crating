-- the crating machines
for i=1,3 do
	local machine = table.deepcopy(data.raw["assembling-machine"]["assembling-machine-"..i])
	machine.name = "deadlock-machine-packer-entity-"..i
	machine.icon = "__DeadlockCrating__/graphics/crate-machine-"..i..".png"
	machine.minable.result = "deadlock-machine-packer-item-"..i
	machine.crafting_speed = i
	machine.module_specification = {
	  module_info_icon_shift = { 0, 0.8 },
	  module_slots = 1
	}
	machine.allowed_effects = {"consumption"}
	machine.crafting_categories = {"packing"}
	machine.max_health = 300 + i*75
	machine.energy_usage = i*170 .. "KW"
	machine.energy_source = {
			emissions = 0.015,
			type = "electric",
			usage_priority = "secondary-input",
			drain = i*170 .. "KW",
	}
	machine.working_sound = { filename = "__DeadlockCrating__/sounds/deadlock-crate-machine.ogg" }
	data:extend{machine}
end