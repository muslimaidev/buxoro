local U = require("bx.util")
local c = U.colors()

hl.config({
    general = {
        gaps_in     = 4,
        gaps_out    = 8,
        border_size = 2,
        col = {
            active_border   = { colors = { U.rgba(c.accent), U.rgba(c.accent2) }, angle = 45 },
            inactive_border = U.rgba(c.overlay, "aa"),
        },
        resize_on_border = true,
        allow_tearing    = false,
        layout           = "dwindle",
        snap = {
            enabled     = true,
            window_gap  = 10,
            monitor_gap = 10,
        },
    },

    decoration = {
        rounding       = 12,
        rounding_power = 2.5,

        active_opacity   = 1.0,
        inactive_opacity = 1.0,  -- nofaol oynalar ortidagi xiralik GPU ni band qilmaydi
        dim_special      = 0.35,

        shadow = {
            enabled      = true,
            range        = 16,
            render_power = 3,
            color        = U.rgba("000000", "50"),
        },

        -- Faol oynaga yengil feruza nur (Hyprland 0.55+)
        glow = {
            enabled      = true,
            range        = 14,
            render_power = 3,
            color        = U.rgba(c.accent, "40"),
            color_inactive = U.rgba("000000", "00"),
        },

        -- 2 o'tish × 5 o'lcham: ichki Intel kartada ham 144 Hz da silliq
        blur = {
            enabled           = true,
            size              = 5,
            passes            = 2,
            new_optimizations = true,
            popups            = true,
            vibrancy          = 0.18,
            noise             = 0.012,
        },
    },

    animations = { enabled = true },

    dwindle = {
        preserve_split = true,
    },

    misc = {
        disable_hyprland_logo    = true,
        disable_splash_rendering = true,
        force_default_wallpaper  = 0,
        background_color         = tonumber("0xff" .. c.bg),
        focus_on_activate        = true,
        key_press_enables_dpms   = true,
        mouse_move_enables_dpms  = true,
        -- Terminaldan ochilgan GUI oyna terminal o'rnini egallaydi (mpv, zathura...)
        enable_swallow           = true,
        swallow_regex            = "^(foot|footclient)$",
    },

    cursor = {
        inactive_timeout = 5,    -- 5 soniya harakatsizlikdan keyin kursor yashirinadi
    },

    xwayland = {
        force_zero_scaling = true,
    },

    ecosystem = {
        no_donation_nag = true,
    },
})

-- ── Animatsiyalar: tez, lekin silliq ─────────────────────────────────
hl.curve("snappy",  { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })
hl.curve("smooth",  { type = "bezier", points = { { 0.25, 1 },   { 0.5, 1 } } })
hl.curve("linear",  { type = "bezier", points = { { 0, 0 },      { 1, 1 } } })
hl.curve("quick",   { type = "bezier", points = { { 0.15, 0 },   { 0.1, 1 } } })
hl.curve("bouncy",  { type = "spring", mass = 1, stiffness = 260, damping = 22 })

hl.animation({ leaf = "global",        enabled = true, speed = 8,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true, speed = 5,   bezier = "smooth" })
hl.animation({ leaf = "borderangle",   enabled = true, speed = 30,  bezier = "linear", style = "once" })
hl.animation({ leaf = "windows",       enabled = true, speed = 4,   spring = "bouncy" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 3.5, spring = "bouncy", style = "popin 85%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 1.5, bezier = "linear", style = "popin 85%" })
hl.animation({ leaf = "fade",          enabled = true, speed = 2.5, bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true, speed = 3,   bezier = "snappy" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 3,   bezier = "snappy", style = "slide" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 1.5, bezier = "linear", style = "fade" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 3,   bezier = "snappy", style = "slide" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 3, bezier = "snappy", style = "slidevert" })
