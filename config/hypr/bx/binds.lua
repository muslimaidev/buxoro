local V = require("bx.vars")
local U = require("bx.util")
local mod = V.mod
local b = U.bind

U.reset()

-- ── Dasturlar ────────────────────────────────────────────────────────
b(mod .. " + Return",      hl.dsp.exec_cmd(V.terminal),  "Terminal (foot)")
b(mod .. " + D",           hl.dsp.exec_cmd(V.launcher),  "Dasturlar menyusi (fuzzel)")
b(mod .. " + E",           hl.dsp.exec_cmd(V.files),     "Fayl menejeri (yazi)")
b(mod .. " + SHIFT + E",   hl.dsp.exec_cmd(V.files_gui), "Grafik fayl menejeri (Thunar)")
b(mod .. " + B",           hl.dsp.exec_cmd(V.browser),   "Brauzer")
b(mod .. " + SHIFT + Return", hl.dsp.exec_cmd(V.editor), "Neovim")
b(mod .. " + CTRL + Escape",  hl.dsp.exec_cmd(V.monitor), "Tizim monitori (btop)")
b(mod .. " + C",           hl.dsp.exec_cmd("bx-clip"),   "Bufer tarixi")
b(mod .. " + period",      hl.dsp.exec_cmd("bx-emoji"),  "Emoji va belgilar")
b(mod .. " + slash",       hl.dsp.exec_cmd("bx-keys"),   "Shu ro'yxat")
b(mod .. " + ALT + space", hl.dsp.exec_cmd("bx-menu"),   "Buxoro menyusi (hamma narsa bir joyda)")

-- ── Oynalar ──────────────────────────────────────────────────────────
b(mod .. " + Q",           hl.dsp.window.close(),       "Oynani yopish")
b(mod .. " + SHIFT + Q",   hl.dsp.window.kill(),        "Oynani majburan yopish")
b(mod .. " + F",           hl.dsp.window.fullscreen({ action = "toggle", mode = "fullscreen" }), "To'liq ekran")
b(mod .. " + M",           hl.dsp.window.fullscreen({ action = "toggle", mode = "maximized" }),  "Kattalashtirish (panel ko'rinadi)")
b(mod .. " + V", function()
    hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
    hl.dispatch(hl.dsp.window.center())
end, "Suzuvchi / joylashtirilgan")
b(mod .. " + SHIFT + P",   hl.dsp.window.pin({ action = "toggle" }), "Barcha ish stollariga qadash")
b(mod .. " + P",           hl.dsp.window.pseudo(),      "Psevdo-joylashuv")
b(mod .. " + O",           hl.dsp.layout("togglesplit"), "Bo'linish yo'nalishini almashtirish")
b(mod .. " + G",           hl.dsp.group.toggle(),       "Guruh (tablar) yaratish/bekor qilish")
b(mod .. " + bracketright", hl.dsp.group.next(),        "Guruhda keyingi oyna")
b(mod .. " + bracketleft",  hl.dsp.group.prev(),        "Guruhda oldingi oyna")
b("ALT + Tab", function()
    hl.dispatch(hl.dsp.window.cycle_next())
    hl.dispatch(hl.dsp.window.alter_zorder({ mode = "top" }))
end, "Oynalar orasida aylanish")

-- Fokus, ko'chirish, o'lcham: strelkalar yoki h/j/k/l (Vim uslubi)
local dirs = {
    { "left",  "h", -40,   0 },
    { "right", "l",  40,   0 },
    { "up",    "k",   0, -40 },
    { "down",  "j",   0,  40 },
}
for _, d in ipairs(dirs) do
    local name, vim, dx, dy = d[1], d[2], d[3], d[4]
    for _, key in ipairs({ name, vim }) do
        hl.bind(mod .. " + " .. key,           hl.dsp.focus({ direction = name }))
        hl.bind(mod .. " + SHIFT + " .. key,   hl.dsp.window.move({ direction = name }))
        hl.bind(mod .. " + CTRL + " .. key,    hl.dsp.window.resize({ x = dx, y = dy, relative = true }), { repeating = true })
    end
end
U.note(mod .. " + ←↓↑→ / H J K L",         "Fokusni ko'chirish")
U.note(mod .. " + SHIFT + ←↓↑→ / H J K L", "Oynani ko'chirish")
U.note(mod .. " + CTRL + ←↓↑→ / H J K L",  "Oyna o'lchamini o'zgartirish")

hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
U.note(mod .. " + sichqoncha (chap/o'ng)", "Oynani sudrash / o'lchamini o'zgartirish")

-- ── Ish stollari ─────────────────────────────────────────────────────
for i = 1, 10 do
    local key = i % 10
    hl.bind(mod .. " + " .. key,          hl.dsp.focus({ workspace = i }))
    hl.bind(mod .. " + SHIFT + " .. key,  hl.dsp.window.move({ workspace = i }))
    hl.bind(mod .. " + CTRL + " .. key,   hl.dsp.window.move({ workspace = i, follow = false }))
end
U.note(mod .. " + 1…0",         "Ish stoliga o'tish")
U.note(mod .. " + SHIFT + 1…0", "Oynani ish stoliga ko'chirish (birga o'tish)")
U.note(mod .. " + CTRL + 1…0",  "Oynani ish stoliga jimgina yuborish")

b(mod .. " + Tab",         hl.dsp.focus({ workspace = "previous" }), "Oldingi ish stoli")
b(mod .. " + grave",       hl.dsp.workspace.toggle_special("scratch"), "Yashirin ish stoli (scratchpad)")
b(mod .. " + SHIFT + grave", hl.dsp.window.move({ workspace = "special:scratch" }), "Oynani yashirin ish stoliga")
hl.bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- ── Tizim ────────────────────────────────────────────────────────────
b(mod .. " + X",           hl.dsp.exec_cmd("bx-power"),              "Quvvat menyusi")
b(mod .. " + ALT + L",     hl.dsp.exec_cmd("loginctl lock-session"), "Ekranni qulflash")
b(mod .. " + SHIFT + R",   hl.dsp.reload_config(),                   "Hyprland konfiguratsiyasini qayta yuklash")
b(mod .. " + ALT + B",     hl.dsp.exec_cmd("pkill -SIGUSR1 waybar"), "Panelni yashirish/ko'rsatish")
b(mod .. " + SHIFT + T",   hl.dsp.exec_cmd("bx-picker theme"),       "Mavzular galereyasi (fon rasmidan avtomatik ham)")
b(mod .. " + ALT + T",     hl.dsp.exec_cmd("bx-theme toggle"),       "Mavzu: tungi ↔ kunduzgi")
b(mod .. " + W",           hl.dsp.exec_cmd("bx-picker wallpaper"),   "Fon rasmlari galereyasi")
b(mod .. " + SHIFT + W",   hl.dsp.exec_cmd("bx-wall next"),          "Keyingi fon rasmi")
b(mod .. " + ALT + W",     hl.dsp.exec_cmd("bx-wall random"),        "Tasodifiy fon rasmi")
b(mod .. " + ALT + N",     hl.dsp.exec_cmd("bx-nightlight"),         "Tungi yorug'lik (ko'z uchun)")
b(mod .. " + ALT + P",     hl.dsp.exec_cmd("hyprpicker -a -f hex"),  "Ekrandan rang olish")

-- Bildirishnomalar markazi (swaync)
b(mod .. " + N",           hl.dsp.exec_cmd("swaync-client -t -sw"),  "Boshqaruv markazi / bildirishnomalar")
b(mod .. " + SHIFT + N",   hl.dsp.exec_cmd("swaync-client -C -sw"),  "Bildirishnomalarni tozalash")
b(mod .. " + ALT + D",     hl.dsp.exec_cmd("swaync-client -d -sw"),  "Bezovta qilmaslik rejimi")
b(mod .. " + ALT + R",     hl.dsp.exec_cmd("bx-printer menu"),       "Printer menyusi")

-- O'yin rejimi: animatsiya, xiralik va soyalarni o'chirib, maksimal FPS
b(mod .. " + ALT + G",     hl.dsp.exec_cmd("bx-gamemode"),           "O'yin rejimi (effektlarsiz)")

-- ── Skrinshotlar ─────────────────────────────────────────────────────
b("Print",                 hl.dsp.exec_cmd("bx-shot region"), "Skrinshot: hudud")
b("SHIFT + Print",         hl.dsp.exec_cmd("bx-shot screen"), "Skrinshot: butun ekran")
b(mod .. " + Print",       hl.dsp.exec_cmd("bx-shot edit"),   "Skrinshot: hudud + tahrirlash")
b(mod .. " + SHIFT + S",   hl.dsp.exec_cmd("bx-shot region"), "Skrinshot: hudud")
b(mod .. " + ALT + Print",  hl.dsp.exec_cmd("bx-record region"), "Ekran yozuvi: hudud (qayta bosish — to'xtatish)")
b(mod .. " + CTRL + Print", hl.dsp.exec_cmd("bx-record screen"), "Ekran yozuvi: butun ekran")

-- ── Multimedia tugmalari (ekran qulflangan bo'lsa ham ishlaydi) ──────
-- SwayOSD ekranda chiroyli ko'rsatkich chiqaradi
local media = { locked = true, repeating = true }
local osd = "swayosd-client "
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd(osd .. "--output-volume raise --max-volume 150"), media)
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd(osd .. "--output-volume lower"),  media)
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd(osd .. "--output-volume mute-toggle"), { locked = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd(osd .. "--input-volume mute-toggle"),  { locked = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd(osd .. "--brightness raise"), media)
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(osd .. "--brightness lower"), media)
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd(osd .. "--playerctl next"),       { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd(osd .. "--playerctl previous"),   { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd(osd .. "--playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd(osd .. "--playerctl play-pause"), { locked = true })
U.note("Fn + ovoz / yorug'lik tugmalari", "Ovoz, mikrofon va yorug'lik (ekranda ko'rsatkich bilan)")

U.write_sheet()
