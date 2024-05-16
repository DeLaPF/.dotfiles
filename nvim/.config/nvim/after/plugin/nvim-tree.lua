-- disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- set termguicolors to enable highlight groups
vim.opt.termguicolors = true

local api = require('nvim-tree.api')

require('nvim-tree').setup({
    sort = { sorter = 'case_sensitive' },
    view = { width = 30 },
    renderer = { group_empty = true },
    on_attach = function(bufnr)

        local function opts(desc)
            return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
        end

        -- default mappings
        api.config.mappings.default_on_attach(bufnr)

        -- custom mappings
        vim.keymap.set('n', '+', api.tree.change_root_to_node, opts('Move root to current'))
        vim.keymap.set('n', '_', api.tree.change_root_to_parent, opts('Move root to parent'))
        vim.keymap.set('n', '-', api.node.navigate.parent, opts('Focus parent'))
        -- vim.keymap.set('n', '<CR>', api.node.open.replace_tree_buffer, opts('Open: in place'))
        -- vim.keymap.set('n', '<leader><CR>', api.node.open.tab, opts('Open: new tab'))
        -- vim.keymap.set('n', '?', api.tree.toggle_help, opts('Help'))
    end,
})

vim.keymap.set('n', '<leader>pv', function()
    api.tree.toggle({ find_file = true, focus = true })
end)
