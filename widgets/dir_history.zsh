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

# zle -M message that clears itself after ~1.5s with no extra keypress
# needed: zle -F wakes zsh's event loop on its own once the background
# `sleep` exits. Any key pressed before then also clears it immediately,
# same as any other zle -M message (e.g. the non-ASCII guard's warning).
#
# NOTE: zle -M does not render raw ANSI/SGR escapes -- testing confirmed
# it displays them as literal caret-notation (e.g. "^[[38;2;...m") rather
# than applying color, so this stays plain text rather than themed.
_dir_hist_flash_clear() {
    local fd="$1"
    zle -F "$fd"
    exec {fd}<&-
    zle -M ""
}

_dir_hist_flash() {
    zle -M "$1"
    local fd
    exec {fd}< <(sleep 1)
    zle -F "$fd" _dir_hist_flash_clear
}

_dir_hist_back_widget() {
    local target
    while (( _dir_hist_pos > 1 )); do
        target="${_dir_hist[_dir_hist_pos-1]}"
        _dir_nav_flag=1
        if builtin cd -- "$target" 2>/dev/null; then
            (( _dir_hist_pos-- ))
            _force_refresh_ui
            return
        fi
        _dir_nav_flag=0
        # That directory no longer exists (deleted, unmounted, ...) — drop
        # it from history and try the next one back, instead of getting
        # stuck silently retrying the same dead path forever.
        _dir_hist[_dir_hist_pos-1]=()
        (( _dir_hist_pos-- ))
    done
    _dir_hist_flash "No earlier directory in history still exists"
}
zle -N _dir_hist_back_widget

_dir_hist_forward_widget() {
    local target
    while (( _dir_hist_pos < ${#_dir_hist} )); do
        target="${_dir_hist[_dir_hist_pos+1]}"
        _dir_nav_flag=1
        if builtin cd -- "$target" 2>/dev/null; then
            (( _dir_hist_pos++ ))
            _force_refresh_ui
            return
        fi
        _dir_nav_flag=0
        # Same as above, but for a dead entry ahead of us.
        _dir_hist[_dir_hist_pos+1]=()
    done
    _dir_hist_flash "No later directory in history still exists"
}
zle -N _dir_hist_forward_widget

# Same xterm modifier-code convention already used for Ctrl+Left/Right in
# widgets/keys.zsh (^[[1;5D/^[[1;5C) — 3 is Alt instead of Ctrl's 5.
bindkey '^[[1;3D' _dir_hist_back_widget     # Alt+Left
bindkey '^[[1;3C' _dir_hist_forward_widget  # Alt+Right
