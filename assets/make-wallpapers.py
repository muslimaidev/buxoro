#!/usr/bin/env python3
"""Mavzular uchun fon rasmlari. Ikki uslub (mavzu faylidagi wallpaper_style):
  kalon — Poyi Kalon ansambli siluyeti (standart)
  girih — Samarqand xotam naqshi va oltin rozetka


Kalon minorasi (g'isht naqshlari va feruza belbog' bilan), Masjidi Kalon peshtoqi
va Ko'k gumbazi, Mir-Arab madrasasining egizak feruza gumbazlari; tungi mavzuda oy
va yulduzlar, kunduzgi mavzuda quyosh.

Foydalanish:  python3 assets/make-wallpapers.py [kenglik balandlik]
Natija:       wallpapers/<mavzu>.svg va .png (rsvg-convert kerak)
"""
import math, pathlib, random, re, subprocess, sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
W, H = (int(sys.argv[1]), int(sys.argv[2])) if len(sys.argv) > 2 else (2560, 1440)


def read_theme(path):
    vals = {}
    for line in path.read_text().splitlines():
        m = re.match(r'^(\w+)="?([^"#]*)"?', line.strip())
        if m:
            vals[m.group(1)] = m.group(2).strip()
    return vals


def X(f):  # kenglik ulushi → piksel
    return f * W


def Y(f):
    return f * H


def dome(cx, base_y, w, h):
    """Qovun shaklidagi gumbaz (Buxoro uslubi)."""
    l, r, top = cx - w / 2, cx + w / 2, base_y - h
    return (f"M {l:.1f} {base_y:.1f} "
            f"C {l - w*0.06:.1f} {base_y - h*0.55:.1f} {cx - w*0.32:.1f} {top + h*0.08:.1f} {cx:.1f} {top:.1f} "
            f"C {cx + w*0.32:.1f} {top + h*0.08:.1f} {r + w*0.06:.1f} {base_y - h*0.55:.1f} {r:.1f} {base_y:.1f} Z")


def arch(l, r, bottom, spring, peak):
    """Uchli ravoq (peshtoq va ravvoqlar uchun)."""
    cx = (l + r) / 2
    return (f"M {l:.1f} {bottom:.1f} L {l:.1f} {spring:.1f} "
            f"Q {l:.1f} {peak + (spring - peak) * 0.25:.1f} {cx:.1f} {peak:.1f} "
            f"Q {r:.1f} {peak + (spring - peak) * 0.25:.1f} {r:.1f} {spring:.1f} L {r:.1f} {bottom:.1f} Z")


def mix(a, b, k):
    """Ikki rangni aralashtirish: k=0 → a, k=1 → b."""
    a, b = a.lstrip("#"), b.lstrip("#")
    return "#" + "".join(f"{round(int(a[i:i+2], 16) * (1 - k) + int(b[i:i+2], 16) * k):02x}" for i in (0, 2, 4))


def build_kalon(t):
    c = {k: "#" + v for k, v in t.items() if re.fullmatch(r"[0-9a-fA-F]{6}", v)}
    dark = t.get("mode") == "dark"
    shade = c["bg"] if dark else mix(c["accent2"], c["fg"], 0.35)      # ravoq ichidagi soya
    gy = Y(0.885)                        # yer chizig'i
    o = []
    a = o.append
    a(f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}">')
    a("<defs>")
    if dark:
        a(f'<linearGradient id="sky" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="{c["bg"]}"/>'
          f'<stop offset="0.75" stop-color="{c["bg_alt"]}"/><stop offset="1" stop-color="{c["surface"]}"/></linearGradient>')
    else:
        a(f'<linearGradient id="sky" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="{c["bg"]}"/>'
          f'<stop offset="0.8" stop-color="{c["bg_alt"]}"/><stop offset="1" stop-color="{c["surface"]}"/></linearGradient>')
    a(f'<radialGradient id="halo" cx="0.86" cy="0.17" r="0.45"><stop offset="0" stop-color="{c["gold"]}" '
      f'stop-opacity="{0.10 if dark else 0.30}"/><stop offset="1" stop-color="{c["gold"]}" stop-opacity="0"/></radialGradient>')
    a(f'<radialGradient id="horizon" cx="0.62" cy="1.0" r="0.6"><stop offset="0" stop-color="{c["accent2"]}" '
      f'stop-opacity="{0.22 if dark else 0.18}"/><stop offset="1" stop-color="{c["accent2"]}" stop-opacity="0"/></radialGradient>')
    bld_top, bld_bot = ((c["overlay"], c["surface"]) if dark
                        else (mix(c["accent2"], c["bg"], 0.45), mix(c["accent2"], c["bg"], 0.62)))
    a(f'<linearGradient id="bld" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="{bld_top}"/>'
      f'<stop offset="1" stop-color="{bld_bot}"/></linearGradient>')
    a(f'<linearGradient id="tile" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="{c["accent"]}"/>'
      f'<stop offset="1" stop-color="{c["accent"]}" stop-opacity="0.55"/></linearGradient>')
    # Kalon minorasining olmossimon g'isht to'ri
    a(f'<pattern id="diamond" width="22" height="22" patternUnits="userSpaceOnUse" patternTransform="rotate(45)">'
      f'<rect width="22" height="22" fill="none" stroke="{c["accent2"]}" stroke-width="1.4" stroke-opacity="0.45"/></pattern>')
    # Devorlardagi oddiy g'isht terimi
    a(f'<pattern id="bond" width="36" height="14" patternUnits="userSpaceOnUse">'
      f'<path d="M0 0 H36 M0 7 H36 M18 0 V7 M0 7 V14 M36 7 V14" stroke="{c["accent2"]}" stroke-width="1" '
      f'stroke-opacity="0.22" fill="none"/></pattern>')
    a('<mask id="crescent"><rect width="100%" height="100%" fill="black"/>'
      f'<circle cx="{X(0.86):.0f}" cy="{Y(0.17):.0f}" r="62" fill="white"/>'
      f'<circle cx="{X(0.86) + 26:.0f}" cy="{Y(0.17) - 14:.0f}" r="56" fill="black"/></mask>')
    a("</defs>")

    a(f'<rect width="{W}" height="{H}" fill="url(#sky)"/>')
    a(f'<rect width="{W}" height="{H}" fill="url(#halo)"/>')
    a(f'<rect width="{W}" height="{H}" fill="url(#horizon)"/>')

    # Osmon: tunda yulduzlar va oy, kunduzi quyosh
    if dark:
        rnd = random.Random(1555)  # Kalon minorasi 1127-yilda qurilgan; urug' — shunchaki o'zgarmas son
        for _ in range(220):
            sx, sy = rnd.uniform(0, W), rnd.uniform(0, H * 0.62)
            r = rnd.choice((0.8, 1.0, 1.2, 1.6))
            a(f'<circle cx="{sx:.0f}" cy="{sy:.0f}" r="{r}" fill="{c["fg"]}" fill-opacity="{rnd.uniform(0.15, 0.7):.2f}"/>')
        a(f'<rect width="{W}" height="{H}" fill="{c["gold"]}" mask="url(#crescent)"/>')
    else:
        sun = mix(c["gold"], "#fff4d6", 0.55)
        a(f'<circle cx="{X(0.86):.0f}" cy="{Y(0.17):.0f}" r="130" fill="{sun}" fill-opacity="0.18"/>')
        a(f'<circle cx="{X(0.86):.0f}" cy="{Y(0.17):.0f}" r="92" fill="{sun}" fill-opacity="0.35"/>')
        a(f'<circle cx="{X(0.86):.0f}" cy="{Y(0.17):.0f}" r="66" fill="{sun}"/>')

    # ── Uzun devor va ravvoqlar (galereya) ──
    wall_top = gy - Y(0.11)
    a(f'<rect x="{X(0.30):.0f}" y="{wall_top:.0f}" width="{W - X(0.30):.0f}" height="{gy - wall_top:.0f}" fill="url(#bld)"/>')
    a(f'<rect x="{X(0.30):.0f}" y="{wall_top:.0f}" width="{W - X(0.30):.0f}" height="{gy - wall_top:.0f}" fill="url(#bond)"/>')
    step = 64
    x = X(0.31)
    while x < W - 40:
        a(f'<path d="{arch(x + 12, x + step - 12, gy - 18, wall_top + 70, wall_top + 34)}" fill="{shade}" fill-opacity="{0.55 if dark else 0.45}"/>')
        x += step

    # ── Masjidi Kalon: Ko'k gumbaz ──
    dcx, dbase = X(0.43), wall_top - 30
    a(f'<rect x="{dcx - 82:.0f}" y="{dbase:.0f}" width="164" height="{wall_top - dbase + 2:.0f}" fill="url(#bld)"/>')
    a(f'<rect x="{dcx - 82:.0f}" y="{dbase:.0f}" width="164" height="10" fill="{c["accent"]}" fill-opacity="0.6"/>')
    a(f'<path d="{dome(dcx, dbase, 178, 150)}" fill="url(#tile)"/>')
    for k in (-0.6, -0.3, 0, 0.3, 0.6):
        a(f'<path d="M {dcx + k * 89:.1f} {dbase:.1f} Q {dcx + k * 60:.1f} {dbase - 110:.1f} {dcx:.1f} {dbase - 150:.1f}" '
          f'stroke="{c["bg"]}" stroke-opacity="0.25" stroke-width="2" fill="none"/>')
    a(f'<line x1="{dcx:.0f}" y1="{dbase - 150:.0f}" x2="{dcx:.0f}" y2="{dbase - 186:.0f}" stroke="{c["gold"]}" stroke-width="3"/>')

    # ── Masjidi Kalon peshtoqi ──
    pl, pr, ptop = X(0.50), X(0.62), gy - Y(0.29)
    a(f'<rect x="{pl:.0f}" y="{ptop:.0f}" width="{pr - pl:.0f}" height="{gy - ptop:.0f}" fill="url(#bld)"/>')
    a(f'<rect x="{pl:.0f}" y="{ptop:.0f}" width="{pr - pl:.0f}" height="{gy - ptop:.0f}" fill="url(#bond)"/>')
    a(f'<rect x="{pl + 18:.0f}" y="{ptop + 18:.0f}" width="{pr - pl - 36:.0f}" height="{gy - ptop - 18:.0f}" fill="none" '
      f'stroke="{c["accent"]}" stroke-opacity="0.55" stroke-width="5"/>')
    a(f'<rect x="{pl + 30:.0f}" y="{ptop + 30:.0f}" width="{pr - pl - 60:.0f}" height="{gy - ptop - 30:.0f}" fill="none" '
      f'stroke="{c["gold"]}" stroke-opacity="0.45" stroke-width="2"/>')
    a(f'<path d="{arch(pl + 62, pr - 62, gy, ptop + 170, ptop + 70)}" fill="{shade}" fill-opacity="{0.8 if dark else 0.55}"/>')
    a(f'<path d="{arch(pl + 62, pr - 62, gy, ptop + 170, ptop + 70)}" fill="none" stroke="{c["accent"]}" stroke-opacity="0.6" stroke-width="3"/>')
    # Peshtoq ichidagi muqarnas taassuroti
    for row in range(4):
        yy = ptop + 120 + row * 26
        n = 3 + row
        span = (pr - pl - 160) * (0.45 + row * 0.18)
        for k in range(n):
            xx = (pl + pr) / 2 - span / 2 + span * (k + 0.5) / n
            a(f'<path d="M {xx - 12:.0f} {yy + 18:.0f} Q {xx:.0f} {yy - 4:.0f} {xx + 12:.0f} {yy + 18:.0f}" '
              f'stroke="{c["gold"]}" stroke-opacity="0.35" stroke-width="1.5" fill="none"/>')

    # ── Kalon minorasi ──
    mx, mtop = X(0.70), Y(0.255)
    bw, tw = 60, 40
    shaft = f"M {mx - bw} {gy} L {mx - tw} {mtop} L {mx + tw} {mtop} L {mx + bw} {gy} Z"
    a(f'<clipPath id="shaftclip"><path d="{shaft}"/></clipPath>')
    a(f'<path d="{shaft}" fill="url(#bld)"/>')
    a(f'<g clip-path="url(#shaftclip)">')
    # Har xil g'isht belbog'lari: olmossimon, gorizontal, zigzag
    band_h = (gy - mtop) / 9
    for b in range(9):
        y0 = mtop + b * band_h
        if b % 3 == 0:
            a(f'<rect x="{mx - bw}" y="{y0:.0f}" width="{2 * bw}" height="{band_h:.0f}" fill="url(#diamond)"/>')
        elif b % 3 == 1:
            for yy in range(int(y0), int(y0 + band_h), 9):
                a(f'<line x1="{mx - bw}" y1="{yy}" x2="{mx + bw}" y2="{yy}" stroke="{c["accent2"]}" stroke-opacity="0.35" stroke-width="1.2"/>')
        else:
            zz = " ".join(f"{mx - bw + i * 10},{y0 + band_h / 2 + (8 if i % 2 else -8):.0f}" for i in range(13))
            a(f'<polyline points="{zz}" fill="none" stroke="{c["accent2"]}" stroke-opacity="0.45" stroke-width="2"/>')
        a(f'<line x1="{mx - bw}" y1="{y0:.0f}" x2="{mx + bw}" y2="{y0:.0f}" stroke="{c["accent2"]}" stroke-opacity="0.6" stroke-width="2.5"/>')
    # Feruza belbog' (minoradagi yagona sirlangan qator)
    a(f'<rect x="{mx - bw}" y="{mtop + band_h * 0.55:.0f}" width="{2 * bw}" height="9" fill="{c["accent"]}" fill-opacity="0.85"/>')
    a("</g>")
    # Muqarnasli karniz va fonus (yuqoridagi aylana ravoqli qism)
    a(f'<path d="M {mx - tw - 14} {mtop} L {mx - tw - 4} {mtop - 22} L {mx + tw + 4} {mtop - 22} L {mx + tw + 14} {mtop} Z" fill="url(#bld)"/>')
    for k in range(7):
        xx = mx - tw - 8 + k * (2 * tw + 16) / 6
        a(f'<path d="M {xx - 6:.0f} {mtop:.0f} Q {xx:.0f} {mtop - 16:.0f} {xx + 6:.0f} {mtop:.0f}" stroke="{c["gold"]}" stroke-opacity="0.5" fill="none" stroke-width="1.5"/>')
    lt, lb = mtop - 92, mtop - 22
    a(f'<rect x="{mx - tw - 4}" y="{lt}" width="{2 * tw + 8}" height="{lb - lt}" fill="url(#bld)"/>')
    for k in range(5):
        xx = mx - tw + 8 + k * (2 * tw - 16) / 4
        a(f'<path d="{arch(xx - 6, xx + 6, lb - 10, lt + 30, lt + 14)}" fill="{c["gold"] if dark else shade}" fill-opacity="{0.55 if dark else 0.6}"/>')
    a(f'<path d="M {mx - tw - 8} {lt} L {mx + tw + 8} {lt} L {mx + tw - 2} {lt - 14} L {mx - tw + 2} {lt - 14} Z" fill="url(#bld)"/>')
    a(f'<path d="{dome(mx, lt - 14, 2 * tw - 6, 26)}" fill="url(#bld)"/>')

    # ── Mir-Arab madrasasi: egizak feruza gumbazlar va peshtoq ──
    for cxf, w, h in ((0.80, 150, 128), (0.93, 150, 128)):
        cx = X(cxf)
        base = wall_top - 46
        a(f'<rect x="{cx - w / 2 + 6:.0f}" y="{base:.0f}" width="{w - 12:.0f}" height="{wall_top - base + 2:.0f}" fill="url(#bld)"/>')
        a(f'<rect x="{cx - w / 2 + 6:.0f}" y="{base + 14:.0f}" width="{w - 12:.0f}" height="12" fill="{c["accent"]}" fill-opacity="0.5"/>')
        a(f'<path d="{dome(cx, base, w, h)}" fill="url(#tile)"/>')
        for k in (-0.55, -0.25, 0.05, 0.35):
            a(f'<path d="M {cx + k * w / 2:.1f} {base:.1f} Q {cx + k * w / 3:.1f} {base - h * 0.7:.1f} {cx:.1f} {base - h:.1f}" '
              f'stroke="{c["bg"]}" stroke-opacity="0.25" stroke-width="2" fill="none"/>')
        a(f'<line x1="{cx:.0f}" y1="{base - h:.0f}" x2="{cx:.0f}" y2="{base - h - 30:.0f}" stroke="{c["gold"]}" stroke-width="3"/>')
    ml, mr, mt = X(0.835), X(0.895), gy - Y(0.21)
    a(f'<rect x="{ml:.0f}" y="{mt:.0f}" width="{mr - ml:.0f}" height="{gy - mt:.0f}" fill="url(#bld)"/>')
    a(f'<rect x="{ml + 12:.0f}" y="{mt + 12:.0f}" width="{mr - ml - 24:.0f}" height="{gy - mt - 12:.0f}" fill="none" stroke="{c["accent"]}" stroke-opacity="0.6" stroke-width="4"/>')
    a(f'<path d="{arch(ml + 34, mr - 34, gy, mt + 110, mt + 50)}" fill="{shade}" fill-opacity="{0.8 if dark else 0.55}"/>')
    for tx in (ml - 8, mr - 8):     # guldastalar (burchak minorachalari)
        a(f'<rect x="{tx:.0f}" y="{mt - 26:.0f}" width="16" height="{gy - mt + 26:.0f}" fill="url(#bld)"/>')
        a(f'<path d="{dome(tx + 8, mt - 26, 20, 14)}" fill="{c["accent"]}" fill-opacity="0.8"/>')

    # ── Yer ──
    a(f'<rect x="0" y="{gy:.0f}" width="{W}" height="{H - gy:.0f}" fill="{c["bg"]}"/>')
    a(f'<rect x="0" y="{gy:.0f}" width="{W}" height="3" fill="{c["accent2"]}" fill-opacity="0.5"/>')
    a(f'<rect x="0" y="{gy + 3:.0f}" width="{W}" height="{H - gy - 3:.0f}" fill="url(#bond)" opacity="0.6"/>')
    a("</svg>")
    return "\n".join(o)


def star(cx, cy, R, r, rot=22.5):
    pts = []
    for k in range(16):
        rad = R if k % 2 == 0 else r
        a = math.radians(rot + k * 22.5)
        pts.append(f"{cx + rad * math.cos(a):.1f},{cy + rad * math.sin(a):.1f}")
    return " ".join(pts)


def girih_square(cx, cy, h, rot):
    pts = []
    for k in range(4):
        a = math.radians(rot + 45 + k * 90)
        pts.append(f"{cx + h * math.cos(a):.1f},{cy + h * math.sin(a):.1f}")
    return " ".join(pts)


def build_girih(t):
    """Samarqand uslubi: xotam (sakkiz qirrali yulduz) to'ri va markaziy oltin rozetka."""
    c = {k: "#" + v for k, v in t.items() if re.fullmatch(r"[0-9a-fA-F]{6}", v)}
    dark = t.get("mode") == "dark"
    s = 120                      # katak o'lchami
    fx, fy = W * 0.68, H * 0.42  # naqsh markazi (yorqin nuqta)
    out = [f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}">',
           "<defs>",
           f'<radialGradient id="base" cx="0.68" cy="0.42" r="0.9">'
           f'<stop offset="0" stop-color="{c["bg_alt"]}"/><stop offset="1" stop-color="{c["bg"]}"/></radialGradient>',
           f'<radialGradient id="glowA" cx="0.12" cy="0.95" r="0.55">'
           f'<stop offset="0" stop-color="{c["accent"]}" stop-opacity="{0.22 if dark else 0.16}"/>'
           f'<stop offset="1" stop-color="{c["accent"]}" stop-opacity="0"/></radialGradient>',
           f'<radialGradient id="glowB" cx="0.9" cy="0.05" r="0.5">'
           f'<stop offset="0" stop-color="{c["accent2"]}" stop-opacity="{0.18 if dark else 0.12}"/>'
           f'<stop offset="1" stop-color="{c["accent2"]}" stop-opacity="0"/></radialGradient>',
           "</defs>",
           f'<rect width="{W}" height="{H}" fill="url(#base)"/>',
           f'<rect width="{W}" height="{H}" fill="url(#glowA)"/>',
           f'<rect width="{W}" height="{H}" fill="url(#glowB)"/>']

    maxd = math.hypot(W, H) * 0.7
    line = c["accent2"] if dark else c["muted"]
    R = s / 2                                   # yulduz uchlari qo'shnilariga tegib turadi
    for j in range(-1, H // s + 2):
        for i in range(-1, W // s + 2):
            x, y = i * s, j * s
            d = math.hypot(x - fx, y - fy)
            k = max(0.0, 1 - d / maxd)          # markazdan uzoqlashgan sari xiralashadi
            if k <= 0.02:
                continue
            op = (0.05 + 0.30 * k ** 1.4) if dark else (0.06 + 0.30 * k ** 1.4)
            # Xotam: sakkiz qirrali yulduz; oralarida xoch shaklidagi bo'shliqlar hosil bo'ladi
            out.append(f'<polygon points="{star(x, y, R, R * 0.56, 0)}" fill="none" '
                       f'stroke="{line}" stroke-width="1.4" stroke-opacity="{op:.3f}"/>')
            # Yulduz ichidagi kichik sakkizburchak
            out.append(f'<polygon points="{star(x, y, R * 0.36, R * 0.36, 0)}" fill="none" '
                       f'stroke="{line}" stroke-width="1" stroke-opacity="{op * 0.7:.3f}"/>')

    # Markaziy rozetka — ingichka oltin chiziqlar
    g, a = c["gold"], c["accent"]
    for R2, r2, rot, w, o in ((s * 2.6, s * 1.95, 0, 2.2, 0.75),
                              (s * 2.6, s * 1.95, 22.5, 1.2, 0.45),
                              (s * 1.55, s * 1.1, 0, 1.8, 0.7),
                              (s * 1.55, s * 1.1, 22.5, 1.0, 0.4)):
        out.append(f'<polygon points="{star(fx, fy, R2, r2, rot)}" fill="none" stroke="{g}" '
                   f'stroke-width="{w}" stroke-opacity="{o}"/>')
    out.append(f'<polygon points="{star(fx, fy, s * 0.7, s * 0.4, 0)}" fill="{a}" fill-opacity="0.16" '
               f'stroke="{a}" stroke-width="1.8" stroke-opacity="0.85"/>')
    for rr, dash, o in ((s * 2.95, "none", 0.35), (s * 3.3, "2 9", 0.45), (s * 0.95, "none", 0.4)):
        out.append(f'<circle cx="{fx}" cy="{fy}" r="{rr:.0f}" fill="none" stroke="{a}" '
                   f'stroke-width="1.2" stroke-opacity="{o}" stroke-dasharray="{dash}"/>')
    # Rozetka nurlari
    for kk in range(16):
        ang = math.radians(kk * 22.5)
        x1, y1 = fx + s * 1.0 * math.cos(ang), fy + s * 1.0 * math.sin(ang)
        x2, y2 = fx + s * 2.95 * math.cos(ang), fy + s * 2.95 * math.sin(ang)
        out.append(f'<line x1="{x1:.1f}" y1="{y1:.1f}" x2="{x2:.1f}" y2="{y2:.1f}" stroke="{g}" '
                   f'stroke-width="0.8" stroke-opacity="0.25"/>')
    out.append("</svg>")
    return "\n".join(out)


def build(t):
    return build_girih(t) if t.get("wallpaper_style") == "girih" else build_kalon(t)


def main():
    outdir = ROOT / "wallpapers"
    outdir.mkdir(exist_ok=True)
    for theme in sorted((ROOT / "themes").glob("*.theme")):
        t = read_theme(theme)
        svg = outdir / f"{theme.stem}.svg"
        png = outdir / f"{theme.stem}.png"
        svg.write_text(build(t))
        subprocess.run(["rsvg-convert", "-w", str(W), "-h", str(H), "-o", str(png), str(svg)], check=True)
        print("yaratildi:", png.relative_to(ROOT))


if __name__ == "__main__":
    main()
