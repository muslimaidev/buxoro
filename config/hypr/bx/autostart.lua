-- Hyprland ishga tushganda bir marta bajariladi (qayta yuklashda emas).
hl.on("hyprland.start", function()
    -- systemd/dbus xizmatlari (bx-sync taymeri, portal) Hyprland'ni topishi uchun
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE")
    hl.exec_cmd("systemctl --user start hyprpolkitagent")  -- parol so'rovchi oyna
    -- Fon rasmi: awww (silliq o'tish effektlari), so'ng oxirgi rasmni tiklash
    hl.exec_cmd("(command -v awww-daemon >/dev/null && awww-daemon || swww-daemon) & sleep 0.5; bx-wall restore")
    hl.exec_cmd("waybar")
    hl.exec_cmd("swaync")                                   -- bildirishnomalar markazi
    hl.exec_cmd("swayosd-server")                           -- ovoz/yorug'lik ko'rsatkichi
    hl.exec_cmd("hypridle")
    hl.exec_cmd("foot --server")                            -- terminal bir zumda ochilishi uchun
    hl.exec_cmd("wl-paste --type text  --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    hl.exec_cmd("nm-applet --indicator")
end)
