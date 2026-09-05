# =============================================================================
# lichtar — misc.zsh
# Miscellaneous: fzf key-bindings, UI refresh helper, colored man pages, SSH
# =============================================================================

# Alt+C is bound directly to __fzf_cd_widget in widgets/fzf.zsh (same widget
# as Ctrl+F) — no dependency on fzf's own key-bindings.zsh, so it's themed
# and filtered the same way on every platform, not just Termux.

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
    local _ssh_agent_lock="$LICHTAR_HOME/cache/ssh-agent.lock"

    # Whole check-spawn-write section runs in a subshell locked via
    # zsystem flock — closes the race where two terminals starting at
    # the same instant would both see no valid agent and both spawn one.
    # The lock is released automatically when the subshell exits (this
    # is zsh's own documented pattern for zsystem flock), so there is
    # no manual unlock to forget.
    (
        zmodload zsh/system 2>/dev/null
        : >> "$_ssh_agent_lock"
        # Best-effort: if the lock can't be acquired within 5s (contention,
        # or zsh/system unavailable), fall through unprotected rather than
        # blocking ssh entirely. LICHTAR_DEBUG surfaces this rare case.
        if ! zsystem flock -t 5 "$_ssh_agent_lock" 2>/dev/null; then
            (( LICHTAR_DEBUG )) && echo "[lichtar] ssh-agent lock not acquired — proceeding unprotected"
        fi

        if [[ -f "$_ssh_agent_env" ]]; then
            source "$_ssh_agent_env"
            # Stale check needs BOTH: a live PID (kill -0) and an actual
            # socket file — a killed agent can briefly linger as a zombie
            # PID that still answers kill -0 while its socket is gone.
            if [[ -n "$SSH_AGENT_PID" ]] && { ! kill -0 "$SSH_AGENT_PID" 2>/dev/null || [[ ! -S "$SSH_AUTH_SOCK" ]]; }; then
                unset SSH_AUTH_SOCK SSH_AGENT_PID
            fi
        fi
        if [[ -z "$SSH_AUTH_SOCK" ]]; then
            eval "$(ssh-agent -s)" > /dev/null
            { echo "export SSH_AUTH_SOCK=$SSH_AUTH_SOCK"; echo "export SSH_AGENT_PID=$SSH_AGENT_PID"; } > "$_ssh_agent_env"
        fi
    )
    source "$_ssh_agent_env"
    unset _ssh_agent_env _ssh_agent_lock
fi
