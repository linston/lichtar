# =============================================================================
# lichtar — core/completion.zsh
# Completion system initialization and styling
# =============================================================================

# ── Completion path ───────────────────────────────────────────────────────────
fpath=(
    "$LICHTAR_HOME/plugins/zsh-completions/src"
    "$PREFIX/share/zsh/site-functions"
    "$PREFIX/share/zsh/vendor-completions"
    $fpath
)
autoload -Uz compinit

# ── compinit with daily cache ─────────────────────────────────────────────────
# Fast mode (-C) only when cache exists and is newer than 20 hours
local zcd="$LICHTAR_HOME/cache/zcompdump"
if [[ -f "$zcd" ]]; then
    zmodload zsh/stat 2>/dev/null
    local zcd_age=$(( EPOCHSECONDS - $(zstat +mtime "$zcd" 2>/dev/null || echo 0) ))
    if (( zcd_age < 72000 )); then   # 20h = 72000s
        compinit -C -d "$zcd"
    else
        compinit -d "$zcd"
    fi
else
    compinit -d "$zcd"
fi

# ── Completion styling ────────────────────────────────────────────────────────
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list \
    'm:{a-zA-Z}={A-Za-z}' \
    'r:|[._-]=* r:|=*' \
    'l:|=* r:|=*'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$LICHTAR_HOME/cache"

# ── fzf-tab ───────────────────────────────────────────────────────────────────
zstyle ':fzf-tab:*' fzf-flags \
    --height=50% \
    --layout=reverse \
    --border \
    --info=inline

if command -v eza &>/dev/null; then
    zstyle ':fzf-tab:complete:*' fzf-preview \
        '[[ -d $realpath ]] && eza --tree --icons --git-ignore --level=1 --color=always -- "$realpath" \
        || (file --mime "$realpath" 2>/dev/null | grep -q binary && file "$realpath") \
        || head -n 200 -- "$realpath" 2>/dev/null'
    zstyle ':fzf-tab:complete:cd:*' fzf-preview \
        'eza --tree --icons --git-ignore --level=2 --color=always -- "$realpath"'
else
    zstyle ':fzf-tab:complete:*' fzf-preview \
        '[[ -d $realpath ]] && ls -la -- "$realpath" \
        || head -n 200 -- "$realpath" 2>/dev/null'
    zstyle ':fzf-tab:complete:cd:*' fzf-preview \
        'ls -la -- "$realpath"'
fi
