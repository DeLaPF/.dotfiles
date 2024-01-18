local telescope = require('telescope')
local actions = require('telescope.actions')
telescope.setup({
    defaults = {
        mappings = {
            n = {
                ['q'] = actions.close,
            },
        },
        file_ignore_patterns = {
            '.git',
            'node_modules', 'build', 'dist',
        },
    },
})

local builtin = require('telescope.builtin')
local utils = require('telescope.utils')
vim.keymap.set('n', '<leader>pf', function()
    builtin.find_files({ hidden = true })
end)
vim.keymap.set('n', '<leader>df', function()
    builtin.find_files({ hidden = true, cwd = utils.buffer_dir() })
end)
vim.keymap.set('n', '<leader>ps', function()
    builtin.live_grep({ additional_args = { '--hidden' } })
end)
vim.keymap.set('n', '<leader>ds', function()
    builtin.live_grep({ additional_args = { '--hidden' }, cwd = utils.buffer_dir() })
end)
vim.keymap.set('n', '<M-p>', builtin.git_files)
