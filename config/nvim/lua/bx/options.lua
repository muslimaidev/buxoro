local o = vim.opt

o.number = true
o.relativenumber = true
o.signcolumn = "yes"
o.cursorline = true
o.termguicolors = true
o.mouse = "a"
o.clipboard = "unnamedplus"
o.undofile = true
o.swapfile = false
o.updatetime = 250
o.timeoutlen = 400
o.splitright = true
o.splitbelow = true
o.ignorecase = true
o.smartcase = true
o.expandtab = true
o.shiftwidth = 2
o.tabstop = 2
o.smartindent = true
o.wrap = false
o.linebreak = true
o.breakindent = true
o.scrolloff = 6
o.sidescrolloff = 8
o.showmode = false
o.laststatus = 3
o.pumheight = 12
o.winborder = "rounded"
o.fillchars = { eob = " ", fold = " " }
o.list = true
o.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
o.spelllang = { "en", "ru" }
o.confirm = true

-- Matnli fayllarda qatorni o'rash va imlo tekshiruvi
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "tex", "markdown", "text", "gitcommit" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

-- Nusxa olinganda qisqa yoritish
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function() vim.hl.on_yank({ timeout = 180 }) end,
})

-- Faylni qayta ochganda oxirgi joyga qaytish
vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function(ev)
    local mark = vim.api.nvim_buf_get_mark(ev.buf, '"')
    local lines = vim.api.nvim_buf_line_count(ev.buf)
    if mark[1] > 0 and mark[1] <= lines then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})
