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
local undodir = vim.fn.stdpath("cache") .. "/undodir"
vim.fn.mkdir(undodir, "p")
vim.opt.undodir = undodir
vim.opt.undofile = true

vim.opt.inccommand = "split"
vim.opt.smartcase = true
vim.opt.ignorecase = true

vim.opt.scrolloff = 16
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

-- Single most useful setting for editing cmd
vim.opt.cedit = "<TAB>"

-- Keep comment wrapping, but do not insert a comment leader after o/O.
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("FixFormatOptions", { clear = true }),
  pattern = "*",
  callback = function()
    vim.opt_local.formatoptions:remove("o")
    vim.opt_local.formatoptions:append("c")
  end,
})

-- auto reload files
vim.o.autoread = true
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
  command = "checktime",
})
