if vim.g.vscode then
  return {}
end

return {
  -- Live preview (browser/window) that updates as you type.
  -- tinymist provides the LSP (completion/diagnostics/format/PDF-on-save);
  -- see the `tinymist` entry in lua/plugins/lsp.lua.
  "chomosuke/typst-preview.nvim",
  ft = "typst",
  version = "1.*",
  opts = {
    dependencies_bin = {
      -- Reuse the Tinymist managed by Mason instead of downloading another copy.
      tinymist = "tinymist",
    },
  },
}
