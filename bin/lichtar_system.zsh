# =============================================================================
# ~/.lichtar/bin/lichtar_system.zsh
# lichtar system — shows or refreshes the cached system-detection info
# used by prompt.zsh, install.sh, and lichtar doctor/update.
#
# Usage:
#   lichtar system           — show cached platform/distro/icon info
#   lichtar system --force   — re-run detection and overwrite the cache
# =============================================================================

_lichtar_system() {
    : "${LICHTAR_HOME:=$HOME/.lichtar}"

    local FORCE=0
    local NO_COLOR=0

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --force|-f) FORCE=1 ;;
            --no-color) NO_COLOR=1 ;;
            -h|--help)
                cat <<EOF
Usage: lichtar system [options]

Shows the cached system-detection info (platform, distro, package
manager, prompt icon/color) that prompt, doctor, update, and install
all read from the same place: ~/.lichtar/cache/system.env

Options:
  --force, -f   Re-run detection now and overwrite the cache
  --no-color    Disable ANSI colors
  -h, --help    Show this help
EOF
                return 0
                ;;
            *) echo "Unknown option: $1"; return 1 ;;
        esac
        shift
    done

    if (( FORCE == 1 )) || [[ ! -f "$LICHTAR_HOME/cache/system.env" ]]; then
        source "$LICHTAR_HOME/bin/system_detect.zsh"
        detect_system
    fi

    source "$LICHTAR_HOME/cache/system.env"

    local B NC HDR TXT TXM ACC BADGE
    if (( NO_COLOR == 0 )); then
        _hex2a() {
            local hex="${1#\#}"
            local r=$((16#${hex:0:2})) g=$((16#${hex:2:2})) b=$((16#${hex:4:2}))
            printf "\e[38;2;%d;%d;%dm" $r $g $b
        }
        B=$'\e[1m'; NC=$'\e[0m'
        HDR="$(_hex2a "${CL_MTN_HDR:-#80a08a}")"
        TXT="$(_hex2a "${CL_MTN_TXT:-#cdd6f4}")"
        TXM="$(_hex2a "${CL_MTN_TXM:-#6c7086}")"
        ACC="$(_hex2a "${CL_MTN_ACC:-#94e2d5}")"
        local _color_var="CL_DISTRO_${LICHTAR_ICON_COLOR:-DEFAULT}"
        BADGE="$(_hex2a "${(P)_color_var:-#7c7f93}")"
    else
        B="" NC="" HDR="" TXT="" TXM="" ACC="" BADGE=""
    fi

    # same "local funcname() doesn't scope in zsh" gotcha as doctor/update —
    # clean up explicitly on every exit
    _system_cleanup() {
        unfunction _hex2a _system_cleanup 2>/dev/null
    }
    trap _system_cleanup EXIT

    printf "\n  ${HDR}${B}          LICHTAR  SYSTEM            ${NC}\n"
    printf "  ${ACC}${B}─────────────────────────────────────${NC}\n\n"
    printf "  ${BADGE}${B}%s ${NC}${TXT}${B}%s${NC}\n\n" "$LICHTAR_ICON" "${LICHTAR_DISTRO:-unknown}"
    printf "  ${TXM}Platform         ${NC}${TXT}%s${NC}\n" "${LICHTAR_PLATFORM:-unknown}"
    printf "  ${TXM}Package manager  ${NC}${TXT}%s${NC}\n" "${LICHTAR_PACKAGE_MANAGER:-none}"
    printf "  ${TXM}Icon color key   ${NC}${TXT}%s${NC}\n\n" "${LICHTAR_ICON_COLOR:-DEFAULT}"

    if (( FORCE == 1 )); then
        printf "  ${TXM}Cache regenerated: %s${NC}\n\n" "$LICHTAR_HOME/cache/system.env"
    fi
}
