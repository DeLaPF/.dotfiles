require('oil').setup({
    default_file_explorer = false,
    view_options = {
        show_hidden = true,
    },
})

-- vim.keymap.set('n', '-', '<CMD>Oil<CR>', { desc = 'Open parent directory' })
-- using floating avoids adding to jump list
vim.keymap.set("n", "-", require("oil").toggle_float)
vim.keymap.set('n', '<leader><leader>q', require('oil').close)
