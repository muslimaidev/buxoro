# ── Buxoro — zsh ────────────────────────────────────────────────────
# Plaginlar pacman orqali o'rnatilgan, plagin menejeri yo'q: ishga tushish ~30 ms.

export EDITOR=nvim VISUAL=nvim PAGER=less
export MANPAGER="nvim +Man!"
export BAT_THEME=ansi                  # terminal ranglari = mavzu ranglari
export LESS="-R --mouse"
typeset -U path
path=("$HOME/.local/bin" $path)

# Mavzuga bog'liq ranglar (fzf va h.k.) — bx-theme yaratadi
[[ -r "$ZDOTDIR/colors.zsh" ]] && source "$ZDOTDIR/colors.zsh"

# ── Tarix ──────────────────────────────────────────────────────────────
HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"
[[ -d ${HISTFILE:h} ]] || mkdir -p ${HISTFILE:h}
HISTSIZE=50000
SAVEHIST=50000
setopt extended_history hist_ignore_all_dups hist_ignore_space hist_reduce_blanks
setopt share_history inc_append_history
setopt auto_cd auto_pushd pushd_ignore_dups interactive_comments extended_glob
setopt no_beep

# ── Avtoto'ldirish (kesh bilan — kuniga bir marta yangilanadi) ─────────
autoload -Uz compinit
_zcomp="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"
[[ -d ${_zcomp:h} ]] || mkdir -p ${_zcomp:h}
if [[ -n ${_zcomp}(#qN.mh+24) ]]; then compinit -d "$_zcomp"; else compinit -C -d "$_zcomp"; fi
unset _zcomp
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{cyan}── %d ──%f'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/compcache"

# ── Klaviatura ─────────────────────────────────────────────────────────
bindkey -e
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word
bindkey '^[[3~' delete-char
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line

# ── Vositalar ──────────────────────────────────────────────────────────
command -v fzf      >/dev/null && source <(fzf --zsh)
command -v zoxide   >/dev/null && eval "$(zoxide init zsh --cmd cd)"
command -v starship >/dev/null && eval "$(starship init zsh)"

# ── Qisqartmalar ───────────────────────────────────────────────────────
if command -v eza >/dev/null; then
  alias ls='eza --icons=auto --group-directories-first'
  alias ll='eza -l --icons=auto --group-directories-first --git --time-style=relative'
  alias la='eza -la --icons=auto --group-directories-first --git --time-style=relative'
  alias lt='eza --tree --level=2 --icons=auto'
fi
command -v bat >/dev/null && alias cat='bat -pp'
alias grep='grep --color=auto'
alias ip='ip -color=auto'
alias df='df -h' du='du -h' free='free -h'
alias v='nvim' vim='nvim'
alias ff='fastfetch'
alias update='bx-update'
alias pac='sudo pacman'
alias orphans='pacman -Qdtq'
alias ..='cd ..' ...='cd ../..'
alias tex='latexmk -lualatex -pvc -interaction=nonstopmode'   # avtomatik qayta kompilyatsiya

# yazi dan chiqqanda o'sha papkada qolish
y() {
  local tmp cwd
  tmp="$(mktemp -t yazi-cwd.XXXXXX)"
  yazi "$@" --cwd-file="$tmp"
  IFS= read -r -d '' cwd < "$tmp"
  [[ -n "$cwd" && "$cwd" != "$PWD" ]] && builtin cd -- "$cwd"
  rm -f -- "$tmp"
}

# Arxivni ochish: x fayl.zip
x() {
  case "$1" in
    *.tar.gz|*.tgz)   tar xzf "$1" ;;
    *.tar.xz|*.txz)   tar xJf "$1" ;;
    *.tar.zst)        tar --zstd -xf "$1" ;;
    *.tar.bz2)        tar xjf "$1" ;;
    *.tar)            tar xf "$1" ;;
    *.zip)            unzip "$1" ;;
    *.7z)             7z x "$1" ;;
    *.rar)            unrar x "$1" ;;
    *.gz)             gunzip "$1" ;;
    *) echo "x: '$1' — noma'lum format" >&2; return 1 ;;
  esac
}

# ── Plaginlar (oxirida yuklanishi kerak) ───────────────────────────────
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=40
for _p in \
  /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh \
  /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh; do
  [[ -r $_p ]] && source $_p
done
unset _p

# Shaxsiy qo'shimchalar (gitga kirmaydi)
[[ -r "$ZDOTDIR/local.zsh" ]] && source "$ZDOTDIR/local.zsh"
