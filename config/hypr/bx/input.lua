hl.config({
    input = {
        -- Alt+Shift: inglizcha → o'zbekcha (lotin) → ruscha
        kb_layout  = "us,uz,ru",
        kb_variant = ",latin,",
        kb_options = "grp:alt_shift_toggle",

        numlock_by_default = true,
        repeat_rate        = 40,
        repeat_delay       = 280,

        follow_mouse = 1,
        sensitivity  = 0,

        touchpad = {
            natural_scroll       = true,
            tap_to_click         = true,
            disable_while_typing = true,
            clickfinger_behavior = true,  -- 2 barmoq = o'ng tugma, 3 barmoq = o'rta tugma
            scroll_factor        = 0.6,
        },
    },
})

-- 3 barmoq bilan chapga/o'ngga surish — ish stollarini almashtirish
hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})
