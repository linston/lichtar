# =============================================================================
# lichtar — widgets/guard.zsh
# Non-ASCII keyboard layout protection
# Must be sourced BEFORE plugins to register accept-line first
# =============================================================================

typeset -g _non_ascii_warned=0

_check_non_ascii_cmd() {
    local first="${BUFFER%% *}"
    if [[ "$(LC_ALL=C printf '%s' "$first" | tr -d '[ -~]')" != "" ]]; then
        if (( _non_ascii_warned == 0 )); then
            _non_ascii_warned=1
            zle -M "⚠ Wrong layout? Non-ASCII detected. Enter again to force."
            return 0
        fi
    fi
    _non_ascii_warned=0
    zle -M ""
    zle .accept-line
}
zle -N accept-line _check_non_ascii_cmd

# Runs before every line redraw, no matter which widget touched the buffer
# (backspace, backward-kill-word, kill-whole-line, undo, paste, ...). Clears
# the warning only once the first word is FULLY clean of non-ASCII bytes —
# a partial edit that still leaves bad characters keeps the warning showing.
# Uses zle -M (not POSTDISPLAY/region_highlight) specifically because both
# of those are actively managed by zsh-autosuggestions / fast-syntax-
# highlighting and get silently overwritten by them; zle -M is a separate
# channel neither plugin touches.
_guard_check_buffer() {
    (( _non_ascii_warned )) || return 0
    local first="${BUFFER%% *}"
    if [[ "$(LC_ALL=C printf '%s' "$first" | tr -d '[ -~]')" == "" ]]; then
        _non_ascii_warned=0
        zle -M ""
    fi
}
autoload -Uz add-zle-hook-widget
add-zle-hook-widget zle-line-pre-redraw _guard_check_buffer
