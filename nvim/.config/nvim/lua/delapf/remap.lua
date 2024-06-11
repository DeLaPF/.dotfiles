vim.g.mapleader = " "
vim.keymap.set("i", "jk", "<Esc>")
vim.keymap.set("n", "<leader>g", "<C-w>")

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- greatest remap ever
vim.keymap.set("x", "<leader>p", [["_dP]])

-- next greatest remap ever : asbjornHaland
vim.keymap.set({"n", "v"}, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

vim.keymap.set({"n", "v"}, "<leader>d", [["_d]])

vim.keymap.set("n", "Q", "<nop>")
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)

vim.keymap.set("n", "<leader>qf", function()
    local qf_exists = false
    for _, win in pairs(vim.fn.getwininfo()) do
        if win["quickfix"] == 1 then
            qf_exists = true
        end
    end
    if qf_exists then
        vim.cmd "cclose"
    else
        vim.cmd "copen"
    end
end)
vim.keymap.set("n", "<leader>l", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<leader>h", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

vim.keymap.set("n", "<leader>s", [[/\<<C-r><C-w>\><CR>]])
vim.keymap.set("n", "<leader>/", "<cmd>set hls!<CR>")

vim.keymap.set("n", "_", "<C-o>zz")
vim.keymap.set("n", "+", "<C-i>zz")

vim.keymap.set("n", "<CR>", function()
    if (vim.v.count ~= 0) then
        return "G"
    else
        return "<CR>"
    end
end, { expr = true })

vim.keymap.set("n", "<leader>c", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })
vim.keymap.set("n", "<leader><leader>x", "<cmd>source %<CR>", { desc = "Execute the current file" })

-- Set local settings for terminal buffers
vim.api.nvim_create_autocmd("TermOpen", {
    pattern = { "*" },
    group = vim.api.nvim_create_augroup("custom-term-open", {}),
    callback = function()
        vim.opt_local.number = false
        vim.opt_local.relativenumber = false
        vim.opt_local.scrolloff = 0

        if vim.opt.buftype:get() == "terminal" then
            vim.cmd(":startinsert")
        end
    end,
})

-- Easily hit escape in terminal mode.
vim.keymap.set("t", "<esc>", "<c-\\><c-n>")
vim.keymap.set("t", "<leader>jk", "<cmd>:q<CR>")

-- Open a terminal at the bottom of the screen with a fixed height.
vim.keymap.set("n", "<leader>o", function()
    vim.cmd.new()
    vim.cmd.wincmd "J"
    vim.api.nvim_win_set_height(0, 12)
    vim.wo.winfixheight = true
    vim.cmd.term()
end)
