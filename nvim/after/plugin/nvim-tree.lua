-- disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- set termguicolors to enable highlight groups
vim.opt.termguicolors = true

require('nvim-tree').setup({
    sort = { sorter = 'case_sensitive' },
    view = { width = 30 },
    renderer = { group_empty = true },
})

local api = require('nvim-tree.api')
vim.keymap.set('n', '<leader>pv', function()
    api.tree.toggle({
        find_file = true,
        focus = true,
    })
end)
vim.keymap.set('n', '+', api.tree.change_root_to_node)
vim.keymap.set('n', '_', api.tree.change_root_to_parent)
-- TODO set '-' to focus parent dir in tree
