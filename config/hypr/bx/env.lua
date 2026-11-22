local U = require("bx.util")

-- bx-* skriptlari ~/.local/bin da. Arch uni PATH ga standart qo'shmaydi, shuning uchun
-- tugmalar, panel va bildirishnomalar markazidagi buyruqlar topilishi uchun qo'shamiz.
do
    local home = os.getenv("HOME") or ""
    local path = os.getenv("PATH") or "/usr/local/bin:/usr/bin"
    local bin = home .. "/.local/bin"
    if not (":" .. path .. ":"):find(":" .. bin .. ":", 1, true) then
        hl.env("PATH", bin .. ":" .. path)
    end
end

-- Kursor
hl.env("XCURSOR_THEME", "Bibata-Modern-Classic")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- Ilovalarni Wayland rejimida ishga tushirish
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
hl.env("SDL_VIDEODRIVER", "wayland,x11")
hl.env("CLUTTER_BACKEND", "wayland")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
hl.env("MOZ_ENABLE_WAYLAND", "1")

-- ── Ikki videokartali noutbuklar (Intel + NVIDIA) ─────────────────────
-- install.sh udev qoidasi orqali barqaror yo'llar yaratadi:
--   /dev/dri/bx-igpu  — ichki (Intel/AMD) karta
--   /dev/dri/bx-dgpu  — diskret (NVIDIA) karta
-- Ish stolini ichki karta chizadi (batareya tejaladi), NVIDIA esa faqat
-- `prime-run dastur` bilan ishga tushirilganda ishlaydi.
-- Diskret karta ham ro'yxatda turadi: agar HDMI porti NVIDIA ga ulangan
-- bo'lsa, tashqi monitor shu tufayli ishlaydi.
if U.exists("/dev/dri/bx-igpu") then
    local devices = "/dev/dri/bx-igpu"
    if U.exists("/dev/dri/bx-dgpu") then
        devices = devices .. ":/dev/dri/bx-dgpu"
    end
    hl.env("AQ_DRM_DEVICES", devices)
end

-- Faqat NVIDIA bo'lgan kompyuterlar uchun (noutbukda YOQMANG — hammasini
-- NVIDIA da chizishga majburlaydi va batareyani tez tugatadi):
-- hl.env("LIBVA_DRIVER_NAME", "nvidia")
-- hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
