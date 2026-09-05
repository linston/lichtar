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
    ${PREFIX:+"$PREFIX/bin"}
    $path
)
export PATH

# ── Security ─────────────────────────────────────────────────────────────────
umask 027

# ── Zsh modules ──────────────────────────────────────────────────────────────
# zsh/datetime is already loaded by init.zsh (needed there for EPOCHREALTIME
# before the first _lichtar_load call even runs) — no need to repeat it here.
zmodload zsh/zutil       # zparseopts support
zmodload zsh/complist    # colored menu select

