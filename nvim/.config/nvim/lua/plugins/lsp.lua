return {
  {
    "pmizio/typescript-tools.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "neovim/nvim-lspconfig",
      "saghen/blink.cmp",
    },
    ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
    opts = function()
      return {
        capabilities = require("blink.cmp").get_lsp_capabilities(),
        settings = { tsserver_max_memory = 8192 },
      }
    end,
  },
  {
    -- Add Neovim's runtime and plugin APIs to lua_ls completion.
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      { "mason-org/mason.nvim", opts = {} },
      "mason-org/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      { "j-hui/fidget.nvim", opts = {} },
      "saghen/blink.cmp",
    },
    config = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup(
          "kickstart-lsp-attach",
          { clear = true }
        ),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            vim.keymap.set(mode or "n", keys, func, {
              buffer = event.buf,
              desc = "LSP: " .. desc,
            })
          end

          map("grn", vim.lsp.buf.rename, "[R]e[n]ame")
          map("<leader>vd", vim.diagnostic.open_float, "[V]iew [D]iagnostic")
          map(
            "gra",
            vim.lsp.buf.code_action,
            "[G]oto Code [A]ction",
            { "n", "x" }
          )
          map(
            "grr",
            require("telescope.builtin").lsp_references,
            "[G]oto [R]eferences"
          )
          map(
            "gri",
            require("telescope.builtin").lsp_implementations,
            "[G]oto [I]mplementation"
          )
          map(
            "grd",
            require("telescope.builtin").lsp_definitions,
            "[G]oto [D]efinition"
          )
          map("grD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
          map(
            "gO",
            require("telescope.builtin").lsp_document_symbols,
            "Open Document Symbols"
          )
          map(
            "gW",
            require("telescope.builtin").lsp_dynamic_workspace_symbols,
            "Open Workspace Symbols"
          )
          map(
            "grt",
            require("telescope.builtin").lsp_type_definitions,
            "[G]oto [T]ype Definition"
          )

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if
            client
            and client:supports_method(
              vim.lsp.protocol.Methods.textDocument_documentHighlight,
              event.buf
            )
          then
            local highlight_group = vim.api.nvim_create_augroup(
              "kickstart-lsp-highlight",
              { clear = false }
            )
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
              buffer = event.buf,
              group = highlight_group,
              callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
              buffer = event.buf,
              group = highlight_group,
              callback = vim.lsp.buf.clear_references,
            })
            vim.api.nvim_create_autocmd("LspDetach", {
              group = vim.api.nvim_create_augroup(
                "kickstart-lsp-detach",
                { clear = true }
              ),
              callback = function(detach_event)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds({
                  group = "kickstart-lsp-highlight",
                  buffer = detach_event.buf,
                })
              end,
            })
          end

          if
            client
            and client:supports_method(
              vim.lsp.protocol.Methods.textDocument_inlayHint,
              event.buf
            )
          then
            map("<leader>th", function()
              vim.lsp.inlay_hint.enable(
                not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf })
              )
            end, "[T]oggle Inlay [H]ints")
          end
        end,
      })

      vim.diagnostic.config({
        severity_sort = true,
        float = { border = "rounded", source = "if_many" },
        underline = { severity = vim.diagnostic.severity.ERROR },
        signs = vim.g.have_nerd_font and {
          text = {
            [vim.diagnostic.severity.ERROR] = "󰅚 ",
            [vim.diagnostic.severity.WARN] = "󰀪 ",
            [vim.diagnostic.severity.INFO] = "󰋽 ",
            [vim.diagnostic.severity.HINT] = "󰌶 ",
          },
        } or {},
        virtual_text = {
          source = "if_many",
          spacing = 2,
          format = function(diagnostic)
            return diagnostic.message
          end,
        },
      })

      local capabilities = require("blink.cmp").get_lsp_capabilities()
      local servers = {
        -- Export PDFs on save and use typstyle formatting.
        tinymist = {
          settings = {
            exportPdf = "onSave",
            formatterMode = "typstyle",
          },
        },
        lua_ls = {
          settings = {
            Lua = {
              completion = { callSnippet = "Replace" },
              -- Neovim injects this global into its Lua runtime.
              diagnostics = { globals = { "vim" } },
            },
          },
        },
      }

      local ensure_installed = vim.tbl_keys(servers)
      vim.list_extend(ensure_installed, { "stylua" })
      require("mason-tool-installer").setup({
        ensure_installed = ensure_installed,
      })

      -- Mason installs tools; Neovim configures and enables only this table.
      require("mason-lspconfig").setup({ automatic_enable = false })
      for server_name, server in pairs(servers) do
        server.capabilities = vim.tbl_deep_extend(
          "force",
          {},
          capabilities,
          server.capabilities or {}
        )
        vim.lsp.config(server_name, server)
      end
      vim.lsp.enable(vim.tbl_keys(servers))
    end,
  },
  {
    "saghen/blink.cmp",
    event = "VimEnter",
    version = "1.*",
    dependencies = {
      {
        "L3MON4D3/LuaSnip",
        version = "2.*",
        build = (function()
          if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
            return
          end
          return "make install_jsregexp"
        end)(),
        opts = {},
      },
      "folke/lazydev.nvim",
    },
    ---@module "blink.cmp"
    ---@type blink.cmp.Config
    opts = {
      keymap = { preset = "default" },
      appearance = { nerd_font_variant = "mono" },
      completion = {
        documentation = { auto_show = false, auto_show_delay_ms = 500 },
      },
      sources = {
        default = { "lsp", "path", "snippets", "lazydev" },
        providers = {
          lazydev = {
            module = "lazydev.integrations.blink",
            score_offset = 100,
          },
        },
      },
      snippets = { preset = "luasnip" },
      signature = { enabled = true },
    },
  },
}
