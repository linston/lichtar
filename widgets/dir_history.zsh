# =============================================================================
# lichtar — widgets/dir_history.zsh
# Alt+Left / Alt+Right — browser-style back/forward directory navigation
# =============================================================================

# ── Interactive-only widget ───────────────────────────────────────────────────
[[ -o interactive ]] || return 0

autoload -Uz add-zsh-hook

typeset -ga _dir_hist=("$PWD")
typeset -gi _dir_hist_pos=1
typeset -gi _dir_nav_flag=0

# Fires on every directory change, however it happened — plain `cd`, zoxide's
# `z`, Ctrl+F/Alt+C's __fzf_cd_widget, AUTO_CD — so back/forward navigation
# transparently covers all of them, not just a hand-picked subset.
_dir_hist_track() {
    if (( _dir_nav_flag )); then
        _dir_nav_flag=0
        return
    fi
    # New navigation from somewhere other than back/forward itself discards
    # whatever "forward" history existed past the current position — same
    # rule a browser tab follows.
    _dir_hist=("${_dir_hist[@]:0:$_dir_hist_pos}")
    _dir_hist+=("$PWD")
    local _max=${LICHTAR_DIR_HISTORY_SIZE:-200}
    (( ${#_dir_hist} > _max )) && _dir_hist=("${_dir_hist[@]: -$_max}")
    _dir_hist_pos=${#_dir_hist}
}
add-zsh-hook chpwd _dir_hist_track

_dir_hist_back_widget() {
    (( _dir_hist_pos > 1 )) || return 0
    _dir_nav_flag=1
    if builtin cd -- "${_dir_hist[_dir_hist_pos-1]}" 2>/dev/null; then
        (( _dir_hist_pos-- ))
        _force_refresh_ui
    else
        _dir_nav_flag=0
    fi
}
zle -N _dir_hist_back_widget

_dir_hist_forward_widget() {
    (( _dir_hist_pos < ${#_dir_hist} )) || return 0
    _dir_nav_flag=1
    if builtin cd -- "${_dir_hist[_dir_hist_pos+1]}" 2>/dev/null; then
        (( _dir_hist_pos++ ))
        _force_refresh_ui
    else
        _dir_nav_flag=0
    fi
}
zle -N _dir_hist_forward_widget

# Same xterm modifier-code convention already used for Ctrl+Left/Right in
# widgets/keys.zsh (^[[1;5D/^[[1;5C) — 3 is Alt instead of Ctrl's 5.
bindkey '^[[1;3D' _dir_hist_back_widget     # Alt+Left
bindkey '^[[1;3C' _dir_hist_forward_widget  # Alt+Right
