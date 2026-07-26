# =============================================================================
# lichtar theme — Catppuccin Mocha
# https://github.com/catppuccin/catppuccin
#
# All color values are hex (#rrggbb).
# Exception: CL_MAN_* use ANSI SGR codes (e.g. "1;32") because they are
# passed directly to LESS_TERMCAP_* variables, not to zsh %F{}.
#
# To create a new theme: copy this file, rename it, change the hex values.
# Load it by setting LICHTAR_THEME=your-theme-name in .env
# =============================================================================


# ── Distros  ─────────────────────────────────────────────────────────────────
export CL_DISTRO_ANDROID="#80f080" 
export CL_DISTRO_ARCH="#04a5e5"
export CL_DISTRO_ENDEAVOUR="#8839ef"
export CL_DISTRO_MANJARO="#40f912"
export CL_DISTRO_UBUNTU="#fab387" 
export CL_DISTRO_DEBIAN="#d20f39"
export CL_DISTRO_FEDORA="#1e66f5"
export CL_DISTRO_OPENSUSE="#40a02b"
export CL_DISTRO_ALPINE="#8acfbc"
export CL_DISTRO_NIXOS="#89b4fa"
export CL_DISTRO_VOID="#a6e3a1"
export CL_DISTRO_LINUX="#9399b2"
export CL_DISTRO_DEFAULT="#7c7f93"

# ── Path ─────────────────────────────────────────────────────────────────────
export CL_DVD="#6c7086"   # dividers: / and …
export CL_LNL="#313244"   # └─ line
export CL_CDR="#94e2d5"   # current directory
export CL_PDR="#78b0a0"   # parent directory
export CL_GDR="#587068"   # grandparent directory

# ── Prompt elements ───────────────────────────────────────────────────────────
export CL_TIM="#6c7086"   # clock and time (RPROMPT)
export CL_DUR="#6c7086"   # command duration (RPROMPT)
export CL_BJB="#fab387"   # background jobs indicator
export CL_SCS="#cdd6f4"   # success arrow ❯
export CL_FLR="#f38ba8"   # failure arrow ❯
export CL_ERR="#f38ba8"   # error code ✘
export CL_LOK="#eba0ac"   # locked directory 🔒 and root badge
export CL_SSH="#94e2d5"   # SSH badge 󰣀

# ── Git ───────────────────────────────────────────────────────────────────────
export CL_GIF="#585b70"   # git icon 
export CL_GBR="#8088c0"   # branch name
export CL_GUC="#eba0ac"   # unstaged changes ●
export CL_GSC="#74c7ec"   # staged changes ●
export CL_GAB="#cba6f7"   # stash ⚑
export CL_GAH="#94e2d5"   # ahead ⇡
export CL_GBH="#eba0ac"   # behind ⇣

# ── Languages ─────────────────────────────────────────────────────────────────
export CL_PYT="#8a9a8a"   # Python
export CL_NOD="#b0a080"   # Node.js
export CL_RST="#b08a70"   # Rust
export CL_GOL="#8088c0"   # Go
export CL_PHP="#a080a8"   # PHP
export CL_RBL="#a88088"   # Ruby
export CL_JAV="#a87880"   # Java
export CL_LUA="#80a090"   # Lua
export CL_CPP="#7a88b8"   # C/C++
export CL_ZIG="#b89068"   # Zig
export CL_DEN="#8098a0"   # Deno
export CL_BUN="#c8b898"   # Bun

# ── Maintenance ─────────────────────────────────────────────────────────────
export CL_MTN_LHT="#89dceb"   # lichtar
export CL_MTN_YZI="#89b4fa"   # yazi plugins
export CL_MTN_ZSH="#fab387"   # zsh plugins
export CL_MTN_HDR="#80a08a"   # headers
export CL_MTN_KEY="#a6e3bf"   # keys / commands
export CL_MTN_ACC="#94e2d5"   # accents
export CL_MTN_WRN="#f38ba8"   # warnings
export CL_MTN_TXT="#cdd6f4"   # text
export CL_MTN_TXM="#6c7086"   # text muted

# ── Help system ─────────────────────────────────────────────────────────────
export CL_HLP_HDR="#f9e2af"   # headers
export CL_HLP_KEY="#a6e3a1"   # keys / commands
export CL_HLP_SEC="#fab387"   # section titles
export CL_HLP_EXM="#89b4fa"   # example commands
export CL_HLP_SEP="#585b70"   # separators and notes
export CL_HLP_TXT="#a6adc8"   # body text
export CL_HLP_WRN="#f38ba8"   # warnings
export CL_HLP_ACC="#94e2d5"   # accents
export CL_HLP_VAL="#cdd6f4"   # values

# ── bat ─────────────────────────────────────────────────────────────────────
export BAT_CONFIG_DIR="$HOME/.lichtar/themes/bat/"
export BAT_THEME="Catppuccin Mocha"

# ── eza ─────────────────────────────────────────────────────────────────────
export EZA_CONFIG_DIR="$HOME/.lichtar/themes/eza"

# ── fzf ──────────────────────────────────────────────────────────────────────
source "$HOME/.lichtar/themes/fzf/catppuccin-fzf-mocha.sh"
zstyle ':fzf-tab:*' use-fzf-default-opts yes

# ── zsh-autosuggestions ───────────────────────────────────────────────────────
export CL_SUG="#585b70"   # suggestion text color (Overlay0 — subtle, not distracting)

# ── fast-syntax-highlighting ──────────────────────────────────────────────────
# NOTE: only exports the theme path here — the actual `fast-theme` call must
# happen AFTER the plugin is loaded (see plugins/load.zsh)
export CL_FSH_THEME_INI="$LICHTAR_HOME/themes/fast-syntax-highlighting/catppuccin-mocha.ini"

# ── Man pages (ANSI SGR codes, not hex) ───────────────────────────────────────
CL_MAN_HDR="38;5;189"  # bold headings
CL_MAN_USR="38;5;116"  # underlined arguments
CL_MAN_SRC="38;5;216"  # search highlights
