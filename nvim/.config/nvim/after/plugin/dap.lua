local dap = require('dap')
local ui = require('dapui')
local vt = require('nvim-dap-virtual-text')

ui.setup({})
vt.setup({})

vim.keymap.set('n', '<leader>b', dap.toggle_breakpoint)
vim.keymap.set('n', '<leader>gb', dap.run_to_cursor)
vim.keymap.set('n', '<leader>dc', dap.continue)
vim.keymap.set('n', '<leader>do', dap.step_over)
vim.keymap.set('n', '<leader>di', dap.step_into)
vim.keymap.set('n', '<leader>db', dap.step_back)
vim.keymap.set('n', '<leader>dr', dap.run_last)
vim.keymap.set('n', '<leader>dd', dap.terminate)
vim.keymap.set('n', '<leader>du', ui.toggle)
vim.keymap.set('n', '<leader>?', function()
    ui.eval(nil, { enter = true })
end)

local function get_buf_tail()
    local buf_name = vim.api.nvim_buf_get_name(0)
    if not buf_name then
        return nil
    end
    return string.match(buf_name, '[^\\/]+$')
end

vim.keymap.set('n', 'p', function()
    local buf_tail = get_buf_tail()
    if not buf_tail then
        return 'p'
    end

    local is_dap_repl = string.match(buf_tail, '^%[dap%-repl%-[0-9]*%]$') ~= nil
    if not is_dap_repl then
        return 'p'
    end

    local first_line = vim.split(vim.fn.getreg('"'), '\n')[1]
    if not first_line then
        return ''
    end
    return 'i' .. first_line .. '\n' .. '<ESC>'
end, { expr = true })

-- Auto open/close dapui
dap.listeners.before.attach.dapui_config = ui.open
dap.listeners.before.launch.dapui_config = ui.open
dap.listeners.before.event_terminated.dapui_config = ui.close
dap.listeners.before.event_exited.dapui_config = ui.close

dap.adapters.debugpy = {
    type = 'executable',
    command = 'python',
    args = { '-m', 'debugpy.adapter' },
}

-- Python
require('dap-python').setup('python')
