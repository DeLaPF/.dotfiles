local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    vim.fn.system({
        'git',
        'clone',
        '--filter=blob:none',
        'https://github.com/folke/lazy.nvim.git',
        '--branch=stable', -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

local core = {
    {
        'nvim-telescope/telescope.nvim', tag = '0.1.5', -- or: branch = '0.1.x'
        dependencies = {'nvim-lua/plenary.nvim'},
    },
    {
        'nvim-tree/nvim-tree.lua',
        dependencies = {'nvim-tree/nvim-web-devicons'}, -- optional
    },
    {
        'stevearc/oil.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' }, -- optional
    },
    {
        'rose-pine/neovim',
        name = 'rose-pine',
        lazy = false, -- load during startup
        priority = 1000, -- load before all other start plugins (default: 50)
        config = function()
            vim.cmd('colorscheme rose-pine')
        end
    },
    {
        'olivercederborg/poimandres.nvim',
        name = 'poimandres',
        config = function()
            vim.cmd('colorscheme poimandres')
        end
    },
    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',

    },
    {'theprimeagen/harpoon'},
    {'mbbill/undotree'},
    {
        'VonHeikemen/lsp-zero.nvim',
        dependencies = {
            -- LSP Support
            {'neovim/nvim-lspconfig'},
            {
                'williamboman/mason.nvim',
                build = ':MasonUpdate',
            },
            {'williamboman/mason-lspconfig.nvim'},

            -- Autocompletion
            {'hrsh7th/nvim-cmp'},
            {'hrsh7th/cmp-buffer'},
            {'hrsh7th/cmp-path'},
            {'saadparwaiz1/cmp_luasnip'},
            {'hrsh7th/cmp-nvim-lsp'},
            {'hrsh7th/cmp-nvim-lua'},

            -- Snippets
            {'L3MON4D3/LuaSnip'},
            -- Snippet Collection (Optional)
            {'rafamadriz/friendly-snippets'},
        }
    },
    {
        'mfussenegger/nvim-dap',
        dependencies = {
            'rcarriga/nvim-dap-ui',
            'theHamsta/nvim-dap-virtual-text',
            'mfussenegger/nvim-dap-python',
            'nvim-neotest/nvim-nio',
        },
    },
}
local dev_plugins = {
    { dir = '~/dev/neovim/plugins/locr' },  -- plugins in development
}

local plugins = core
if vim.fn.empty(dev_plugins) ~= 1 then
    for _, v in ipairs(dev_plugins) do
        if (
            vim.fn.isdirectory(vim.fn.expand(v['import'])) == 1 or
            vim.fn.isdirectory(vim.fn.expand(v['dir'])) == 1
        ) then
            table.insert(plugins, v)
        end
    end
end

require('lazy').setup(plugins, {})
