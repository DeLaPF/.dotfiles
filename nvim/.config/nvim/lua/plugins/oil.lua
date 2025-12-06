if vim.g.vscode then
    return {}
end

return {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" }, -- optional
    config = function()
        require("oil").setup({
            default_file_explorer = true,
            view_options = {
                show_hidden = true,
            },
            keymaps = {
                ["q"] = "actions.close",
            }
        })

        -- using floating avoids adding to jump list
        vim.keymap.set("n", "-", require("oil").toggle_float)
    end
}
