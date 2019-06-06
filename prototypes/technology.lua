local DCM = require "prototypes.shared"

-- research
for tier = 1,DCM.TIERS do
	DCM.create_crating_technology(tier)
end
