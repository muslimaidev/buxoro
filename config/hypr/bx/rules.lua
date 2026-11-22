-- ── Oyna qoidalari ──────────────────────────────────────────────────

-- Ilovalarning "o'zini kattalashtirish" so'rovlariga e'tibor bermaslik
hl.window_rule({
    name  = "suppress-maximize",
    match = { class = ".*" },
    suppress_event = "maximize",
})

-- XWayland'da sudrab olib o'tish muammosini tuzatish
hl.window_rule({
    name  = "fix-xwayland-drags",
    match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
    no_focus = true,
})

-- To'liq ekranli video/o'yin paytida ekran o'chmasin
hl.window_rule({
    name  = "idle-inhibit-fullscreen",
    match = { class = ".*" },
    idle_inhibit = "fullscreen",
})

-- Sozlamalar oynalari — suzuvchi va markazda
hl.window_rule({
    name  = "float-utilities",
    match = { class = "^(org.pulseaudio.pavucontrol|pavucontrol|nm-connection-editor|blueman-manager|.blueman-manager-wrapped|system-config-printer|org.gnome.Calculator|qalculate-gtk|nwg-look|xdg-desktop-portal-gtk|hyprpolkitagent|org.hyprland.hyprpolkitagent)$" },
    float  = true,
    center = true,
    size   = { "monitor_w*0.45", "monitor_h*0.55" },
})

-- Buxoro menyusidan ochiladigan terminal oynalari (paketlar, tekshiruv, Wi-Fi)
hl.window_rule({
    name  = "float-bx-terminal",
    match = { class = "^(bx-float)$" },
    float  = true,
    center = true,
    size   = { "monitor_w*0.62", "monitor_h*0.68" },
})

-- Fayl tanlash dialoglari
hl.window_rule({
    name  = "float-dialogs",
    match = { title = "^(Open File|Open Folder|Save As|Save File|Select a File|Choose Files|File Upload|Fayl.*|Открыть.*|Сохранить.*)$" },
    float  = true,
    center = true,
    size   = { "monitor_w*0.55", "monitor_h*0.6" },
})

-- Rasm ko'ruvchi va skrinshot muharriri
hl.window_rule({
    name  = "float-viewers",
    match = { class = "^(imv|com.gabm.satty)$" },
    float  = true,
    center = true,
})

-- Brauzerdagi "Picture-in-Picture" video — burchakda, barcha ish stollarida
hl.window_rule({
    name  = "pip",
    match = { title = "^(Picture-in-Picture|Картинка в картинке)$" },
    float = true,
    pin   = true,
    size  = { "monitor_w*0.25", "monitor_h*0.25" },
    move  = { "monitor_w*0.74", "monitor_h*0.72" },
    keep_aspect_ratio = true,
})

-- Video va rasm oynalarida shaffoflik yo'q
hl.window_rule({
    name  = "opaque-media",
    match = { class = "^(mpv|imv|firefox|org.pwmt.zathura)$" },
    opaque = true,
})

-- ── Qatlam qoidalari (panel, launcher, bildirishnomalar) ─────────────
hl.layer_rule({ match = { namespace = "waybar" },        blur = true, ignore_alpha = 0.2 })
hl.layer_rule({ match = { namespace = "launcher" },      blur = true, ignore_alpha = 0.2, animation = "popin 90%" })
hl.layer_rule({ match = { namespace = "swaync-control-center" },     blur = true, ignore_alpha = 0.3, animation = "slide right" })
hl.layer_rule({ match = { namespace = "swaync-notification-window" }, blur = true, ignore_alpha = 0.3, animation = "slide right" })
hl.layer_rule({ match = { namespace = "swayosd" },       blur = true, ignore_alpha = 0.3, animation = "fade" })
hl.layer_rule({ match = { namespace = "rofi" },          blur = true, ignore_alpha = 0.3, animation = "popin 92%" })
hl.layer_rule({ match = { namespace = "selection" },     no_anim = true })   -- slurp
hl.layer_rule({ match = { namespace = "hyprpicker" },    no_anim = true })
