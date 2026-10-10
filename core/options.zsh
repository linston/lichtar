# =============================================================================
# lichtar — core/options.zsh
# Shell options, history, word characters
# =============================================================================

# ── Shell options ─────────────────────────────────────────────────────────────
setopt extendedglob
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
# Prompt strings contain user-controlled data (paths, git branch names).
# Keep prompt substitution disabled so shell syntax in those values is
# displayed literally rather than executed.
unsetopt PROMPT_SUBST
setopt INTERACTIVE_COMMENTS

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
    # Decode Zsh's metafied history through Zsh itself; copying bytes with
    # sed can corrupt non-ASCII commands in the frequency log.
    _lichtar_freq_seed_tmp="${LICHTAR_FREQ_FILE}.tmp.$$"
    if zsh -f -s -- "$HISTFILE" > "$_lichtar_freq_seed_tmp" 2>/dev/null <<'LICHTAR_HISTORY_SEED'
HISTFILE=$1
HISTSIZE=50000
SAVEHIST=50000
fc -p "$HISTFILE" "$HISTSIZE" "$SAVEHIST" || exit 1
for event in ${(onk)history}; do
    cmd="${history[$event]}"
    cmd="${cmd//$'\n'/ ; }"
    print -r -- "$cmd"
done
LICHTAR_HISTORY_SEED
    then
        if [[ -s "$_lichtar_freq_seed_tmp" ]] && mv -- "$_lichtar_freq_seed_tmp" "$LICHTAR_FREQ_FILE"; then
            :
        else
            rm -f -- "$_lichtar_freq_seed_tmp"
        fi
    else
        rm -f -- "$_lichtar_freq_seed_tmp"
    fi
    unset _lichtar_freq_seed_tmp
fi

# ── Word characters (physical keyboard) ───────────────────────────────────────
WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'
