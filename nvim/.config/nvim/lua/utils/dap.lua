local M = {}
M._default_args = {}
M._prev_args = {}
M._valid_requests = { launch=true, attach=true }
M.add_config = function(config, file_type, default_args)
    assert(config.name and config.name ~= '', '`name` must be specified')
    assert(config.type and config.type ~= '', '`type` (adapter) must be specified')
    assert(M._valid_requests[config.request], string.format('invalid `request`: %s', config.request))

    local name = config.name
    local program = config.program or '${file}'
    program = vim.fn.expand(vim.fn.trim(config.program), true)
    M._default_args[name] = default_args

    local new_config = vim.tbl_deep_extend('keep', {
        name = name,
        type = config.type,
        program = program,
        request = config.request,
        console = config.console or 'integratedTerminal',
        args = config.args or function()
            default_args = M._default_args[name] or {}
            local prev_args = M._prev_args[name] or {}
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
    }, config)

    local dap = require('dap')
    local configs = dap.configurations[file_type] or {}
    table.insert(configs, new_config)
    dap.configurations[file_type] = configs
end

return M
