-- Barcha monitorlar uchun umumiy qoida: eng yaxshi rejim, avtomatik joylashuv.
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1,
})

-- Noutbuk ekrani: eng yuqori yangilanish chastotasi (masalan, 144 Hz).
hl.monitor({
    output   = "eDP-1",
    mode     = "highrr",
    position = "0x0",
    scale    = 1,
})

-- Tashqi monitorni o'ng tomonga qo'yish namunasi (nomini `hyprctl monitors` dan oling):
-- hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@75", position = "auto-right", scale = 1 })
