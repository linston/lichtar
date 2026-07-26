# =============================================================================
# lichtar — widgets/yazi.zsh
# Yazi file manager integration with cd-on-exit
# =============================================================================

if (( ${LICHTAR_YAZI:-1} )); then

    # Relocate yazi's config (settings, flavors/themes, plugins) into lichtar's
    # own tree, so the whole setup is portable in one folder
    export YAZI_CONFIG_HOME="$LICHTAR_HOME/yazi"

    function y() {
        local tmp cwd
        tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
        command yazi "$@" --cwd-file="$tmp"
        if cwd="$(cat -- "$tmp")" && [[ -n "$cwd" && "$cwd" != "$PWD" ]]; then builtin cd -- "$cwd"; fi
        rm -f -- "$tmp"
    }

fi
