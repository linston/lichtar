# =============================================================================
# ~/.lichtar/bin/lichtar_changelog.zsh
# lichtar changelog — pages CHANGELOG.md
# =============================================================================

_lichtar_changelog() {
    : "${LICHTAR_HOME:=$HOME/.lichtar}"

    if [[ ! -f "$LICHTAR_HOME/CHANGELOG.md" ]]; then
        echo "[lichtar] CHANGELOG.md not found at $LICHTAR_HOME" >&2
        return 1
    fi

    less -R \
        --prompt="  lichtar changelog — / search  n/N next/prev  q quit " \
        -j4 \
        "$LICHTAR_HOME/CHANGELOG.md"
}
