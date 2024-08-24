local function set_quit_noname()
    vim.keymap.set('n', 'q',
        function()
            local bufnr = vim.api.nvim_get_current_buf()
            if vim.api.nvim_buf_get_name(bufnr) == '' then
                vim.cmd('q')
            else
                vim.keymap.set('n', 'q', 'q')
            end
        end
    )
end

vim.api.nvim_create_user_command('TelescopeFindFile',
    function()
        require('telescope.builtin').find_files({ hidden = true })
        set_quit_noname()
    end,
{})
vim.api.nvim_create_user_command('TelescopeFindPattern',
    function()
        require('telescope.builtin').live_grep({ additional_args = { '--hidden' } })
        set_quit_noname()
    end,
{})
