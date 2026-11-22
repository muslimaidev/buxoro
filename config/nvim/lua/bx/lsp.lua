-- Til serverlari pacman orqali o'rnatiladi (install.sh):
--   texlab, lua-language-server, bash-language-server
vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      workspace = { library = { vim.env.VIMRUNTIME, "/usr/share/hypr/stubs" }, checkThirdParty = false },
      diagnostics = { globals = { "vim", "hl" } },
    },
  },
})

vim.lsp.config("texlab", {
  settings = {
    texlab = {
      build = { executable = "latexmk", args = { "-lualatex", "-interaction=nonstopmode", "-synctex=1", "%f" } },
      chktex = { onOpenAndSave = false },
    },
  },
})

vim.lsp.enable({ "lua_ls", "texlab", "bashls" })

vim.diagnostic.config({
  virtual_text = { spacing = 2, prefix = "●" },
  severity_sort = true,
  float = { border = "rounded" },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN]  = "",
      [vim.diagnostic.severity.INFO]  = "",
      [vim.diagnostic.severity.HINT]  = "󰌵",
    },
  },
})

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local map = function(keys, fn, desc)
      vim.keymap.set("n", keys, fn, { buffer = ev.buf, desc = desc })
    end
    map("gd", vim.lsp.buf.definition, "Ta'rifga o'tish")
    map("<leader>a", vim.lsp.buf.code_action, "Kod amallari")
    map("<leader>n", vim.lsp.buf.rename, "Nomini o'zgartirish")
    map("<leader>F", function() vim.lsp.buf.format({ async = true }) end, "Formatlash")
  end,
})
