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

        case "$distro" in
            arch|archarm)
                pm="pacman"
                icon=""
                color="ARCH"
                ;;

            endeavouros)
                pm="pacman"
                icon=""
                color="ENDEAVOUR"
                ;;

            manjaro|manjaro-arm)
                pm="pacman"
                icon=""
                color="MANJARO"
                ;;

            ubuntu)
                pm="apt"
                icon=""
                color="UBUNTU"
                ;;

            debian)
                pm="apt"
                icon=""
                color="DEBIAN"
                ;;

            fedora)
                pm="dnf"
                icon=""
                color="FEDORA"
                ;;

            opensuse*|opensuse-leap|opensuse-tumbleweed)
                pm="zypper"
                icon=""
                color="OPENSUSE"
                ;;

            alpine)
                pm="apk"
                icon=""
                color="ALPINE"
                ;;

            nixos)
                pm="nix"
                icon=""
                color="NIXOS"
                ;;

            void)
                pm="xbps"
                icon=""
                color="VOID"
                ;;

            *)
                # Unknown/derivative ID not matched above (e.g. spins,
                # rebrands, future ARM variants) — fall back to the
                # closest known family via ID_LIKE before giving up.
                
                case "$family" in
                    *arch*)
                        pm="pacman"
                        icon=""
                        color="ARCH"
                        ;;

                    *debian*)
                        pm="apt"
                        icon=""
                        color="DEBIAN"
                        ;;
                    
                    *ubuntu*)
                        pm="apt"
                        icon=""
                        color="UBUNTU"
                        ;;

                    *fedora*|*rhel*)
                        pm="dnf"
                        icon=""
                        color="FEDORA"
                        ;;

                    *suse*)
                        pm="zypper"
                        icon=""
                        color="OPENSUSE"
                        ;;

                    *)
                        pm=""
                        icon=""
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
