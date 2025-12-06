vim.keymap.set("i", "jk", "<Esc>")
vim.keymap.set("n", "<leader>g", "<C-w>")

-- when not using oil
-- vim.keymap.set("n", "-", "<cmd>Ex<CR>")

-- navigation
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "+", "<C-i>zz", { desc = "Jumplist forward" })
vim.keymap.set("n", "_", "<C-o>zz", { desc = "Jumplist back" })
vim.keymap.set("n", "<CR>", function()
    if (vim.v.count ~= 0) then
        return "G"
    else
        return "<CR>"
    end
end, { desc = "Jump to line", expr = true })

-- yanking
vim.keymap.set({"n", "v"}, "<leader>y", [["+y]], { desc = "Yank to system clipboard" })
vim.keymap.set("n", "<leader>Y", [["+Y]], { desc = "Yank line to system clipboard" })
vim.keymap.set("x", "<leader>p", [["_dP]], { desc = "Paste to selection without yank" })
vim.keymap.set({"n", "v"}, "<leader>d", [["_d]], { desc = "Delete without yank" })

-- toggle and navigate quickfix list entries
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

-- searching
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Un-highlight search" })
vim.keymap.set("n", "<leader>s", [[/\<<C-r><C-w>\><CR>]], { desc = "Search hovered word" })
vim.keymap.set("n", "<leader>c", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Change all occurances of hovered word" })

vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { desc = "Make file executable", silent = true })
vim.keymap.set("n", "<leader><leader>x", "<cmd>source %<CR>", { desc = "Execute the current file" })
