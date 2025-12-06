vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- numbering
vim.opt.nu = true
vim.opt.relativenumber = true

-- tab character handling
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true

-- disable wrapping (TODO: may want to enable this for certain file types)
vim.opt.wrap = false
vim.opt.colorcolumn = "80"

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
