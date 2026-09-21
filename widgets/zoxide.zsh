# =============================================================================
# lichtar — widgets/zoxide.zsh
# zoxide smart directory jump — Ctrl+G
# =============================================================================

if command -v zoxide &>/dev/null; then
    local _zoxide_bin="${commands[zoxide]}"
    local _zoxide_cache="$LICHTAR_HOME/cache/zoxide_init.zsh"

    if [[ -f "$_zoxide_cache" && ! "$_zoxide_bin" -nt "$_zoxide_cache" ]]; then
        source "$_zoxide_cache"
    else
        "$_zoxide_bin" init zsh >| "$_zoxide_cache"
        source "$_zoxide_cache"
    fi

    unset _zoxide_bin _zoxide_cache

    __zoxide_zi_cd() {
        local dir=$(zoxide query -l | fzf --height 45% --reverse --border --prompt='Jump to: ')
        if [[ -n "$dir" ]] && builtin cd -- "$dir"; then
            BUFFER=""
        fi
        _force_refresh_ui
    }
    zle -N __zoxide_zi_cd
    bindkey '^G' __zoxide_zi_cd
fi
