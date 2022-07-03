local DCM = require "prototypes.shared"

-- generate vanilla crates and add them to their technology
if DCM.VANILLA_GENERATION then
	for i=1,DCM.TIERS do
		for _,item in pairs(DCM.VANILLA_ITEM_TIERS[i]) do
			DCM.generate_crates(item, DCM.VANILLA_ICON_SIZE)
			DCM.add_crates_to_tech(item, DCM.TECH_PREFIX..i)
		end
	end
end