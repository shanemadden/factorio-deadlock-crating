data:extend(
{
    {
        type = "double-setting",
        name = "craft_belt_ratio",
        setting_type = "startup",
        default_value = 15,
        minimum_value = 1,
        maximum_value = 100,
    },
    {
        type = "int-setting",
        name = "crate_stack_ratio",
        setting_type = "startup",
        default_value = 5,
        minimum_value = 1,
        maximum_value = 100,
    },
    -- {
    --     type = "int-setting",
    --     name = "crating_technology_tiers",
    --     setting_type = "startup",
    --     default_value = 1,
    --     minimum_value = 3,
    --     maximum_value = 10,
    -- },
    {
        type = "bool-setting",
        name = "vanilla_generation",
        setting_type = "startup",
        default_value = true
    }
}
)