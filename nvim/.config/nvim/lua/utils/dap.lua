local M = {}
M.default_args = {}
M.prev_args = {}
M.add_config = function(
    name, adapter_type, file_type, program, request, default_args
)
    program = vim.fn.expand(vim.fn.trim(program), true)
    M.default_args[name] = default_args
    local new_config = {
        name = name,
        type = adapter_type,
        program = program,
        request = request,
        console = 'integratedTerminal',
        args = function()
            default_args = M.default_args[name] or {}
            local prev_args = M.prev_args[name] or {}
            local new_args = {}
            -- if next(prev_args) ~= nil then  -- prev is not empty
            if vim.fn.empty(prev_args) ~= 1 then
                local res = vim.fn.input(
                'Run previous (Y/n): ' .. program .. ' ' ..
                table.concat(default_args, ' ') .. ' ' ..
                table.concat(prev_args, ' ') .. ' '
                )
                if not res or res == '' then
                    new_args = prev_args
                end
            end
            if vim.fn.empty(new_args) == 1 then
                local args_string = vim.fn.input(
                program .. ' ' ..
                table.concat(default_args, ' ') .. ' '
                )
                new_args = vim.split(args_string, ' +')
            end
            M.prev_args[name] = new_args
            local merged = vim.fn.extend(default_args, new_args)
            print('Running: ' .. program .. ' ' .. table.concat(merged, ' '))
            return merged
        end,
    }
    local dap = require('dap')
    local configs = dap.configurations[file_type] or {}
    table.insert(configs, new_config)
    dap.configurations[file_type] = configs
end

return M
