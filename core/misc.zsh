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

# ── SSH agent (reused via pidfile — spawning one per terminal leaks agents) ──
if [[ -z "$SSH_AUTH_SOCK" ]] && command -v ssh-agent &>/dev/null; then
    local _ssh_agent_env="$LICHTAR_HOME/cache/ssh-agent.env"
    if [[ -f "$_ssh_agent_env" ]]; then
        source "$_ssh_agent_env"
        # Stale check needs BOTH: a live PID (kill -0) and an actual socket
        # file — a killed agent can briefly linger as a zombie PID that
        # still answers kill -0 while its socket is already gone.
        if [[ -n "$SSH_AGENT_PID" ]] && { ! kill -0 "$SSH_AGENT_PID" 2>/dev/null || [[ ! -S "$SSH_AUTH_SOCK" ]]; }; then
            unset SSH_AUTH_SOCK SSH_AGENT_PID
        fi
    fi
    if [[ -z "$SSH_AUTH_SOCK" ]]; then
        eval "$(ssh-agent -s)" > /dev/null
        { echo "export SSH_AUTH_SOCK=$SSH_AUTH_SOCK"; echo "export SSH_AGENT_PID=$SSH_AGENT_PID"; } > "$_ssh_agent_env"
    fi
    unset _ssh_agent_env
fi
