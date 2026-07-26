# =============================================================================
# ~/.lichtar/bin/lichtar_doctor.zsh
# lichtar doctor — diagnoses dependencies, plugins, config, caches, Nerd Font.
#
# Usage:
#   lichtar doctor           — diagnose only, ask before fixing each issue
#   lichtar doctor --fix     — diagnose and auto-fix what's fixable, no prompts
#   lichtar doctor --no-font — skip the interactive Nerd Font glyph check
# =============================================================================

_lichtar_doctor() {
    : "${LICHTAR_HOME:=$HOME/.lichtar}"

    # ── System info (package manager / platform for hints below) ───────────
    # Same lazy-generate pattern as init.zsh / lichtar_system.zsh — don't
    # assume Termux just because the cache hasn't been built yet.
    if [[ ! -f "$LICHTAR_HOME/cache/system.env" ]]; then
        source "$LICHTAR_HOME/bin/system_detect.zsh"
        detect_system
    fi
    source "$LICHTAR_HOME/cache/system.env"
    local PM="${LICHTAR_PACKAGE_MANAGER:-}"

    local AUTOFIX=0
    local SKIP_FONT_CHECK=0
    local NO_COLOR=0

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --fix)      AUTOFIX=1 ;;
            --no-font)  SKIP_FONT_CHECK=1 ;;
            --no-color) NO_COLOR=1 ;;
            -h|--help)
                cat <<EOF
Usage: lichtar doctor [options]

Diagnoses lichtar's environment: dependencies, plugin status,
directory structure, caches, .env, and Nerd Font glyph rendering.

Options:
  --fix         Auto-fix issues that can be fixed safely (no prompts)
  --no-font     Skip the interactive Nerd Font glyph check
  --no-color    Disable ANSI colors
  -h, --help    Show this help
EOF
                return 0
                ;;
            *) echo "Unknown option: $1"; return 1 ;;
        esac
        shift
    done

    # ── Theme colors ─────────────────────────────────────────────────────────
    local B NC HDR ACC WRN KEY TXT TXM
    local S1 S2 S3 S4 S5 S6 S7
    if (( NO_COLOR == 0 )); then
        local _hex2a() {
            local hex="${1#\#}"
            local r=$((16#${hex:0:2})) g=$((16#${hex:2:2})) b=$((16#${hex:4:2}))
            printf "\e[38;2;%d;%d;%dm" $r $g $b
        }
        B=$'\e[1m'; NC=$'\e[0m'
        HDR="$(_hex2a "${CL_MTN_HDR:-#80a08a}")"
        ACC="$(_hex2a "${CL_MTN_ACC:-#94e2d5}")"
        WRN="$(_hex2a "${CL_MTN_WRN:-#f38ba8}")"
        KEY="$(_hex2a "${CL_MTN_KEY:-#a6e3bf}")"
        TXT="$(_hex2a "${CL_MTN_TXT:-#cdd6f4}")"
        TXM="$(_hex2a "${CL_MTN_TXM:-#6c7086}")"

        # Section icon colors — one distinct hue per section, theme-sourced
        S1="$(_hex2a "${CL_RST:-#b08a70}")"   # Dependencies      
        S2="$(_hex2a "${CL_GOL:-#8088c0}")"   # Minimum Versions  󰬹
        S3="$(_hex2a "${CL_GAH:-#94e2d5}")"   # Nerd Font         󰛖
        S4="$(_hex2a "${CL_PYT:-#8a9a8a}")"   # Directory Struct  
        S5="$(_hex2a "${CL_MTN_ZSH:-#fab387}")" # Zsh Plugins     󰊢
        S6="$(_hex2a "${CL_GUC:-#eba0ac}")"   # Caches            󰆼
        S7="$(_hex2a "${CL_MTN_YZI:-#89b4fa}")" # Configuration   
    else
        B="" NC="" HDR="" ACC="" WRN="" KEY="" TXT="" TXM=""
        S1="" S2="" S3="" S4="" S5="" S6="" S7=""
    fi

    has()     { command -v "$1" >/dev/null 2>&1; }
    section() { printf "\n  ${B}${TXT}%s${NC}\n" "$1"; }
    ok()      { printf "  ${KEY}${B}✔${NC}  ${TXT}%s${NC}\n" "$1"; }
    skip()    { printf "  ${TXM}◦${NC}  ${TXM}%s${NC}\n" "$1"; }
    warn()    { printf "  ${WRN}✘${NC}  ${TXT}%s${NC}\n" "$1"; }
    detail()  { printf "     ${TXM}↳ %s${NC}\n" "$1"; }
    ask()     { printf "  ${ACC}?${NC}  ${TXT}%s${NC} ${TXM}[y/N]${NC} " "$1"; }

    pkg_install_hint() {
        # $1 = package name — install command for the detected package manager
        case "$PM" in
            pkg)     echo "pkg install $1" ;;
            pacman)  echo "pacman -S $1" ;;
            apt)     echo "apt install $1" ;;
            dnf)     echo "dnf install $1" ;;
            zypper)  echo "zypper install $1" ;;
            apk)     echo "apk add $1" ;;
            xbps)    echo "xbps-install $1" ;;
            nix)     echo "nix-env -iA nixpkgs.$1" ;;
            *)       echo "install '$1' using your system's package manager" ;;
        esac
    }

    pkg_upgrade_hint() {
        # $1 = package name — upgrade command for the detected package manager
        case "$PM" in
            pkg)     echo "pkg upgrade $1" ;;
            pacman)  echo "pacman -S $1" ;;
            apt)     echo "apt install --only-upgrade $1" ;;
            dnf)     echo "dnf upgrade $1" ;;
            zypper)  echo "zypper update $1" ;;
            apk)     echo "apk upgrade $1" ;;
            xbps)    echo "xbps-install -u $1" ;;
            nix)     echo "nix-env -u $1" ;;
            *)       echo "upgrade '$1' using your system's package manager" ;;
        esac
    }

    local ISSUES=0
    local FIXED=0

    confirm_fix() {
        # $1 = description, $2.. = fix command
        local desc="$1"; shift
        if (( AUTOFIX == 1 )); then
            "$@" && { ok "Fixed: $desc"; (( FIXED++ )); return 0; }
            warn "Fix failed: $desc"
            return 1
        fi
        ask "Fix now — $desc?"
        local reply
        read -r reply
        if [[ "$reply" == [yY]* ]]; then
            "$@" && { ok "Fixed: $desc"; (( FIXED++ )); return 0; }
            warn "Fix failed: $desc"
            return 1
        else
            skip "Skipped: $desc"
            return 1
        fi
    }

    _doctor_cleanup() {
        # same leak as lichtar_update.zsh — local funcname() {} doesn't scope
        # in zsh, so clean up explicitly on every exit from this function
        unfunction has section ok skip warn detail ask confirm_fix \
            pkg_install_hint pkg_upgrade_hint \
            version_ge check_min_version _hex2a _doctor_cleanup 2>/dev/null
    }
    trap _doctor_cleanup EXIT
    
    printf "\n"
    printf "  ${HDR}${B}          LICHTAR  DOCTOR            ${NC}\n"
    printf "  ${ACC}${B}─────────────────────────────────────${NC}\n"
    (( AUTOFIX == 1 )) && detail "Auto-fix mode — fixable issues will be resolved without prompting"

    # =========================================================================
    # 1. Core dependencies
    # =========================================================================
    section "${S1}${B}${NC}  Dependencies"

    local -a REQUIRED=(zsh git curl fzf zoxide eza fd bat yazi unzip less)
    local -a OPTIONAL=(neovim unrar zstd ptpython micro)
    local dep

    for dep in "${REQUIRED[@]}"; do
        if has "$dep"; then
            ok "$dep"
        else
            warn "$dep — not found"
            detail "$(pkg_install_hint "$dep")"
            (( ISSUES++ ))  
        fi
    done

    for dep in "${OPTIONAL[@]}"; do
        if has "$dep"; then
            ok "$dep (optional)"
        else
            skip "$dep (optional) — not found"
        fi
    done

    if has p7zip || has 7z || has 7za; then
        ok "p7zip"
    else
        warn "p7zip — not found"
        detail "$(pkg_install_hint "p7zip")"
        (( ISSUES++ ))
    fi

    # =========================================================================
    # 2. Minimum versions
    # =========================================================================
    section "${S2}${B}󰬹${NC}  Minimum Versions"

    version_ge() {
        # returns 0 if $1 >= $2  (dotted version strings)
        [[ "$1" == "$2" ]] && return 0
        local IFS=.
        local -a v1=(${=1}) v2=(${=2})
        local i
        for (( i = 1; i <= ${#v1[@]} || i <= ${#v2[@]}; i++ )); do
            local a=${v1[i]:-0} b=${v2[i]:-0}
            (( a > b )) && return 0
            (( a < b )) && return 1
        done
        return 0
    }

    check_min_version() {
        local tool="$1" min="$2" raw_version="$3"
        local ver
        ver=$(echo "$raw_version" | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1)
        if [[ -z "$ver" ]]; then
            skip "$tool — could not parse version"
            return
        fi
        if version_ge "$ver" "$min"; then
            ok "$tool $ver  (>= $min)"
        else
            warn "$tool $ver  — below minimum $min"
            detail "$(pkg_upgrade_hint "$tool")"
            (( ISSUES++ ))
        fi
    }

    has fzf    && check_min_version "fzf"    "0.40" "$(fzf --version 2>/dev/null)"
    has zoxide && check_min_version "zoxide" "0.9"  "$(zoxide --version 2>/dev/null)"
    has eza    && check_min_version "eza"    "0.15" "$(eza --version 2>/dev/null)"

    # =========================================================================
    # 3. Nerd Font
    # =========================================================================
    section "${S3}${B}󰛖${NC}  Nerd Font"

    if [[ "${LICHTAR_PLATFORM:-}" == "android" ]]; then
        local font_path="$HOME/.termux/font.ttf"
        if [[ -f "$font_path" ]]; then
            ok "font.ttf installed (~/.termux/font.ttf)"
        else
            warn "font.ttf not found (~/.termux/font.ttf)"
            detail "curl -fLo ~/.termux/font.ttf <Nerd Font URL>"
            detail "termux-reload-settings"
            (( ISSUES++ ))
        fi
    else
        skip "Font file check skipped — not Termux; your terminal emulator manages its own font"
    fi

    if (( SKIP_FONT_CHECK == 0 )) && [[ -t 1 ]]; then
        printf "\n  ${TXT}Glyph test:${NC}      󰣀  ⇡ ⇣  \n"
        ask "Do these render as icons (not boxes/question marks)?"
        local reply
        read -r reply
        if [[ "$reply" == [yY]* ]]; then
            ok "Nerd Font glyphs render correctly"
        else
            warn "Nerd Font glyphs not rendering"
            if [[ "${LICHTAR_PLATFORM:-}" == "android" ]]; then
                detail "Re-check font selection in Termux's terminal style menu"
            else
                detail "Install a Nerd Font and set it in your terminal emulator's font settings"
            fi
            detail "See: lichtar help install"
            (( ISSUES++ ))
        fi
    else
        skip "Glyph check skipped"
    fi

    # =========================================================================
    # 4. Directory structure
    # =========================================================================
    section "${S4}${B}${NC}  Directory Structure"

    local -a REQUIRED_DIRS=(bin cache core help plugins themes ui widgets)
    local d_name d_path

    for d_name in "${REQUIRED_DIRS[@]}"; do
        d_path="$LICHTAR_HOME/$d_name"
        if [[ -d "$d_path" ]]; then
            ok "~/.lichtar/$d_name/"
        else
            warn "~/.lichtar/$d_name/ — missing"
            (( ISSUES++ ))
            confirm_fix "create ~/.lichtar/$d_name/" mkdir -p "$d_path"
        fi
    done

    if [[ -n "$YAZI_CONFIG_HOME" && -d "$YAZI_CONFIG_HOME" ]]; then
        ok "yazi config relocated (\$YAZI_CONFIG_HOME)"
    fi
    
    if [[ -n "$MICRO_CONFIG_HOME" && -d "$MICRO_CONFIG_HOME" ]]; then
        ok "micro config relocated (\$MICRO_CONFIG_HOME)"
    fi

    # =========================================================================
    # 5. Plugins
    # =========================================================================
    section "${S5}${B}󰊢${NC}  Zsh Plugins"

    local -a EXPECTED_PLUGINS=(
        zsh-autosuggestions
        zsh-history-substring-search
        fzf-tab
        fast-syntax-highlighting
        zsh-autopair
    )
    local p p_path

    for p in "${EXPECTED_PLUGINS[@]}"; do
        p_path="$LICHTAR_HOME/plugins/$p"
        if [[ -d "$p_path/.git" ]]; then
            ok "$p"
        elif [[ -d "$p_path" ]]; then
            warn "$p — present but not a git repo"
            (( ISSUES++ ))
        else
            warn "$p — not installed"
            detail "see: lichtar help install"
            (( ISSUES++ ))
        fi
    done

    # =========================================================================
    # 6. Caches
    # =========================================================================
    section "${S6}${B}󰆼${NC}  Caches"

    local cache_dir="$LICHTAR_HOME/cache"
    if [[ -d "$cache_dir" ]]; then
        local zcd="$cache_dir/zcompdump"
        if [[ -f "$zcd" ]]; then
            local age_h=$(( ( $(date +%s) - $(stat -c %Y "$zcd" 2>/dev/null || stat -f %m "$zcd" 2>/dev/null || echo 0) ) / 3600 ))
            ok "zcompdump  (age: ${age_h}h)"
        else
            skip "zcompdump — not yet generated"
        fi
    else
        skip "cache directory not found — covered in Directory Structure above"
    fi

    # =========================================================================
    # 7. Config
    # =========================================================================
    section "${S7}${B}${NC}  Configuration"

    if [[ -f "$LICHTAR_HOME/.env" ]]; then
        ok ".env present"

        if [[ -f "$LICHTAR_HOME/.env.example" ]]; then
            local -a known_vars user_vars unknown_vars
            known_vars=(${(f)"$(grep -oE '^LICHTAR_[A-Z_]+' "$LICHTAR_HOME/.env.example")"})
            user_vars=(${(f)"$(grep -oE '^LICHTAR_[A-Z_]+' "$LICHTAR_HOME/.env")"})
            local v
            for v in "${user_vars[@]}"; do
                [[ -z "${known_vars[(r)$v]}" ]] && unknown_vars+=("$v")
            done
            if (( ${#unknown_vars[@]} > 0 )); then
                warn "${#unknown_vars[@]} unrecognized variable(s) in .env"
                local uv
                for uv in "${unknown_vars[@]}"; do
                    detail "$uv — not in .env.example, possibly renamed or removed"
                done
                (( ISSUES++ ))
            fi
        fi
    else
        warn ".env missing"
        detail "lichtar uses defaults; copy .env.example if available"
        (( ISSUES++ ))
    fi

    if [[ -f "$HOME/.zshrc" ]]; then
        if grep -q "lichtar" "$HOME/.zshrc" 2>/dev/null; then
            ok "~/.zshrc sources lichtar"
        else
            warn "~/.zshrc does not appear to source lichtar"
            (( ISSUES++ ))
        fi
    else
        warn "~/.zshrc not found"
        (( ISSUES++ ))
    fi

    # =========================================================================
    # Footer
    # =========================================================================
    printf "\n  ${ACC}${B}─────────────────────────────────────${NC}\n"

    if (( ISSUES == 0 )); then
        ok "No issues found — lichtar is healthy"
    else
        if (( AUTOFIX == 1 || FIXED > 0 )); then
            printf "  ${KEY}${B}✔${NC}  ${TXT}%d issue(s) found, %d fixed${NC}\n" "$ISSUES" "$FIXED"
        else
            warn "$ISSUES issue(s) found"
            detail "Run with --fix to resolve automatically where possible"
        fi
    fi
    printf "\n"

    (( ISSUES > FIXED )) && return 1
    return 0
}
