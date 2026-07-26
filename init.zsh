# =============================================================================
# lichtar — init.zsh
# Main entry point — loads all modules in correct order
# =============================================================================

export LICHTAR_HOME="${LICHTAR_HOME:-$HOME/.lichtar}"

# ── Create required directories ───────────────────────────────────────────────
mkdir -p "$LICHTAR_HOME/cache"

# ── Load user configuration (.env) — must be first ───────────────────────────
[[ -f "$LICHTAR_HOME/.env" ]] && source "$LICHTAR_HOME/.env"

# ── System detection (platform, distro, icon, package manager) ───────────────
# Detected once and cached; regenerated only if the cache file is missing.
# Run `lichtar system --force` to refresh manually.
if [[ ! -f "$LICHTAR_HOME/cache/system.env" ]]; then
    source "$LICHTAR_HOME/bin/system_detect.zsh"
    detect_system
fi
source "$LICHTAR_HOME/cache/system.env"

# ── Apply .env settings ───────────────────────────────────────────────────────
LICHTAR_THEME="${LICHTAR_THEME:-catppuccin-mocha}"
LICHTAR_EDITOR="${LICHTAR_EDITOR:-micro}"
export EDITOR="${EDITOR:-$LICHTAR_EDITOR}"
export MICRO_CONFIG_HOME="$LICHTAR_HOME/micro"
LICHTAR_YAZI="${LICHTAR_YAZI:-1}"
LICHTAR_GIT_AHEAD="${LICHTAR_GIT_AHEAD:-1}"
LICHTAR_LANG_DETECT="${LICHTAR_LANG_DETECT:-1}"
LICHTAR_DEBUG="${LICHTAR_DEBUG:-0}"
LICHTAR_PROFILE="${LICHTAR_PROFILE:-0}"

# ── Profile helper ────────────────────────────────────────────────────────────
zmodload zsh/datetime 2>/dev/null
typeset -gF _lichtar_t0
_lichtar_load() {
    local file="$1"
    if (( LICHTAR_PROFILE )); then
        local t0=$EPOCHREALTIME
        source "$file"
        local ms=$(( (EPOCHREALTIME - t0) * 1000 ))
        printf "  [lichtar] %-45s %5.1fms\n" "${file#$LICHTAR_HOME/}" $ms
    else
        source "$file"
    fi
    (( LICHTAR_DEBUG )) && echo "[lichtar] loaded: ${file#$LICHTAR_HOME/}"
}

# ── Theme (must be first — defines color variables) ───────────────────────────
theme_file="$LICHTAR_HOME/themes/${LICHTAR_THEME}.zsh"
if [[ -f "$theme_file" ]]; then
    _lichtar_load "$theme_file"
else
    echo "[lichtar] theme not found: $LICHTAR_THEME"
fi

# ── Core ──────────────────────────────────────────────────────────────────────
_lichtar_load "$LICHTAR_HOME/core/path.zsh"
_lichtar_load "$LICHTAR_HOME/core/options.zsh"

# ── Non-ASCII guard (must be before plugins) ──────────────────────────────────
_lichtar_load "$LICHTAR_HOME/widgets/guard.zsh"

# ── Plugins ───────────────────────────────────────────────────────────────────
_lichtar_load "$LICHTAR_HOME/plugins/load.zsh"

# ── Completion (after plugins) ────────────────────────────────────────────────
_lichtar_load "$LICHTAR_HOME/core/completion.zsh"

# ── UI ────────────────────────────────────────────────────────────────────────
_lichtar_load "$LICHTAR_HOME/ui/langs.zsh"
_lichtar_load "$LICHTAR_HOME/ui/git.zsh"
_lichtar_load "$LICHTAR_HOME/ui/prompt.zsh"

# ── Misc (fzf bindings, refresh helper, man colors, SSH) ─────────────────────
_lichtar_load "$LICHTAR_HOME/core/misc.zsh"

# ── Widgets — guard first, rest auto-loaded ───────────────────────────────────
for _lf in "$LICHTAR_HOME"/widgets/^guard.zsh(N); do
    _lichtar_load "$_lf"
done
unset _lf

# ── Aliases and functions ─────────────────────────────────────────────────────
_lichtar_load "$LICHTAR_HOME/aliases.zsh"
_lichtar_load "$LICHTAR_HOME/core/functions.zsh"

# ── Help system ───────────────────────────────────────────────────────────────
_lichtar_load "$LICHTAR_HOME/help/lichtar_help.zsh"

# ── Hooks ─────────────────────────────────────────────────────────────────────
autoload -Uz add-zsh-hook
add-zsh-hook preexec _timer_preexec
add-zsh-hook preexec _lichtar_freq_log
add-zsh-hook precmd _assemble_prompt
