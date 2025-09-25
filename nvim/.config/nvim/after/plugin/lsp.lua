local lsp_zero = require('lsp-zero')
lsp_zero.on_attach(function(_, bufnr)
	local opts = {buffer = bufnr, remap = false}

	vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
	vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
	vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
	--vim.keymap.set("n", "<leader>vws", vim.lsp.buf.workspace_symbol, opts)
	vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, opts)
	vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
	vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
	vim.keymap.set("i", "<leader>?", vim.lsp.buf.signature_help, opts)
end)
lsp_zero.setup({})

require('mason').setup({})
require('mason-lspconfig').setup({
    ensure_installed = {
        'pyright',
        'lua_ls',
    },
    handlers = {
        lsp_zero.default_setup,
    },
})

vim.lsp.enable('dartls')
vim.lsp.enable('luals')
vim.lsp.enable('zls')

local cmp = require('cmp')
local cmp_action = require('lsp-zero').cmp_action()
local cmp_format = require('lsp-zero').cmp_format()

cmp.setup({
    sources = {
        {name = 'nvim_lsp'},
        {name = 'buffer'},
    },
    mapping = cmp.mapping.preset.insert({
        ['<CR>'] = cmp.mapping.confirm({select = false}),
        ['<Tab>'] = cmp_action.tab_complete(),
        -- ['<S-Tab>'] = cmp_action.select_prev_or_fallback(),
    }),

    --- Show source name in completion menu
    formatting = cmp_format,
})
