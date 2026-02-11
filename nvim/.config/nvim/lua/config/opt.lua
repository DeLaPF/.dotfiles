vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- set to false if don't have nerd font
vim.g.have_nerd_font = true

-- numbering
vim.opt.nu = true
vim.opt.relativenumber = true

-- tab character handling
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true

-- disable wrapping (TODO: may want to enable this for certain file types)
vim.opt.wrap = false
vim.opt.colorcolumn = "80"
vim.opt.textwidth = 80

-- disable mouse
vim.opt.mouse = ""

-- undo handling
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.cache/nvim/undodir"
vim.opt.undofile = true

vim.opt.inccommand = "split"
vim.opt.smartcase = true
vim.opt.ignorecase = true

vim.opt.scrolloff = 16
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

-- Single most useful setting for editing cmd
vim.opt.cedit = "<TAB>"

-- Fix formatoptions (remove auto-commenting on new line)
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("FixFormatOptions", { clear = true }),
  pattern = "*", -- Apply to all filetypes
  callback = function()
    -- 1. Remove 'o' to stop comment continuation on 'o'/'O'
    vim.opt_local.formatoptions:remove("o")

    -- 2. Ensure 'c' is present (Wrap comments using textwidth)
    vim.opt_local.formatoptions:append("c")

    -- 3. Ensure 'r' is present (<Enter> to continue comments)
    -- vim.opt_local.formatoptions:append("r")
  end,
})
