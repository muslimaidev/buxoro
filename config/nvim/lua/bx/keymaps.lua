local map = vim.keymap.set

map("n", "<Esc>", "<cmd>nohlsearch<cr>")
map("n", "<leader>w", "<cmd>write<cr>", { desc = "Saqlash" })
map("n", "<leader>q", "<cmd>quit<cr>", { desc = "Chiqish" })

-- Oynalar orasida harakat
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")

-- Buferlar
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Oldingi bufer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Keyingi bufer" })
map("n", "<leader>x", "<cmd>bdelete<cr>", { desc = "Buferni yopish" })

-- Belgilangan qatorlarni ko'chirish
map("v", "J", ":m '>+1<cr>gv=gv", { silent = true })
map("v", "K", ":m '<-2<cr>gv=gv", { silent = true })
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Diagnostika
map("n", "<leader>d", vim.diagnostic.open_float, { desc = "Xato tafsilotlari" })
