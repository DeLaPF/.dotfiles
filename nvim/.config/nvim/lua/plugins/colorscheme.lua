if vim.g.vscode then
    return {}
end

return {
    "rose-pine/neovim",
    name = "rose-pine",
    priority = 1000, -- load before all other start plugins (default: 50)
    config = function()
        vim.cmd("colorscheme rose-pine")
    end
}
