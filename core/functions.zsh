# =============================================================================
# lichtar — functions.zsh
# Shell functions: extract, mkcd, up, zrc
# =============================================================================

mkcd() { mkdir -p "$1" && cd "$1" }

up() { local p=""; repeat "${1:-1}" p+="../"; cd "${p:-.}"; }

extract() {
    case "$1" in
        *.tar.bz2) tar xjf "$1" ;;
        *.tar.gz)  tar xzf "$1" ;;
        *.tgz)     tar xzf "$1" ;;
        *.tar.xz)  tar xJf "$1" ;;
        *.zip)     unzip "$1" ;;
        *.7z)      7z x "$1" ;;
        *.rar)     unrar x "$1" ;;
        *.tar.zst) tar --zstd -xf "$1" ;;
        *.tar)     tar xf "$1" ;;
        *.gz)      gunzip "$1" ;;
        *.xz)      unxz "$1" ;;
        *.zst)     zstd -d "$1" ;;
        *) echo "extract: unknown format: $1" ;;
    esac
}

zrc() {
    add-zsh-hook -d precmd _assemble_prompt
    add-zsh-hook -d preexec _timer_preexec
    add-zsh-hook -d preexec _lichtar_freq_log
    "$EDITOR" ~/.zshrc && source ~/.zshrc
}

md() {
    local file="${1:-README.md}"
    if command -v glow &>/dev/null; then
        glow -p "$file"
    else
        ${PAGER:-less} "$file"
    fi
}


# ── CLI wrapper ────────────────────────────────────────────────────────────────
# Keep interactive `lichtar update` in the current shell so a successful
# self-update can replace this shell with the new lichtar version.
lichtar() {
    if [[ "${1:-}" == "update" ]]; then
        shift
        LICHTAR_UPDATE_IN_SHELL=1
        source "$LICHTAR_HOME/bin/lichtar_update.zsh"
        _lichtar_update "$@"
    else
        "$LICHTAR_HOME/bin/lichtar" "$@"
    fi
}
