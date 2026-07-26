# =============================================================================
# lichtar — widgets/zoxide.zsh
# zoxide smart directory jump — Ctrl+G
# =============================================================================

if command -v zoxide &>/dev/null; then
    eval "$(zoxide init zsh)"
    __zoxide_zi_cd() {
        local dir=$(zoxide query -l | fzf --height 45% --reverse --border --prompt='Jump to: ')
        if [[ -n "$dir" ]]; then cd "$dir"; BUFFER=""; fi
        _force_refresh_ui
    }
    zle -N __zoxide_zi_cd
    bindkey '^G' __zoxide_zi_cd
fi
