-- lazy.nvim — plagin menejeri (birinchi ochilishda o'zini o'rnatadi)
local path = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(path) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", path })
end
vim.opt.rtp:prepend(path)

require("lazy").setup({ { import = "bx.plugins" } }, {
  defaults = { lazy = true },
  install = { colorscheme = { "buxoro", "habamax" } },
  checker = { enabled = false },
  change_detection = { notify = false },
  ui = { border = "rounded" },
  performance = {
    rtp = {
      disabled_plugins = { "gzip", "tarPlugin", "tohtml", "tutor", "zipPlugin", "netrwPlugin" },
    },
  },
})

vim.cmd.colorscheme("buxoro")
