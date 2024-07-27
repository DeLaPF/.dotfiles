-- TODO: How to exit neovim if file is not opened?

-- function del_buf(bufnr)
--     vim.api.nvim_buf_delete(bufnr, { force = true })
-- end
-- 
-- function print_table(table)
--     for k, v in pairs(table) do
--         print(k, v)
--     end
-- end

function close_empty()
    local buffers = vim.api.nvim_list_bufs()
    for _, bufnr in ipairs(buffers) do
        if vim.api.nvim_buf_is_loaded(bufnr) and
            vim.api.nvim_buf_get_option(bufnr, 'buftype') == ''
            -- vim.api.nvim_buf_get_option(bufnr, 'buftype') == 'nofile'
        then
            print('closing', bufnr)
            -- vim.cmd('q')
            vim.api.nvim_buf_delete(bufnr, { force = true })
        end
    end
end

function close_empty_unnamed_buffers()
    local buffers = vim.api.nvim_list_bufs()
    for _, bufnr in ipairs(buffers) do
        print(
            'bufnr:', bufnr,
            'name:', vim.api.nvim_buf_get_name(bufnr),
            'loaded:', vim.api.nvim_buf_is_loaded(bufnr),
            'option:', vim.api.nvim_buf_get_option(bufnr, 'buftype')
        )
        if vim.api.nvim_buf_is_loaded(bufnr) and
            vim.api.nvim_buf_get_name(bufnr) == '' and
            vim.api.nvim_buf_get_option(bufnr, 'buftype') == ''
        then
            local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
            local total_characters = 0
            for _, line in ipairs(lines) do
                total_characters = total_characters + #line
            end
            print('buf:', bufnr, 'total characters:', total_characters)

            if total_characters == 0 then
                print('Deleting Buffer:', bufnr)
                vim.api.nvim_buf_delete(bufnr, { force = true })
            end
        end
    end
end

vim.api.nvim_create_user_command('TelescopeFindFile',
    function()
        require('telescope.builtin').find_files({ hidden = true })
        vim.api.nvim_create_autocmd('BufEnter', {
            callback = function(args)
                -- close_empty_unnamed_buffers()
                -- close_no_file()
            end,
        })
    end,
{})
vim.api.nvim_create_user_command('TelescopeFindPattern',
    function()
        require('telescope.builtin').live_grep({ additional_args = { '--hidden' } })
        vim.api.nvim_create_autocmd('BufEnter', {
            callback = function(args)
                -- close_empty_unnamed_buffers()
            end,
        })
    end,
{})
