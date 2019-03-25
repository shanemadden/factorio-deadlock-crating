local DCM = require "prototypes.shared"

-- brighter version of tier colour for working vis glow & lights
local function brighter_colour(c)
	local w = 240
	return { r = math.floor((c.r + w)/2), g = math.floor((c.g + w)/2), b = math.floor((c.b + w)/2) }
end

-- for calculating scales of energy, health etc.
local function get_scale(this_tier, tiers, lowest, highest)
	return lowest + ((highest - lowest) * ((this_tier - 1) / (tiers - 1)))
end

-- Energy and pollution. They just couldn't make it easy, could they
local function get_energy_table(this_tier, tiers, lowest, highest, passive_multiplier, pollution)
	local total = get_scale(this_tier, tiers, lowest, highest)
	local passive_energy_usage = total * passive_multiplier
	local active_energy_usage = total * (1 - passive_multiplier)
	return {
		passive = passive_energy_usage .. "KW", -- passive energy drain as a string
		active = active_energy_usage .. "KW", -- active energy usage as a string
		emissions = pollution / active_energy_usage / 1000, -- pollution/s/W
	}
end

-- iterate through tiers
for i=1,DCM.TIERS do
	local machine = table.deepcopy(data.raw["assembling-machine"]["assembling-machine-"..i])
	machine.name = "deadlock-machine-packer-entity-"..i
	machine.icon = nil
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
	machine.max_health = get_scale(i, DCM.TIERS, 300, 400)
	local energy_table = get_energy_table(i, DCM.TIERS, 500, 1000, 0.1, 5 - i)
	machine.energy_usage = energy_table.active
	machine.energy_source = {
		type = "electric",
		usage_priority = "secondary-input",
		drain = energy_table.passive,
		emissions_per_second_per_watt = energy_table.emissions, -- replaces old emissions parameter
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