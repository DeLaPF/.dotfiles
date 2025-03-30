local lsp_zero = require('lsp-zero')
lsp_zero.preset('recommended')
lsp_zero.on_attach(function(_, bufnr)
	local opts = {buffer = bufnr, remap = false}

	vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
	vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
	vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
	--vim.keymap.set("n", "<leader>vws", vim.lsp.buf.workspace_symbol, opts)
	vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, opts)
	vim.keymap.set("n", "[d", vim.diagnostic.goto_next, opts)
	vim.keymap.set("n", "]d", vim.diagnostic.goto_prev, opts)
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

-- Additional lsp setup
-- require('lspconfig').gopls.setup({})
local lsp_config = require('lspconfig')

-- Lua (copied from neovim-lspconfig/doc/server_configurations.md)
lsp_config['lua_ls'].setup({
    on_init = function(client)
        local path = client.workspace_folders[1].name
        if (vim.uv or vim.loop).fs_stat(path..'/.luarc.json') or (vim.uv or vim.loop).fs_stat(path..'/.luarc.jsonc') then
            return
        end

        client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
            runtime = {
                -- Tell the language server which version of Lua you're using
                -- (most likely LuaJIT in the case of Neovim)
                version = 'LuaJIT'
            },
            -- Make the server aware of Neovim runtime files
            workspace = {
                checkThirdParty = false,
                library = {
                    vim.env.VIMRUNTIME,
                    -- Depending on the usage, you might want to add additional paths here.
                    "${3rd}/luv/library",  -- fixes fs_stat warning
                    -- "${3rd}/busted/library",
                }
                -- or pull in all of 'runtimepath'. NOTE: this is a lot slower
                -- library = vim.api.nvim_get_runtime_file("", true)
            }
        })
    end,
    settings = {
        Lua = {}
    }
})

-- Dart
lsp_config['dartls'].setup({
    settings = {
        dart = {
            analysisExcludedFolders = {},
        },
    },
})

-- Zig (zls managed by zvm)
lsp_config['zls'].setup({})

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
        ['<S-Tab>'] = cmp_action.select_prev_or_fallback(),
    }),

    --- Show source name in completion menu
    formatting = cmp_format,
})
