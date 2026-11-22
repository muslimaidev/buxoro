-- Buxoro rang sxemasi. Ranglar lua/bx/palette.lua dan (bx-theme yaratadi).
package.loaded["bx.palette"] = nil
local ok, p = pcall(require, "bx.palette")
if not ok then
  p = { mode = "dark", bg = "#13111a", bg_alt = "#1a1723", surface = "#24202f", overlay = "#372f45",
    muted = "#7c7289", subtext = "#b9b0c5", fg = "#eee7f3", accent = "#3cc4b4", accent2 = "#d4835a",
    gold = "#e8b84e", red = "#e46c6c", green = "#9dd08a", yellow = "#eecb7c", purple = "#ab8ce8", orange = "#f0a160" }
end

vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") == 1 then vim.cmd("syntax reset") end
vim.o.background = p.mode == "light" and "light" or "dark"
vim.g.colors_name = "buxoro"

local hl = function(group, spec) vim.api.nvim_set_hl(0, group, spec) end

local groups = {
  -- Muharrir
  Normal       = { fg = p.fg, bg = p.bg },
  NormalNC     = { fg = p.fg, bg = p.bg },
  NormalFloat  = { fg = p.fg, bg = p.bg_alt },
  FloatBorder  = { fg = p.overlay, bg = p.bg_alt },
  FloatTitle   = { fg = p.accent, bg = p.bg_alt, bold = true },
  Cursor       = { fg = p.bg, bg = p.accent },
  CursorLine   = { bg = p.bg_alt },
  CursorLineNr = { fg = p.gold, bold = true },
  LineNr       = { fg = p.overlay },
  SignColumn   = { bg = p.bg },
  ColorColumn  = { bg = p.bg_alt },
  VertSplit    = { fg = p.overlay },
  WinSeparator = { fg = p.overlay },
  Visual       = { bg = p.overlay },
  Search       = { fg = p.bg, bg = p.gold },
  IncSearch    = { fg = p.bg, bg = p.accent },
  CurSearch    = { fg = p.bg, bg = p.accent },
  MatchParen   = { fg = p.gold, bold = true, underline = true },
  Pmenu        = { fg = p.subtext, bg = p.bg_alt },
  PmenuSel     = { fg = p.fg, bg = p.surface, bold = true },
  PmenuSbar    = { bg = p.surface },
  PmenuThumb   = { bg = p.overlay },
  StatusLine   = { fg = p.subtext, bg = p.bg_alt },
  StatusLineNC = { fg = p.muted, bg = p.bg_alt },
  TabLine      = { fg = p.muted, bg = p.bg_alt },
  TabLineSel   = { fg = p.fg, bg = p.surface, bold = true },
  TabLineFill  = { bg = p.bg_alt },
  WinBar       = { fg = p.subtext, bg = p.bg },
  Folded       = { fg = p.muted, bg = p.bg_alt },
  NonText      = { fg = p.overlay },
  Whitespace   = { fg = p.overlay },
  SpecialKey   = { fg = p.overlay },
  EndOfBuffer  = { fg = p.bg },
  Directory    = { fg = p.accent2 },
  Title        = { fg = p.accent, bold = true },
  ErrorMsg     = { fg = p.red, bold = true },
  WarningMsg   = { fg = p.orange },
  MoreMsg      = { fg = p.green },
  Question     = { fg = p.accent },
  SpellBad     = { undercurl = true, sp = p.red },
  SpellCap     = { undercurl = true, sp = p.yellow },
  SpellRare    = { undercurl = true, sp = p.purple },
  SpellLocal   = { undercurl = true, sp = p.accent },

  -- Sintaksis
  Comment      = { fg = p.muted, italic = true },
  Constant     = { fg = p.orange },
  String       = { fg = p.green },
  Character    = { fg = p.green },
  Number       = { fg = p.orange },
  Boolean      = { fg = p.orange },
  Float        = { fg = p.orange },
  Identifier   = { fg = p.fg },
  Function     = { fg = p.accent2 },
  Statement    = { fg = p.purple },
  Keyword      = { fg = p.purple },
  Conditional  = { fg = p.purple },
  Repeat       = { fg = p.purple },
  Operator     = { fg = p.accent },
  Exception    = { fg = p.red },
  PreProc      = { fg = p.gold },
  Include      = { fg = p.purple },
  Type         = { fg = p.gold },
  Special      = { fg = p.accent },
  Delimiter    = { fg = p.subtext },
  Underlined   = { underline = true },
  Error        = { fg = p.red },
  Todo         = { fg = p.bg, bg = p.gold, bold = true },

  -- Treesitter
  ["@variable"]            = { fg = p.fg },
  ["@variable.builtin"]    = { fg = p.red },
  ["@variable.parameter"]  = { fg = p.subtext },
  ["@variable.member"]     = { fg = p.accent },
  ["@property"]            = { fg = p.accent },
  ["@function.builtin"]    = { fg = p.accent },
  ["@constructor"]         = { fg = p.gold },
  ["@keyword.return"]      = { fg = p.red },
  ["@punctuation.bracket"] = { fg = p.subtext },
  ["@tag"]                 = { fg = p.purple },
  ["@tag.attribute"]       = { fg = p.gold },
  ["@markup.heading"]      = { fg = p.accent, bold = true },
  ["@markup.strong"]       = { bold = true },
  ["@markup.italic"]       = { italic = true },
  ["@markup.link"]         = { fg = p.accent2, underline = true },
  ["@markup.raw"]          = { fg = p.green },

  -- LaTeX (VimTeX)
  texCmd            = { fg = p.purple },
  texCmdEnv         = { fg = p.purple, bold = true },
  texEnvArgName     = { fg = p.gold },
  texPartArgTitle   = { fg = p.accent, bold = true },
  texMathZone       = { fg = p.accent },
  texMathDelimZone  = { fg = p.gold },
  texMathCmd        = { fg = p.accent2 },
  texRefArg         = { fg = p.green },
  texFileArg        = { fg = p.green },

  -- Diagnostika
  DiagnosticError = { fg = p.red },
  DiagnosticWarn  = { fg = p.orange },
  DiagnosticInfo  = { fg = p.accent2 },
  DiagnosticHint  = { fg = p.accent },
  DiagnosticOk    = { fg = p.green },
  DiagnosticUnderlineError = { undercurl = true, sp = p.red },
  DiagnosticUnderlineWarn  = { undercurl = true, sp = p.orange },
  DiagnosticUnderlineInfo  = { undercurl = true, sp = p.accent2 },
  DiagnosticUnderlineHint  = { undercurl = true, sp = p.accent },

  -- Git
  DiffAdd    = { fg = p.green },
  DiffChange = { fg = p.yellow },
  DiffDelete = { fg = p.red },
  Added      = { fg = p.green },
  Changed    = { fg = p.yellow },
  Removed    = { fg = p.red },
  GitSignsAdd    = { fg = p.green },
  GitSignsChange = { fg = p.yellow },
  GitSignsDelete = { fg = p.red },

  -- mini.statusline
  MiniStatuslineModeNormal  = { fg = p.bg, bg = p.accent, bold = true },
  MiniStatuslineModeInsert  = { fg = p.bg, bg = p.green, bold = true },
  MiniStatuslineModeVisual  = { fg = p.bg, bg = p.purple, bold = true },
  MiniStatuslineModeReplace = { fg = p.bg, bg = p.red, bold = true },
  MiniStatuslineModeCommand = { fg = p.bg, bg = p.gold, bold = true },
  MiniStatuslineModeOther   = { fg = p.bg, bg = p.accent2, bold = true },
  MiniStatuslineDevinfo     = { fg = p.subtext, bg = p.surface },
  MiniStatuslineFilename    = { fg = p.subtext, bg = p.bg_alt },
  MiniStatuslineFileinfo    = { fg = p.subtext, bg = p.surface },
  MiniStatuslineInactive    = { fg = p.muted, bg = p.bg_alt },

  -- blink.cmp va which-key
  BlinkCmpMenuBorder       = { fg = p.overlay, bg = p.bg_alt },
  BlinkCmpLabelMatch       = { fg = p.accent, bold = true },
  BlinkCmpKind             = { fg = p.gold },
  WhichKey                 = { fg = p.accent },
  WhichKeyGroup            = { fg = p.purple },
  WhichKeyDesc             = { fg = p.subtext },
  FzfLuaBorder             = { fg = p.overlay },
}

for group, spec in pairs(groups) do hl(group, spec) end

-- Terminal ranglari (:terminal)
local term = { p.surface, p.red, p.green, p.yellow, p.accent2, p.purple, p.accent, p.subtext,
  p.muted, p.red, p.green, p.gold, p.accent2, p.purple, p.accent, p.fg }
for i, c in ipairs(term) do vim.g["terminal_color_" .. (i - 1)] = c end
