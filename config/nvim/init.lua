-- Buxoro — Neovim (0.11+). LaTeX uchun moslangan: VimTeX + texlab + Zathura.
vim.g.mapleader = " "
vim.g.maplocalleader = ","

require("bx.options")
require("bx.keymaps")
require("bx.lazy")
require("bx.lsp")
