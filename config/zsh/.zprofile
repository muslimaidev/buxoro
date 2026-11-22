# TTY1 da tizimga kirilganda Hyprland avtomatik ishga tushadi.
# (Display manager ishlatsangiz, bu qator hech narsa qilmaydi.)
if [[ -z $WAYLAND_DISPLAY && -z $DISPLAY && ${XDG_VTNR:-0} -eq 1 ]] && command -v start-hyprland >/dev/null; then
    exec start-hyprland
fi
