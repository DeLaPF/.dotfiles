if vim.g.vscode then
  return {}
end

return {
  "nvim-telescope/telescope.nvim",
  event = "VimEnter",
  dependencies = {
    "nvim-lua/plenary.nvim",
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
      cond = function()
        return vim.fn.executable("make") == 1
      end,
    },
    "nvim-telescope/telescope-ui-select.nvim",
    { "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
  },
  config = function()
    local actions = require("telescope.actions")
    local builtin = require("telescope.builtin")
    local themes = require("telescope.themes")

    require("telescope").setup({
      defaults = {
        mappings = { n = { q = actions.close } },
      },
      pickers = {
        marks = {
          attach_mappings = function(prompt_bufnr, map)
            map("n", "dd", function()
              actions.delete_mark(prompt_bufnr)
            end)
            return true
          end,
        },
      },
      extensions = {
        ["ui-select"] = { themes.get_dropdown() },
      },
    })

    pcall(require("telescope").load_extension, "fzf")
    pcall(require("telescope").load_extension, "ui-select")

    local map = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { desc = desc })
    end

    map("n", "<leader>sf", function()
      builtin.find_files({ hidden = true })
    end, "[S]earch [F]iles")
    map("n", "<leader>sF", function()
      builtin.find_files({ no_ignore = true, hidden = true })
    end, "[S]earch all [F]iles")
    map("n", "<leader>sg", builtin.live_grep, "[S]earch by [G]rep")
    map("n", "<leader>sG", function()
      builtin.live_grep({ additional_args = { "--no-ignore", "--hidden" } })
    end, "[S]earch all by [G]rep")
    map("n", "<leader>sr", builtin.resume, "[S]earch [R]esume")
    map("n", "<leader><leader>", builtin.buffers, "Find existing buffers")
    map("n", "<leader>s.", builtin.oldfiles, "[S]earch recent files")
    map("n", "<leader>sh", builtin.help_tags, "[S]earch [H]elp")
    map("n", "<leader>sk", builtin.keymaps, "[S]earch [K]eymaps")
    map("n", "<leader>sm", function()
      builtin.marks({ mark_type = "global" })
    end, "[S]earch global [M]arks")
    map("n", "<leader>slm", function()
      builtin.marks({ mark_type = "local" })
    end, "[S]earch [L]ocal [M]arks")
    map(
      "n",
      "<leader>sc",
      builtin.command_history,
      "[S]earch [C]ommand history"
    )
    map("v", "<leader>s", builtin.grep_string, "[S]earch selection")
    map("n", "<leader>ss", builtin.builtin, "[S]earch [S]elect Telescope")
    map("n", "<leader>sd", builtin.diagnostics, "[S]earch [D]iagnostics")
    map("n", "<leader>/", function()
      builtin.current_buffer_fuzzy_find(themes.get_dropdown({
        winblend = 10,
        previewer = false,
      }))
    end, "Search current buffer")
    map("n", "<leader>s/", function()
      builtin.live_grep({
        grep_open_files = true,
        prompt_title = "Live Grep in Open Files",
      })
    end, "[S]earch open files")
    map("n", "<leader>sn", function()
      builtin.find_files({ cwd = vim.fn.stdpath("config") })
    end, "[S]earch [N]eovim files")
  end,
}
