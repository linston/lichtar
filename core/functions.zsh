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
        *.tar.xz)  tar xJf "$1" ;;
        *.zip)     unzip "$1" ;;
        *.7z)      7z x "$1" ;;
        *.rar)     unrar x "$1" ;;
        *.tar.zst) tar --zstd -xf "$1" ;;
        *.gz)      gunzip "$1" ;;
        *.zst)     zstd -d "$1" ;;
        *) echo "extract: unknown format: $1" ;;
    esac
}

zrc() {
    add-zsh-hook -d precmd _assemble_prompt
    add-zsh-hook -d preexec _timer_preexec
    "$EDITOR" ~/.zshrc && source ~/.zshrc
}
