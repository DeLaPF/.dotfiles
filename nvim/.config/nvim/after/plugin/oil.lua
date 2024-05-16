require('oil').setup({
    default_file_explorer = false,
})

vim.keymap.set('n', '-', '<CMD>Oil<CR>', { desc = 'Open parent directory' })
vim.keymap.set('n', '<leader><leader>q', require('oil').close)
