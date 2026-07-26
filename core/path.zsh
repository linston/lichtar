# =============================================================================
# lichtar — core/path.zsh
# PATH, environment, system modules
# =============================================================================

# ── PATH ─────────────────────────────────────────────────────────────────────
typeset -gaU path

path=(
    "$LICHTAR_HOME/bin"
    "$HOME/.zsh/scripts"
    "$HOME/bin"
    "$HOME/.local/bin"
    "$PREFIX/bin"
    $path
)
export PATH

# ── Security ─────────────────────────────────────────────────────────────────
umask 027

# ── Zsh modules ──────────────────────────────────────────────────────────────
zmodload zsh/datetime    # EPOCHSECONDS for TTL cache
zmodload zsh/zutil       # zparseopts support
zmodload zsh/complist    # colored menu select

