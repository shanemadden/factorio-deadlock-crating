local DCM = require "prototypes.shared"

-- the crating machines

local function brighter_colour(c)
	local w = 240
	return { r = math.floor((c.r + w)/2), g = math.floor((c.g + w)/2), b = math.floor((c.b + w)/2) }
end

for i=1,3 do
	local machine = table.deepcopy(data.raw["assembling-machine"]["assembling-machine-"..i])
	machine.name = "deadlock-machine-packer-entity-"..i
	machine.icons = {
		{ icon = "__DeadlockCrating__/graphics/icons/crating-icon-base-128.png" },
		{ icon = "__DeadlockCrating__/graphics/icons/crating-icon-mask-128.png", tint = DCM.TIER_COLOURS[1] },
	}
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
	machine.working_sound = { filename = "__DeadlockCrating__/sounds/deadlock-crate-machine.ogg", volume = 0.7 }
	machine.animation = {
		layers = {
			{
				hr_version = {
					draw_as_shadow = true,
					filename = "__DeadlockCrating__/graphics/entities/high/crating-shadow.png",
					animation_speed = 1 / i,
					repeat_count = 60,
					height = 192,
					scale = 0.5,
					shift = {1.5, 0},
					width = 384
				},
				draw_as_shadow = true,
				filename = "__DeadlockCrating__/graphics/entities/low/crating-shadow.png",
				animation_speed = 1 / i,
				repeat_count = 60,
				height = 96,
				scale = 1,
				shift = {1.5, 0},
				width = 192	
			},
			{
				hr_version = {
					filename = "__DeadlockCrating__/graphics/entities/high/crating-base.png",
					animation_speed = 1 / i,
					priority = "high",
					frame_count = 60,
					line_length = 10,
					height = 192,
					scale = 0.5,
					shift = {0, 0},
					width = 192
				},
				filename = "__DeadlockCrating__/graphics/entities/low/crating-base.png",
				animation_speed = 1 / i,
				priority = "high",
				frame_count = 60,
				line_length = 10,
				height = 96,
				scale = 1,
				shift = {0, 0},
				width = 96	
			},
			{
				hr_version = {
					filename = "__DeadlockCrating__/graphics/entities/high/crating-mask.png",
					animation_speed = 1 / i,
					priority = "high",
					repeat_count = 60,
					height = 192,
					scale = 0.5,
					shift = {0, 0},
					width = 192,
					tint = DCM.TIER_COLOURS[i],
				},
				filename = "__DeadlockCrating__/graphics/entities/low/crating-mask.png",
					animation_speed = 1 / i,
				priority = "high",
				repeat_count = 60,
				height = 96,
				scale = 1,
				shift = {0, 0},
				width = 96,	
				tint = DCM.TIER_COLOURS[i],
			}
		}
	}
	machine.working_visualisations = {
		{
		  animation = {
			hr_version = {
			  animation_speed = 1 / i,
			  blend_mode = "additive",
			  filename = "__DeadlockCrating__/graphics/entities/high/crating-working.png",
			  frame_count = 30,
			  line_length = 10,
			  height = 192,
			  priority = "high",
			  scale = 0.5,
			  tint = brighter_colour(DCM.TIER_COLOURS[i]),
			  width = 192
			},
			animation_speed = 1 / i,
			blend_mode = "additive",
			filename = "__DeadlockCrating__/graphics/entities/low/crating-working.png",
			frame_count = 30,
			line_length = 10,
			height = 96,
			priority = "high",
			tint = brighter_colour(DCM.TIER_COLOURS[i]),
			width = 96
		  },
		  light = {
			color = brighter_colour(DCM.TIER_COLOURS[i]),
			intensity = 0.4,
			size = 9,
			shift = {0, 0},
		  },
		},
	}
	data:extend{machine}
end