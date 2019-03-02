local DCM = require "prototypes.shared"

-- public stuff
deadlock_crating = {}

function deadlock_crating.create(item_name, target_tech, icon_size)
	DCM.debug("DCM: importing mod item: "..item_name)
    local sg = DCM.TAB_TIERS
    if string.find(target_tech, DCM.TECH_PREFIX, 1, true) then
        local e = tonumber(string.sub(target_tech, -1))
        if e > 0 and e < DCM.TIERS then sg = e end
    end
	DCM.generate_crates(item_name, sg, icon_size)
	DCM.add_crates_to_tech(item_name, target_tech)
end

function deadlock_crating.reset()
    for i=1,DCM.TIERS do
        local e = data.raw.technology[DCM.TECH_PREFIX..i].effects
        if e then 
            while e[2] do table.remove(e,2) end
        end
    end
    DCM.debug("DCM: Technologies cleared.")
end

function deadlock_crating.remove(target_tech)
    for i=1,DCM.TIERS do
        local e = data.raw.technology[DCM.TECH_PREFIX..i].effects
        if e then 
            local j = 2
            while e[j] do
                if e[j].type == "unlock-recipe" and string.find(e[j].recipe, target_tech, 1, true) then
                    DCM.debug("DCM: Recipe "..e[j].recipe.." cleared.")
                    table.remove(e,j)
                else
                    j = j + 1
                end
            end
        end
    end
end
