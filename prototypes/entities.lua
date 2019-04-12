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
	local energy_table = get_energy_table(i, DCM.TIERS, 500, 1000, 0.1, 5 - i)
	local machine = {
		name = "deadlock-machine-packer-entity-"..i,
		type = "assembling-machine",
		next_upgrade = (i < DCM.TIERS) and "deadlock-machine-packer-entity-"..(i+1) or nil,
		fast_replaceable_group = "packer",
		icons = {
			{ icon = "__DeadlockCrating__/graphics/icons/crating-icon-base-"..DCM.ITEM_ICON_SIZE..".png", icon_size = DCM.ITEM_ICON_SIZE },
			{ icon = "__DeadlockCrating__/graphics/icons/crating-icon-mask-"..DCM.ITEM_ICON_SIZE..".png", icon_size = DCM.ITEM_ICON_SIZE, tint = DCM.TIER_COLOURS[1] },
		},
		minable = {
			mining_time = 0.2,
			result = "deadlock-machine-packer-item-"..i,
		},
		crafting_speed = i,
		module_specification = {
			module_info_icon_shift = { 0, 0.8 },
			module_slots = 1
		},
		allowed_effects = {"consumption"},
		crafting_categories = {"packing"},
		max_health = get_scale(i, DCM.TIERS, 300, 400),
		energy_usage = energy_table.active,
		energy_source = {
			type = "electric",
			usage_priority = "secondary-input",
			drain = energy_table.passive,
			emissions_per_second_per_watt = energy_table.emissions,
		},
		dying_explosion = "medium-explosion",
		resistances = {
		  {
			type = "fire",
			percent = 90
		  },
		},
		corpse = "big-remnants",
		flags = {
			"placeable-neutral",
			"placeable-player",
			"player-creation"
		},
		collision_box = { {-1.3,-1.3}, {1.3,1.3} },
		selection_box = { {-1.5,-1.5}, {1.5,1.5} },
		tile_width = 3,
		tile_height = 3,
		animation = {
			layers = {
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
				},
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
				}
			}
		},
		working_visualisations = {
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
		},
		working_sound = { filename = "__DeadlockCrating__/sounds/deadlock-crate-machine.ogg", volume = 0.7 },
		open_sound = {
			filename = "__base__/sound/machine-open.ogg",
			volume = 0.75
		},
		close_sound = {
			filename = "__base__/sound/machine-close.ogg",
			volume = 0.75
		},
		mined_sound = {
			filename = "__base__/sound/deconstruct-bricks.ogg"
		},
		vehicle_impact_sound = {
			filename = "__base__/sound/car-metal-impact.ogg",
			volume = 0.65
		},
	}
	data:extend({machine})
end
