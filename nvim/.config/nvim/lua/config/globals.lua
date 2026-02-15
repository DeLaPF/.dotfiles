MG = {}  -- [M]y [G]lobals

MG.combine_tables = function(...)
    local result = {}
    local args = { ... } -- Tables passed in (e.g., SHARED, NVIM)

    -- Loop through each input table
    for _, plugin_list in ipairs(args) do
        -- Loop through the contents of the current list and insert into the result
        for _, plugin_spec in ipairs(plugin_list) do
            table.insert(result, plugin_spec)
        end
    end
    return result
end
