-- Asosiy dasturlar. Boshqasini xohlasangiz, shu yerda almashtiring.
local V = {}

V.mod = "SUPER"

-- foot server rejimida ishlaydi: footclient bir zumda ochiladi.
-- Server ishlamayotgan bo'lsa, oddiy foot ga qaytadi.
function V.term(cmd)
    if cmd then
        return "footclient -e " .. cmd .. " || foot -e " .. cmd
    end
    return "footclient || foot"
end

V.terminal  = V.term()
V.launcher  = "pkill -x fuzzel || fuzzel"
V.files     = V.term("yazi")
V.files_gui = "thunar"
V.browser   = "firefox"
V.editor    = V.term("nvim")
V.monitor   = V.term("btop")

return V
