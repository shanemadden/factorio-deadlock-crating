local DCM = require "prototypes.shared"

for tier = 1,DCM.TIERS do
	DCM.create_machine_entity(tier, nil, nil, nil, nil, nil, (tier < DCM.TIERS) and (DCM.MACHINE_PREFIX..(tier+1)) or nil, nil)
end
