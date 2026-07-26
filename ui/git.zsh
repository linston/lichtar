
# --- 2.6 Advanced Git (Ahead/Behind) ---
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:git:*' formats " %F{$CL_GIF} %F{$CL_GBR}%b%u%c%f"
zstyle ':vcs_info:git:*' unstagedstr "%F{$CL_GUC}●%f"
zstyle ':vcs_info:git:*' stagedstr "%F{$CL_GSC}●%f"

function _git_status_optimized() {
    _git_ahead_behind=""
    (( LICHTAR_GIT_AHEAD )) || return
    [[ -z "$vcs_info_msg_0_" ]] && { _g_cache_pwd=""; return; }
    [[ "$PWD" == "$_g_cache_pwd" && $(( EPOCHSECONDS - _g_cache_time )) -lt 30 ]] && { _git_ahead_behind="$_g_cache_ab"; return; }
    local stash_f="$(git rev-parse --git-dir 2>/dev/null)/refs/stash"
    [[ -f "$stash_f" ]] && _git_ahead_behind="%F{$CL_GAB}⚑%f"
    if git rev-parse --abbrev-ref @{u} >/dev/null 2>&1; then
        local g_counts; g_counts=$(git rev-list --left-right --count HEAD...@{u} 2>/dev/null)
        if [[ -n "$g_counts" ]]; then
            local ahead=${g_counts%$'\t'*} behind=${g_counts#*$'\t'}
            (( ahead > 0 )) && _git_ahead_behind+="%F{$CL_GAH}⇡${ahead}%f"
            (( behind > 0 )) && _git_ahead_behind+="%F{$CL_GBH}⇣${behind}%f"
            [[ -n "$_git_ahead_behind" ]] && _git_ahead_behind=" ${_git_ahead_behind}"
        fi
    fi
    _g_cache_pwd="$PWD"
    _g_cache_ab="$_git_ahead_behind"
    _g_cache_time=$EPOCHSECONDS
}
