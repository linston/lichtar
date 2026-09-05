#!/usr/bin/env zsh

detect_system() {
    local platform distro pm icon color family

    if [[ -n "$TERMUX_VERSION" ]]; then
        platform="android"
        distro="termux"
        pm="pkg"
        icon=""
        color="ANDROID"

    elif [[ -r /etc/os-release ]]; then
        source /etc/os-release

        platform="linux"
        distro="${ID:-unknown}"
        family="${ID_LIKE:-}"

        # Package manager: shared with install.sh via bin/data/distro-pkgmanager.txt
        # (see that file's header for why this can't just be a sourced .zsh file).
        pm=""
        local _pmdata="$LICHTAR_HOME/bin/data/distro-pkgmanager.txt"
        local _pmline _pmpattern
        if [[ -r "$_pmdata" ]]; then
            while IFS= read -r _pmline; do
                [[ -z "$_pmline" || "$_pmline" == \#* || "$_pmline" == LIKE:* ]] && continue
                _pmpattern="${_pmline%:*}"
                if [[ "$distro" == ${~_pmpattern} ]]; then
                    pm="${_pmline##*:}"
                    break
                fi
            done < "$_pmdata"
            if [[ -z "$pm" ]]; then
                while IFS= read -r _pmline; do
                    [[ "$_pmline" == LIKE:* ]] || continue
                    _pmline="${_pmline#LIKE:}"
                    _pmpattern="${_pmline%:*}"
                    if [[ "$family" == ${~_pmpattern} ]]; then
                        pm="${_pmline##*:}"
                        break
                    fi
                done < "$_pmdata"
            fi
        fi

        # Icon/color: purely zsh/UI-side data, never duplicated in install.sh,
        # so it stays a plain case statement rather than living in the shared file.
        case "$distro" in
            arch|archarm)
                icon=""
                color="ARCH"
                ;;

            endeavouros)
                icon=""
                color="ENDEAVOUR"
                ;;

            manjaro|manjaro-arm)
                icon=""
                color="MANJARO"
                ;;

            ubuntu)
                icon=""
                color="UBUNTU"
                ;;

            debian)
                icon=""
                color="DEBIAN"
                ;;

            fedora)
                icon=""
                color="FEDORA"
                ;;

            opensuse*)
                icon=""
                color="OPENSUSE"
                ;;

            alpine)
                icon=""
                color="ALPINE"
                ;;

            nixos)
                icon=""
                color="NIXOS"
                ;;

            void)
                icon=""
                color="VOID"
                ;;

            *)
                # Unknown/derivative ID not matched above (e.g. spins,
                # rebrands, future ARM variants) — fall back to the
                # closest known family via ID_LIKE before giving up.
                case "$family" in
                    *arch*)
                        icon=""
                        color="ARCH"
                        ;;

                    *debian*)
                        icon=""
                        color="DEBIAN"
                        ;;

                    *ubuntu*)
                        icon=""
                        color="UBUNTU"
                        ;;

                    *fedora*|*rhel*)
                        icon=""
                        color="FEDORA"
                        ;;

                    *suse*)
                        icon=""
                        color="OPENSUSE"
                        ;;

                    *)
                        icon=""
                        color="LINUX"
                        ;;
                esac
                ;;
        esac

    else
        platform="unknown"
        distro="unknown"
        pm=""
        icon="?"
        color="DEFAULT"
    fi

    mkdir -p "$LICHTAR_HOME/cache"

    cat > "$LICHTAR_HOME/cache/system.env" <<EOF

LICHTAR_PLATFORM=$platform
LICHTAR_DISTRO=$distro
LICHTAR_PACKAGE_MANAGER=$pm
LICHTAR_ICON=$icon
LICHTAR_ICON_COLOR=$color
EOF
}
