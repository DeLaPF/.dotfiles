require('oil').setup({
    default_file_explorer = true,
    view_options = {
        show_hidden = true,
    },
    keymaps = {
        ['q'] = 'actions.close',
    }
})

-- using floating avoids adding to jump list
vim.keymap.set('n', '-', require('oil').toggle_float)
