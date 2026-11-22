return {
  -- Sintaksis daraxti (yangi "main" tarmog'i, tree-sitter-cli kerak)
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").install({
        "bash", "c", "lua", "luadoc", "python", "markdown", "markdown_inline",
        "json", "toml", "yaml", "vim", "vimdoc", "query", "regex", "diff",
        "html", "css", "javascript", "bibtex",
      })
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(ev)
          if ev.match == "tex" then return end -- LaTeX ni VimTeX ranglaydi
          if pcall(vim.treesitter.start, ev.buf) then
            vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },

  -- LaTeX: kompilyatsiya, PDF ko'rish (Zathura), SyncTeX
  {
    "lervag/vimtex",
    lazy = false, -- VimTeX'ni kechiktirib yuklash tavsiya etilmaydi
    init = function()
      vim.g.vimtex_view_method = "zathura"
      vim.g.vimtex_compiler_method = "latexmk"
      vim.g.vimtex_compiler_latexmk_engines = { _ = "-lualatex" }
      vim.g.vimtex_quickfix_open_on_warning = 0
      vim.g.vimtex_syntax_conceal_disable = 0
      vim.g.vimtex_mappings_prefix = "<localleader>l"
    end,
  },

  -- Avtoto'ldirish (Rust'da yozilgan, juda tez)
  {
    "saghen/blink.cmp",
    version = "1.*",
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = { "rafamadriz/friendly-snippets" },
    opts = {
      keymap = { preset = "default", ["<CR>"] = { "accept", "fallback" } },
      appearance = { nerd_font_variant = "mono" },
      completion = {
        documentation = { auto_show = true, auto_show_delay_ms = 300 },
        menu = { draw = { treesitter = { "lsp" } } },
      },
      sources = { default = { "lsp", "path", "snippets", "buffer" } },
      signature = { enabled = true },
      fuzzy = { implementation = "prefer_rust_with_warning" },
    },
  },

  -- Til serverlari uchun tayyor sozlamalar
  { "neovim/nvim-lspconfig", lazy = false },

  -- Fayl, matn, bufer qidirish (fzf asosida — eng tez)
  {
    "ibhagwan/fzf-lua",
    cmd = "FzfLua",
    keys = {
      { "<leader>f", "<cmd>FzfLua files<cr>",                desc = "Fayllar" },
      { "<leader>g", "<cmd>FzfLua live_grep<cr>",            desc = "Matn qidirish" },
      { "<leader>b", "<cmd>FzfLua buffers<cr>",              desc = "Buferlar" },
      { "<leader>r", "<cmd>FzfLua oldfiles<cr>",             desc = "Oxirgi fayllar" },
      { "<leader>h", "<cmd>FzfLua helptags<cr>",             desc = "Yordam" },
      { "<leader>s", "<cmd>FzfLua lsp_document_symbols<cr>", desc = "Belgilar" },
      { "<leader>/", "<cmd>FzfLua blines<cr>",               desc = "Fayl ichida qidirish" },
    },
    opts = { "default-title", winopts = { border = "rounded", preview = { layout = "vertical" } } },
  },

  -- mini.nvim: holat qatori, fayl daraxti, juftliklar, ikonkalar
  {
    "nvim-mini/mini.nvim",
    lazy = false,
    config = function()
      require("mini.icons").setup()
      MiniIcons.mock_nvim_web_devicons()
      require("mini.statusline").setup()
      require("mini.pairs").setup()
      require("mini.surround").setup()
      require("mini.ai").setup()
      require("mini.files").setup({ windows = { preview = true, width_preview = 50 } })
      vim.keymap.set("n", "<leader>e", function()
        local p = vim.api.nvim_buf_get_name(0)
        MiniFiles.open(p ~= "" and p or nil)
      end,
        { desc = "Fayl menejeri" })
    end,
  },

  -- Git o'zgarishlari chap ustunda
  { "lewis6991/gitsigns.nvim", event = { "BufReadPre", "BufNewFile" }, opts = {} },

  -- Tugmalar bo'yicha yordamchi
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = { preset = "helix", delay = 400 },
  },
}
