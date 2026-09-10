local nvim = vim.g.vscode and {}
  or {
    {
      "stevearc/oil.nvim",
      dependencies = { "nvim-tree/nvim-web-devicons" },
      config = function()
        require("oil").setup({
          default_file_explorer = true,
          view_options = { show_hidden = true },
          keymaps = { q = "actions.close" },
        })
        -- Floating Oil buffers do not add entries to the jump list.
        vim.keymap.set("n", "-", require("oil").toggle_float)
      end,
    },
    {
      "lewis6991/gitsigns.nvim",
      opts = {
        signs = {
          add = { text = "+" },
          change = { text = "~" },
          delete = { text = "_" },
          topdelete = { text = "‾" },
          changedelete = { text = "~" },
        },
      },
    },
    {
      "folke/todo-comments.nvim",
      event = "VimEnter",
      dependencies = { "nvim-lua/plenary.nvim" },
      opts = { signs = false },
    },
  }

local shared = {
  {
    "echasnovski/mini.nvim",
    config = function()
      require("mini.ai").setup({ n_lines = 500 })
      require("mini.surround").setup()

      local statusline = require("mini.statusline")
      statusline.setup({ use_icons = vim.g.have_nerd_font })
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function()
        return "%2l:%-2v"
      end
    end,
  },
  {
    "mohseenrm/marko.nvim",
    priority = 1000,
    lazy = false,
    opts = {},
  },
}

return vim.list_extend(nvim, shared)
