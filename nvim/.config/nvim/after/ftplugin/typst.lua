-- Buffer-local typst maps under localleader ("\"). Normal-mode only.
-- LSP maps (grn/grd/gra/K/...) come for free via the LspAttach autocmd once
-- tinymist attaches (see lua/plugins/lsp.lua).
local map = function(lhs, rhs, desc)
  vim.keymap.set("n", lhs, rhs, { buffer = true, desc = "Typst: " .. desc })
end

-- Toggle the live preview.
map("<localleader>p", "<cmd>TypstPreviewToggle<cr>", "Preview toggle")

-- Export a PDF now (beside the source, same basename). tinymist also exports
-- on every save; this forces one on demand and reports failures inline.
map("<localleader>e", function()
  local file = vim.fn.expand("%:p")
  if file == "" then
    vim.notify("Typst: buffer has no file on disk", vim.log.levels.WARN)
    return
  end
  vim.cmd.write()
  vim.system({ "typst", "compile", file }, { text = true }, function(obj)
    vim.schedule(function()
      if obj.code == 0 then
        vim.notify(
          "Typst: exported " .. vim.fn.fnamemodify(file, ":r") .. ".pdf"
        )
      else
        vim.notify(
          "Typst export failed:\n" .. (obj.stderr or ""),
          vim.log.levels.ERROR
        )
      end
    end)
  end)
end, "Export PDF")

-- Open the compiled PDF with the system viewer.
map("<localleader>o", function()
  local pdf = vim.fn.expand("%:p:r") .. ".pdf"
  if vim.fn.filereadable(pdf) == 0 then
    vim.notify(
      "Typst: no PDF yet (export with <localleader>e or save)",
      vim.log.levels.WARN
    )
    return
  end
  vim.ui.open(pdf)
end, "Open compiled PDF")

-- Format via tinymist (typstyle).
map("<localleader>f", vim.lsp.buf.format, "Format")
