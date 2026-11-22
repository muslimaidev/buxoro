#!/usr/bin/env bash
#  ┏┓ ╻ ╻╻ ╻┏━┓┏━┓┏━┓
#  ┣┻┓┃ ┃┏╋┛┃ ┃┣┳┛┃ ┃   o'rnatuvchi (Arch Linux)
#  ┗━┛┗━┛╹ ╹┗━┛╹┗╸┗━┛
#
#  ./install.sh                hammasi (savollar bilan)
#  ./install.sh --yes          savollarsiz, standart javoblar bilan
#  ./install.sh --no-packages  faqat konfiguratsiyalarni ulash
#  ./install.sh --latex        LaTeX paketlarini ham o'rnatish
#  ./install.sh --boot         bootloader mavzusi + Plymouth splash (--yes bilan ham)
#  ./install.sh --no-boot      bootloader'ga tegmaslik
#  ./install.sh --no-greeter   login ekranini o'rnatmaslik
#
#  Konfiguratsiyalar NUSXALANMAYDI, balki simvolik havola qilinadi:
#  repozitoriyani `git pull` qilsangiz, o'zgarishlar darhol ishlaydi.
# shellcheck disable=SC2088,SC1112  # matndagi ~ va o‘zbekcha ‘ belgisi ataylab
set -euo pipefail

BX_DIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
CFG="${XDG_CONFIG_HOME:-$HOME/.config}"
BACKUP="$CFG/buxoro-backup-$(date +%Y%m%d-%H%M%S)"
YES=0 PACKAGES=1 LATEX=0 BOOT=ask GREETER=ask

for a in "$@"; do
    case "$a" in
        -y|--yes)      YES=1 ;;
        --no-packages) PACKAGES=0 ;;
        --latex)       LATEX=1 ;;
        --boot)        BOOT=yes ;;
        --no-boot)     BOOT=no ;;
        --no-greeter)  GREETER=no ;;
        -h|--help)     sed -n '6,15p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *) echo "Noma'lum parametr: $a" >&2; exit 1 ;;
    esac
done

c_acc=$'\e[1;36m' c_ok=$'\e[1;32m' c_warn=$'\e[1;33m' c_err=$'\e[1;31m' c_off=$'\e[0m'
step() { printf '\n%s::%s %s\n' "$c_acc" "$c_off" "$*"; }
ok()   { printf '   %s✓%s %s\n' "$c_ok" "$c_off" "$*"; }
warn() { printf '   %s!%s %s\n' "$c_warn" "$c_off" "$*"; }
die()  { printf '%s✗ %s%s\n' "$c_err" "$*" "$c_off" >&2; exit 1; }
ask()  { # ask "savol" [y|n]
    local def=${2:-y} ans
    (( YES )) && { [[ $def == y ]]; return; }
    read -rp "   $1 [$( [[ $def == y ]] && echo 'Y/n' || echo 'y/N')] " ans
    ans=${ans:-$def}; [[ ${ans,,} == y* ]]
}
read_list() { grep -vE '^\s*(#|$)' "$1"; }

[[ $EUID -ne 0 ]] || die "Skriptni oddiy foydalanuvchi sifatida ishga tushiring (sudo o'zi so'raladi)."
command -v pacman >/dev/null || die "Bu skript faqat Arch Linux (va unga asoslangan tizimlar) uchun."

# ── 1. Paketlar ───────────────────────────────────────────────────────
AUR_HELPER=""
AUR_QUEUE=()

ensure_aur_helper() {
    command -v paru >/dev/null && { AUR_HELPER=paru; return; }
    command -v yay  >/dev/null && { AUR_HELPER=yay;  return; }
    step "AUR yordamchisi"
    if ask "paru o'rnatilsinmi? (kursor mavzusi va ba'zi drayverlar AUR da)"; then
        sudo pacman -S --needed --noconfirm git base-devel >/dev/null
        local tmp; tmp="$(mktemp -d)"
        git clone --depth 1 https://aur.archlinux.org/paru-bin.git "$tmp/paru-bin"
        (cd "$tmp/paru-bin" && makepkg -si --noconfirm)
        rm -rf "$tmp"
        AUR_HELPER=paru
        ok "paru o'rnatildi"
    else
        warn "AUR o'tkazib yuborildi"
    fi
}

choose_printer_drivers() {
    # Diqqat: bu funksiya chiqishi paketlar ro'yxati sifatida o'qiladi — matnlar stderr ga
    {
        step "Printer"
        echo "   Zamonaviy printerlar drayversiz ishlaydi (hech narsa o'rnatish shart emas)."
        echo "   Eski model bo'lsa, markani tanlang (bir nechta bo'lsa — probel bilan):"
        echo "     1) HP   2) Canon   3) Epson   4) Brother   5) Samsung   6) Xerox   7) Bilmayman (universal)   0) Kerak emas"
    } >&2
    local ans=0
    (( YES )) || read -rp "   Tanlov [0]: " ans
    local -A map=([1]=hp [2]=canon [3]=epson [4]=brother [5]=samsung [6]=xerox [7]=universal)
    local n sec
    for n in ${ans:-0}; do
        sec=${map[$n]:-}
        [[ -n $sec ]] || continue
        awk -v s="[$sec]" '$0==s {f=1; next} /^\[/ {f=0} f && NF && $0 !~ /^#/' "$BX_DIR/packages-printer.txt"
    done
}

# PulseAudio → PipeWire. pipewire-pulse PulseAudio bilan to'qnashadi, --noconfirm esa
# "o'chirilsinmi?" savoliga "yo'q" deydi va o'rnatish to'xtaydi. Shuning uchun avval
# PulseAudio'ni xavfsiz olib tashlaymiz: dasturlar baribir ishlaydi, chunki
# pipewire-pulse xuddi shu PulseAudio interfeysini (libpulse) taqdim etadi.
migrate_audio() {
    local old=() p
    for p in pulseaudio pulseaudio-bluetooth pulseaudio-alsa pulseaudio-jack pulseaudio-zeroconf pulseaudio-equalizer pulseaudio-lirc; do
        pacman -Qq "$p" >/dev/null 2>&1 && old+=("$p")
    done
    (( ${#old[@]} )) || return 0
    step "Ovoz tizimi: PulseAudio → PipeWire"
    systemctl --user disable --now pulseaudio.service pulseaudio.socket >/dev/null 2>&1 || true
    sudo pacman -Rdd --noconfirm "${old[@]}" >/dev/null && ok "Olib tashlandi: ${old[*]}"
    sudo pacman -S --needed --noconfirm pipewire pipewire-pulse pipewire-alsa wireplumber >/dev/null &&
        ok "PipeWire o'rnatildi (PulseAudio dasturlari o'zgarishsiz ishlaydi)"
    systemctl --user enable --now pipewire.socket pipewire-pulse.socket wireplumber.service >/dev/null 2>&1 || true
}

install_packages() {
    step "Paketlar"
    sudo pacman -Sy --noconfirm >/dev/null
    migrate_audio
    local want=() p
    mapfile -t want < <(read_list "$BX_DIR/packages.txt")
    (( LATEX )) && mapfile -t -O "${#want[@]}" want < <(read_list "$BX_DIR/packages-latex.txt")
    mapfile -t -O "${#want[@]}" want < <(choose_printer_drivers)

    if lspci -d ::03xx 2>/dev/null | grep -qi nvidia; then
        ok "NVIDIA karta topildi"
        if pacman -Qq linux >/dev/null 2>&1; then want+=(nvidia-open); else want+=(nvidia-open-dkms); fi
        want+=(nvidia-utils nvidia-prime libva-nvidia-driver)
    fi
    lspci -d ::03xx 2>/dev/null | grep -qiE 'AMD|ATI' && want+=(vulkan-radeon)

    # Rasmiy repozitoriyada bor-yo'qligini oldindan tekshiramiz: yo'qlari AUR navbatiga
    local repo=()
    for p in "${want[@]}"; do
        if pacman -Si "$p" >/dev/null 2>&1 || pacman -Sg "$p" >/dev/null 2>&1; then repo+=("$p"); else AUR_QUEUE+=("$p"); fi
    done
    sudo pacman -S --needed --noconfirm "${repo[@]}"
    ok "${#repo[@]} ta rasmiy paket"

    mapfile -t -O "${#AUR_QUEUE[@]}" AUR_QUEUE < <(read_list "$BX_DIR/packages-aur.txt")
    if (( ${#AUR_QUEUE[@]} )); then
        ensure_aur_helper
        if [[ -n $AUR_HELPER ]]; then
            "$AUR_HELPER" -S --needed --noconfirm "${AUR_QUEUE[@]}" && ok "AUR: ${AUR_QUEUE[*]}" ||
                warn "Ba'zi AUR paketlari o'rnatilmadi: ${AUR_QUEUE[*]}"
        else
            warn "O'rnatilmadi (AUR): ${AUR_QUEUE[*]}"
        fi
    fi
}

(( PACKAGES )) && install_packages

# ── 2. Konfiguratsiyalarni ulash ──────────────────────────────────────
link() { # link <manba> <manzil>
    local src=$1 dst=$2
    if [[ -L $dst && "$(readlink -f "$dst")" == "$(readlink -f "$src")" ]]; then return; fi
    if [[ -e $dst || -L $dst ]]; then
        mkdir -p "$BACKUP/$(dirname "${dst#"$HOME"/}")"
        mv "$dst" "$BACKUP/${dst#"$HOME"/}"
        warn "Zaxiralandi: ${dst/#$HOME/\~}"
    fi
    mkdir -p "$(dirname "$dst")"
    ln -s "$src" "$dst"
}

step "Mavzu fayllarini yaratish"
"$BX_DIR/bin/bx-theme" render "$(cat "${XDG_STATE_HOME:-$HOME/.local/state}/buxoro/theme" 2>/dev/null || echo buxoro)"
mkdir -p "${XDG_STATE_HOME:-$HOME/.local/state}/buxoro"
[[ -f "${XDG_STATE_HOME:-$HOME/.local/state}/buxoro/theme" ]] || echo buxoro > "${XDG_STATE_HOME:-$HOME/.local/state}/buxoro/theme"

step "Konfiguratsiyalarni ulash (~/.config)"
for d in hypr waybar foot fuzzel rofi swaync swayosd zsh nvim yazi zathura fastfetch mpv; do
    link "$BX_DIR/config/$d" "$CFG/$d"; ok "$d"
done
# btop chiqishda sozlamalarini qayta yozadi — repozitoriya toza qolishi uchun nusxa olamiz
mkdir -p "$CFG/btop"
[[ -L $CFG/btop ]] && { mv "$CFG/btop" "$BACKUP-btop"; mkdir -p "$CFG/btop"; }
[[ -f $CFG/btop/btop.conf ]] || cp "$BX_DIR/config/btop/btop.conf" "$CFG/btop/btop.conf"
link "$BX_DIR/config/btop/themes"           "$CFG/btop/themes";           ok "btop"
link "$BX_DIR/config/starship.toml"         "$CFG/starship.toml";         ok "starship"
link "$BX_DIR/config/gtk-3.0/settings.ini"  "$CFG/gtk-3.0/settings.ini";  ok "gtk-3.0"
link "$BX_DIR/config/gtk-4.0/settings.ini"  "$CFG/gtk-4.0/settings.ini";  ok "gtk-4.0"
link "$BX_DIR/config/fontconfig/fonts.conf" "$CFG/fontconfig/fonts.conf"; ok "fontconfig"
ln -sfn "$BX_DIR/wallpapers/buxoro.png" "$CFG/hypr/wallpaper"

step "Skriptlar (~/.local/bin)"
mkdir -p "$HOME/.local/bin"
for s in "$BX_DIR"/bin/bx-*; do
    link "$s" "$HOME/.local/bin/$(basename "$s")"
done
ok "$(ls "$BX_DIR"/bin | wc -l) ta skript"

mkdir -p "$HOME/Pictures/Screenshots" "$HOME/Pictures/Wallpapers"
command -v xdg-user-dirs-update >/dev/null && xdg-user-dirs-update || true

# ── Avtomatik yangilanish (GitHub → tizim) ──
link "$BX_DIR/config/systemd/user/bx-sync.service" "$CFG/systemd/user/bx-sync.service"
link "$BX_DIR/config/systemd/user/bx-sync.timer"   "$CFG/systemd/user/bx-sync.timer"
systemctl --user daemon-reload 2>/dev/null || true
if git -C "$BX_DIR" rev-parse --abbrev-ref '@{u}' >/dev/null 2>&1; then
    if ask "GitHub'dagi o'zgarishlar avtomatik olib kelinsinmi? (har soatda tekshiriladi)"; then
        systemctl --user enable --now bx-sync.timer >/dev/null 2>&1 && ok "Avtomatik yangilanish yoqildi (bx-sync status)"
    fi
else
    warn "Repozitoriya GitHub'ga ulanmagan — avtomatik yangilanish keyin: bx-sync on"
fi

# ── 3. Shell ──────────────────────────────────────────────────────────
step "zsh"
if ! grep -qs 'ZDOTDIR' "$HOME/.zshenv"; then
    printf 'export ZDOTDIR="$HOME/.config/zsh"\n' >> "$HOME/.zshenv"
    ok "~/.zshenv yangilandi"
fi
if [[ "$(getent passwd "$USER" | cut -d: -f7)" != */zsh ]] && command -v zsh >/dev/null; then
    ask "Asosiy shell zsh ga o'zgartirilsinmi?" && chsh -s "$(command -v zsh)" && ok "Shell: zsh"
fi

# ── 4. Tizim xizmatlari ───────────────────────────────────────────────
if (( PACKAGES )); then
    step "Tizim xizmatlari"
    for svc in NetworkManager bluetooth power-profiles-daemon cups.socket cups-browsed avahi-daemon swayosd-libinput-backend; do
        if sudo systemctl enable --now "$svc" >/dev/null 2>&1; then ok "$svc"; else warn "$svc yoqilmadi"; fi
    done
    systemctl --user enable --now pipewire.socket pipewire-pulse.socket wireplumber.service >/dev/null 2>&1 || true

    # Tarmoq printerlarini nomi bilan topish (mDNS)
    if ! grep -q 'mdns_minimal' /etc/nsswitch.conf; then
        sudo sed -i 's/^hosts: \(.*\)resolve/hosts: \1mdns_minimal [NOTFOUND=return] resolve/' /etc/nsswitch.conf \
            && ok "nsswitch.conf: mDNS yoqildi"
    fi
fi

# ── 5. Ikki videokartali noutbuk (Intel + NVIDIA) ────────────────────
gpu_setup() {
    local igpu dgpu rules=/etc/udev/rules.d/61-buxoro-gpu.rules
    igpu=$(lspci -D -d ::03xx | grep -iE 'Intel|AMD|ATI' | grep -vi nvidia | head -1 | cut -d' ' -f1)
    dgpu=$(lspci -D -d ::03xx | grep -i nvidia | head -1 | cut -d' ' -f1)
    [[ -n $igpu && -n $dgpu ]] || return 0

    step "Gibrid grafika: ichki karta $igpu, NVIDIA $dgpu"
    sudo tee "$rules" >/dev/null <<RULES
# Buxoro: Hyprland uchun barqaror GPU yo'llari (bx/env.lua → AQ_DRM_DEVICES)
KERNEL=="card*", KERNELS=="$igpu", SUBSYSTEM=="drm", SUBSYSTEMS=="pci", SYMLINK+="dri/bx-igpu"
KERNEL=="card*", KERNELS=="$dgpu", SUBSYSTEM=="drm", SUBSYSTEMS=="pci", SYMLINK+="dri/bx-dgpu"
RULES
    sudo udevadm control --reload && sudo udevadm trigger --subsystem-match=drm
    ok "Ish stolini ichki karta chizadi; NVIDIA uchun: prime-run <dastur>"

    if ask "NVIDIA ishlatilmaganda uni to'liq uxlatish (RTD3, batareya uchun) yoqilsinmi?"; then
        sudo tee /etc/udev/rules.d/80-nvidia-pm.rules >/dev/null <<'RULES'
# NVIDIA kartani ishlatilmaganda o'chirish (ArchWiki: PRIME → RTD3)
ACTION=="bind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030000", TEST=="power/control", ATTR{power/control}="auto"
ACTION=="bind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030200", TEST=="power/control", ATTR{power/control}="auto"
ACTION=="unbind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030000", TEST=="power/control", ATTR{power/control}="on"
ACTION=="unbind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030200", TEST=="power/control", ATTR{power/control}="on"
RULES
        echo 'options nvidia "NVreg_DynamicPowerManagement=0x02"' | sudo tee /etc/modprobe.d/nvidia-pm.conf >/dev/null
        sudo systemctl enable nvidia-suspend.service nvidia-hibernate.service nvidia-resume.service >/dev/null 2>&1 || true
        ok "RTD3 yoqildi (qayta yuklashdan keyin ishlaydi). Tekshirish: cat /sys/bus/pci/devices/$dgpu/power/runtime_status"
    fi
}
command -v lspci >/dev/null && gpu_setup

# ── 6. Standart ilovalar va til ───────────────────────────────────────
step "Standart ilovalar"
if command -v xdg-mime >/dev/null; then
    xdg-mime default org.pwmt.zathura.desktop application/pdf
    for t in image/png image/jpeg image/webp image/gif image/svg+xml; do xdg-mime default imv.desktop "$t"; done
    for t in video/mp4 video/x-matroska video/webm audio/mpeg audio/flac; do xdg-mime default mpv.desktop "$t"; done
    xdg-mime default thunar.desktop inode/directory
    xdg-mime default nvim.desktop text/plain text/x-tex
    ok "PDF → Zathura, rasm → imv, video → mpv, papka → Thunar"
fi

if ! locale -a 2>/dev/null | grep -qi '^uz_UZ.utf8'; then
    if ask "Sana va oy nomlari o'zbekcha bo'lishi uchun uz_UZ.UTF-8 lokali yaratilsinmi?"; then
        sudo sed -i 's/^#\s*uz_UZ.UTF-8/uz_UZ.UTF-8/' /etc/locale.gen && sudo locale-gen >/dev/null && ok "uz_UZ.UTF-8 yaratildi"
    fi
fi

# ── 7. GTK mavzusi ────────────────────────────────────────────────────
if command -v gsettings >/dev/null; then
    gsettings set org.gnome.desktop.interface gtk-theme adw-gtk3-dark 2>/dev/null || true
    gsettings set org.gnome.desktop.interface color-scheme prefer-dark 2>/dev/null || true
    gsettings set org.gnome.desktop.interface icon-theme Papirus-Dark 2>/dev/null || true
    gsettings set org.gnome.desktop.interface cursor-theme Bibata-Modern-Classic 2>/dev/null || true
fi

# ── 8. Login ekrani ───────────────────────────────────────────────────
if [[ $GREETER != no ]] && (( PACKAGES )); then
    step "Login ekrani (greetd + ReGreet)"
    if ask "Buxoro login ekrani o'rnatilsinmi? (SDDM/GDM o'chiriladi)"; then
        "$BX_DIR/bin/bx-greeter" install
    fi
fi

# ── 9. Yuklanish: bootloader mavzusi va splash ────────────────────────
if [[ $BOOT == yes ]]; then
    "$BX_DIR/bin/bx-boot" all
elif [[ $BOOT == ask ]]; then
    step "Yuklanish (bootloader va splash ekrani)"
    if (( YES )); then
        warn "Bootloader'ga --yes rejimida tegilmaydi. Keyin: bx-boot all  (yoki ./install.sh --boot)"
    elif ask "Bootloader mavzusi, Plymouth splash va tez yuklanish sozlansinmi? (fayllar zaxiralanadi)" n; then
        "$BX_DIR/bin/bx-boot" all
    else
        warn "O'tkazib yuborildi. Keyin: bx-boot all"
    fi
fi

rm -f "${XDG_STATE_HOME:-$HOME/.local/state}/buxoro/sync-pending"   # bx-sync eslatmalari bajarildi

# ── Tayyor ────────────────────────────────────────────────────────────
printf '\n%s✓ Buxoro o‘rnatildi.%s\n' "$c_ok" "$c_off"
[[ -d $BACKUP ]] && printf '  Eski fayllar: %s\n' "${BACKUP/#$HOME/\~}"
cat <<MSG

  Ishga tushirish:  kompyuterni qayta yuklang — Buxoro login ekranida "Hyprland" ni tanlang
                    (login ekrani o'rnatilmagan bo'lsa: TTY1 da kiring, Hyprland o'zi ochiladi).
  Holatni tekshirish: bx-doctor
  Tugmalar ro'yxati: SUPER + /
  Mavzu almashtirish: SUPER + SHIFT + T

MSG
