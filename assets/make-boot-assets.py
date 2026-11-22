#!/usr/bin/env python3
"""Boot ekranlari uchun rasmlar: GRUB mavzusi, Plymouth splash, Limine va greeter foni.
Hammasi tungi Buxoro palitrasida. Foydalanish: python3 assets/make-boot-assets.py"""
import pathlib, re, subprocess, sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / "assets"))
import importlib.util
spec = importlib.util.spec_from_file_location("wp", ROOT / "assets/make-wallpapers.py")
wp = importlib.util.module_from_spec(spec); spec.loader.exec_module(wp)

t = wp.read_theme(ROOT / "themes/buxoro.theme")
c = {k: "#" + v for k, v in t.items() if re.fullmatch(r"[0-9a-fA-F]{6}", v)}


def render(svg_text, out, w, h):
    tmp = out.with_suffix(".svg")
    tmp.write_text(svg_text)
    subprocess.run(["rsvg-convert", "-w", str(w), "-h", str(h), "-o", str(out), str(tmp)], check=True)
    tmp.unlink()


def emblem(size=260, text=True):
    """Buxoro gerbi: oltin halqa ichida Kalon minorasi va feruza gumbaz."""
    s = size
    cx = s / 2
    h = s + (70 if text else 0)
    o = [f'<svg xmlns="http://www.w3.org/2000/svg" width="{s}" height="{h}" viewBox="0 0 {s} {h}">',
         f'<defs><linearGradient id="g" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="{c["accent"]}"/>'
         f'<stop offset="1" stop-color="{c["accent"]}" stop-opacity="0.6"/></linearGradient></defs>']
    r = s * 0.44
    # Sakkiz qirrali yulduz-halqa
    import math
    pts = []
    for k in range(16):
        rad = r if k % 2 == 0 else r * 0.88
        a = math.radians(k * 22.5 - 90)
        pts.append(f"{cx + rad * math.cos(a):.1f},{cx + rad * math.sin(a):.1f}")
    o.append(f'<polygon points="{" ".join(pts)}" fill="{c["bg_alt"]}" fill-opacity="0.85" stroke="{c["gold"]}" stroke-width="3"/>')
    o.append(f'<circle cx="{cx}" cy="{cx}" r="{r * 0.78:.1f}" fill="none" stroke="{c["gold"]}" stroke-opacity="0.5" stroke-width="1.5"/>')
    gy = cx + r * 0.52
    # Gumbaz (chapda) va minora (o'ngda)
    o.append(f'<path d="{wp.dome(cx - s * 0.12, gy - s * 0.12, s * 0.26, s * 0.2)}" fill="url(#g)"/>')
    o.append(f'<rect x="{cx - s * 0.24:.1f}" y="{gy - s * 0.12:.1f}" width="{s * 0.24:.1f}" height="{s * 0.12:.1f}" fill="{c["overlay"]}"/>')
    mx, top = cx + s * 0.11, cx - r * 0.40
    o.append(f'<path d="M {mx - 11} {gy} L {mx - 7} {top} L {mx + 7} {top} L {mx + 11} {gy} Z" fill="{c["accent2"]}"/>')
    for k in range(1, 6):
        yy = top + (gy - top) * k / 6
        o.append(f'<line x1="{mx - 11}" y1="{yy:.1f}" x2="{mx + 11}" y2="{yy:.1f}" stroke="{c["bg"]}" stroke-opacity="0.35" stroke-width="1.5"/>')
    o.append(f'<rect x="{mx - 7}" y="{top + 10:.1f}" width="14" height="3" fill="{c["accent"]}"/>')
    o.append(f'<rect x="{mx - 10}" y="{top - 14:.1f}" width="20" height="14" rx="2" fill="{c["accent2"]}"/>')
    o.append(f'<path d="{wp.dome(mx, top - 14, 16, 8)}" fill="{c["accent2"]}"/>')
    o.append(f'<line x1="{cx - s * 0.3:.1f}" y1="{gy:.1f}" x2="{cx + s * 0.3:.1f}" y2="{gy:.1f}" stroke="{c["gold"]}" stroke-width="2"/>')
    if text:
        o.append(f'<text x="{cx}" y="{s + 46}" text-anchor="middle" font-family="Inter Display, Inter, sans-serif" '
                 f'font-weight="600" font-size="34" letter-spacing="14" fill="{c["fg"]}">BUXORO</text>')
    o.append("</svg>")
    return "\n".join(o)


def solid(w, h, color, rx=0, opacity=1.0):
    return (f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}">'
            f'<rect width="{w}" height="{h}" rx="{rx}" fill="{color}" fill-opacity="{opacity}"/></svg>')


def main():
    g = ROOT / "boot/grub"
    p = ROOT / "boot/plymouth/buxoro"
    g.mkdir(parents=True, exist_ok=True); p.mkdir(parents=True, exist_ok=True)
    W, H = wp.W, wp.H
    wp.W, wp.H = 1920, 1080
    bg = wp.build(t)
    wp.W, wp.H = W, H
    render(bg, g / "background.png", 1920, 1080)
    render(bg, p / "bg.png", 1920, 1080)
    # GRUB: tanlangan qator foni (chap, o'rta, o'ng bo'laklar)
    render(solid(14, 46, c["accent"]), g / "select_c.png", 14, 46)
    render(f'<svg xmlns="http://www.w3.org/2000/svg" width="23" height="46"><rect x="0" y="0" width="46" height="46" rx="23" fill="{c["accent"]}"/></svg>', g / "select_w.png", 23, 46)
    render(f'<svg xmlns="http://www.w3.org/2000/svg" width="23" height="46"><rect x="-23" y="0" width="46" height="46" rx="23" fill="{c["accent"]}"/></svg>', g / "select_e.png", 23, 46)
    # Plymouth
    render(emblem(260, True), p / "logo.png", 260, 330)
    render(f'<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14"><circle cx="7" cy="7" r="6" fill="{c["gold"]}"/></svg>', p / "dot.png", 14, 14)
    render(f'<svg xmlns="http://www.w3.org/2000/svg" width="360" height="52"><rect x="1" y="1" width="358" height="50" rx="25" '
           f'fill="{c["bg_alt"]}" fill-opacity="0.92" stroke="{c["accent"]}" stroke-width="2"/></svg>', p / "entry.png", 360, 52)
    render(emblem(512, False), ROOT / "assets/logo.png", 512, 512)
    for f in sorted(list(g.glob("*.png")) + list(p.glob("*.png"))):
        print("yaratildi:", f.relative_to(ROOT))


if __name__ == "__main__":
    main()
