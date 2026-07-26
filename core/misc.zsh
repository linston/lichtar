# =============================================================================
# lichtar — misc.zsh
# Miscellaneous: fzf key-bindings, UI refresh helper, colored man pages, SSH
# =============================================================================

# ── fzf key-bindings ──────────────────────────────────────────────────────────
[[ -f "$PREFIX/share/fzf/key-bindings.zsh" ]] && source "$PREFIX/share/fzf/key-bindings.zsh"

# ── UI refresh helper ─────────────────────────────────────────────────────────
_force_refresh_ui() {
    _assemble_prompt
    [[ -o zle ]] && { zle reset-prompt; zle redisplay 2>/dev/null; }
}

# ── Colored man pages ─────────────────────────────────────────────────────────
export LESS_TERMCAP_mb=$(printf '\e[%sm' "${CL_MAN_HDR:-1;32}")
export LESS_TERMCAP_md=$(printf '\e[%sm' "${CL_MAN_HDR:-1;32}")
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$(printf '\e[%sm' "${CL_MAN_SRC:-01;33}")
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$(printf '\e[%sm' "${CL_MAN_USR:-1;4;31}")

# ── SSH agent ─────────────────────────────────────────────────────────────────
if [[ -z "$SSH_AUTH_SOCK" ]] && command -v ssh-agent &>/dev/null; then
    eval "$(ssh-agent -s)" > /dev/null
fi
