# =============================================================================
# lichtar — core/options.zsh
# Shell options, history, word characters
# =============================================================================

# ── Shell options ─────────────────────────────────────────────────────────────
setopt extendedglob
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PROMPT_SUBST

# ── History ───────────────────────────────────────────────────────────────────
HISTSIZE=50000
SAVEHIST=50000
HISTFILE="$LICHTAR_HOME/cache/history"
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt EXTENDED_HISTORY
setopt HIST_IGNORE_SPACE

# ── Frequency log (used by CTRL+R ranking, see widgets/fzf.zsh) ──────────────
# HIST_IGNORE_ALL_DUPS + HIST_SAVE_NO_DUPS mean HISTFILE only ever keeps one
# copy of each command, so frequency can't be derived from it. We keep a
# separate, append-only, non-deduplicated log just for ranking.
LICHTAR_FREQ_FILE="$LICHTAR_HOME/cache/history_freq"
if [[ ! -f "$LICHTAR_FREQ_FILE" && -f "$HISTFILE" ]]; then
    # One-time seed from the existing HISTFILE so CTRL+R isn't empty right
    # after the update. Every command starts at frequency 1.
    sed -E 's/^: [0-9]+:[0-9]+;//' "$HISTFILE" > "$LICHTAR_FREQ_FILE" 2>/dev/null
fi

# ── Word characters (physical keyboard) ───────────────────────────────────────
WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'
