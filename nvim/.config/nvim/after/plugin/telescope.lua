local telescope = require('telescope')
local actions = require('telescope.actions')
local builtin = require('telescope.builtin')
local utils = require('telescope.utils')
telescope.setup({
    defaults = {
        mappings = {
            n = {
                ['q'] = actions.close,
                -- ['<leader>sq'] = actions.smart_send_to_qflist + actions.open_qflist,
                ['<leader>sq'] = function(prompt_bufnr)
                    actions.smart_send_to_qflist(prompt_bufnr)
                    actions.open_qflist(prompt_bufnr)
                    -- print(prompt_bufnr)
                    -- print(vim.fn.getqflist())
                    -- builtin.quickfix({ nr = vim.fn.getqflist() })
                    -- builtin.quickfix({ id = vim.fn.getqflist() })
                    -- builtin.quickfix({ show_line = true, trim_text = false })
                    -- builtin.quickfix({ show_line = true, trim_text = false, nr = vim.fn.getqflist() })
                    -- builtin.quickfixhistory()
                end,
            },
        },
        file_ignore_patterns = {
            '.git',
            'node_modules', 'build', 'dist',
        },
    },
})

vim.keymap.set('n', '<leader>pf', function()
    builtin.find_files({ hidden = true })
end)
vim.keymap.set('n', '<leader>df', function()
    builtin.find_files({ hidden = true, cwd = Cwd() })
end)
vim.keymap.set('n', '<leader>ps', function()
    builtin.live_grep({ additional_args = { '--hidden' } })
end)
vim.keymap.set('n', '<leader>ds', function()
    builtin.live_grep({ additional_args = { '--hidden' }, cwd = Cwd() })
end)
vim.keymap.set('n', '<M-p>', builtin.git_files)
vim.keymap.set('n', '<leader>tr', builtin.resume)
-- vim.keymap.set('n', '<leader>tq', builtin.quickfix)

function Cwd()
    local buf_dir = utils.buffer_dir()
    -- TODO: make work with oil as well
    local lib = require('nvim-tree.lib')
    if not lib then
        return buf_dir
    end
    print('lib exists')

    local node = lib.get_node_at_cursor()
    if not node then
        return buf_dir
    end
    print(node.absolute_path)

    return node.absolute_path
end
