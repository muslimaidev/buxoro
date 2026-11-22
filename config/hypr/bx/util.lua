-- Yordamchi funksiyalar.
-- U.bind() oddiy hl.bind() bilan bir xil, lekin tavsifni ham saqlaydi:
-- SUPER + / bosilganda shu ro'yxat ko'rsatiladi (bx-keys).
local U = {}
local sheet = {}

function U.reset()
    sheet = {}
end

function U.bind(keys, action, desc, opts)
    opts = opts or {}
    if desc then
        opts.description = desc
        sheet[#sheet + 1] = { keys, desc }
    end
    return hl.bind(keys, action, opts)
end

-- Faqat ro'yxatga yozish (masalan, sikl ichidagi tugmalar uchun bitta qator)
function U.note(keys, desc)
    sheet[#sheet + 1] = { keys, desc }
end

function U.write_sheet()
    local home = os.getenv("HOME") or "/tmp"
    local dir = (os.getenv("XDG_CACHE_HOME") or (home .. "/.cache")) .. "/buxoro"
    os.execute("mkdir -p '" .. dir .. "'")
    local f = io.open(dir .. "/keys.tsv", "w")
    if not f then return end
    for _, row in ipairs(sheet) do
        f:write(row[1], "\t", row[2], "\n")
    end
    f:close()
end

function U.exists(path)
    local r = os.execute("test -e '" .. path .. "'")
    return r == true or r == 0
end

function U.rgba(hex, alpha)
    return "rgba(" .. hex .. (alpha or "ff") .. ")"
end

-- Ranglarni yuklash; fayl hali yaratilmagan bo'lsa — Buxoro standarti.
function U.colors()
    local ok, c = pcall(require, "theme.colors")
    if ok and type(c) == "table" then return c end
    return {
        bg = "13111a", bg_alt = "1a1723", surface = "24202f", overlay = "372f45",
        muted = "7c7289", subtext = "b9b0c5", fg = "eee7f3",
        accent = "3cc4b4", accent2 = "d4835a", gold = "e8b84e", red = "e46c6c",
    }
end

return U
