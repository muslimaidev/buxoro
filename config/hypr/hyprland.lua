--  ┏┓ ╻ ╻╻ ╻┏━┓┏━┓┏━┓
--  ┣┻┓┃ ┃┏╋┛┃ ┃┣┳┛┃ ┃
--  ┗━┛┗━┛╹ ╹┗━┛╹┗╸┗━┛   Hyprland (Lua, 0.55+)
--
--  Har bir bo'lim alohida faylda (bx/ papkasi). Biror faylda xato bo'lsa,
--  qolganlari baribir yuklanadi — Hyprland har bir require() ni alohida
--  "scope"da bajaradi.
--
--  Ranglar: theme/colors.lua (bx-theme tomonidan avtomatik yaratiladi).
--  Shaxsiy o'zgarishlar: user.lua (gitga kirmaydi, ixtiyoriy).

require("bx.env")        -- muhit o'zgaruvchilari, GPU tanlash
require("bx.monitors")   -- monitorlar
require("bx.look")       -- ko'rinish, animatsiyalar
require("bx.input")      -- klaviatura, sensorli panel, imo-ishoralar
require("bx.rules")      -- oyna va qatlam qoidalari
require("bx.binds")      -- tezkor tugmalar
require("bx.autostart")  -- avtoishga tushirish

-- Shaxsiy sozlamalar (monitorlar, qo'shimcha tugmalar va h.k.)
local ok, err = pcall(require, "user")
if not ok and not tostring(err):find("not found") then
    print("[buxoro] user.lua xatosi: " .. tostring(err))
end
