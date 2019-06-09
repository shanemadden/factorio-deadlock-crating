local DCM = require "prototypes.shared"

-- crating machines
for tier = 1,DCM.TIERS do
	DCM.create_machine_item(tier)
end
