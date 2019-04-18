local DCM = require "prototypes.shared"

-- generate vanilla crates and add them to their technology
for i=1,DCM.TIERS do
	for _,item in pairs(DCM.ITEM_TIER[i]) do
		DCM.generate_crates(item, i)
		DCM.add_crates_to_tech(item, DCM.TECH_PREFIX..i)
	end
end

