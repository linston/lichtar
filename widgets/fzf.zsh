# =============================================================================
# lichtar — widgets/fzf.zsh
# fzf-powered widgets: directory jump, history, file picker, clear screen
# =============================================================================


# ==========================================
# CTRL+F: SAFE FZF directory jump (ZLE widget)
# ==========================================
__fzf_cd_widget() {
    local dir

    if command -v fd &>/dev/null; then
    	dir="$(fd --type d --hidden --exclude .git --exclude node_modules \
			--max-depth 4 . 2>/dev/null | fzf \
            --height 40% --reverse --border --prompt='CD > ')" || {
            zle reset-prompt; return 0
        }
    else
		dir="$(find . -maxdepth 4 -type d \
			\( -name .git -o -name node_modules \) -prune -o \
            -type d -print 2>/dev/null | sed 's|^\./||' | fzf \
            --height 40% --reverse --border --prompt='CD > ')" || {
            zle reset-prompt; return 0
        }
    fi

    [[ -z "$dir" ]] && return 0

    builtin cd -- "$dir" || return 0
    BUFFER=""
    zle reset-prompt
}

zle -N __fzf_cd_widget
bindkey '^F' __fzf_cd_widget

# zoxide widget lives in widgets/zoxide.zsh

# ==========================================
# History frequency log — feeds CTRL+R ranking
# Registered as a preexec hook in init.zsh (after autoload -Uz add-zsh-hook)
# ==========================================
_lichtar_freq_log() {
    local cmd="$1"
    [[ -z "${cmd//[[:space:]]/}" ]] && return   # skip blank lines
    [[ "$cmd" == ' '* ]] && return              # respect HIST_IGNORE_SPACE
    local first="${cmd%% *}"
    # respect the same non-ASCII / wrong-layout guard as zshaddhistory()
    [[ "$(LC_ALL=C printf '%s' "$first" | tr -d '[ -~]')" != "" ]] && return
    # collapse embedded newlines (heredocs, multi-line commands) into one line
    print -r -- "${cmd//$'\n'/ ; }" >> "$LICHTAR_FREQ_FILE"
    # cap growth so the log doesn't grow forever
    local lines
    lines=$(wc -l < "$LICHTAR_FREQ_FILE" 2>/dev/null)
    if (( lines > 40000 )); then
        tail -n 20000 "$LICHTAR_FREQ_FILE" > "$LICHTAR_FREQ_FILE.tmp" && \
            mv "$LICHTAR_FREQ_FILE.tmp" "$LICHTAR_FREQ_FILE"
    fi
}

# ==========================================
# CTRL+R: history search ranked by usage frequency
# (ties broken by recency — the more recently used command wins)
# ==========================================
__fzf_history_widget() {
    local selected
    selected=$(awk '
            { count[$0]++; last[$0]=NR }
            END { for (c in count) printf "%08d\t%010d\t%s\n", count[c], last[c], c }
        ' "$LICHTAR_FREQ_FILE" 2>/dev/null | \
        sort -t $'\t' -k1,1nr -k2,2nr | cut -f3- | \
        fzf --height 45% --reverse --border --prompt='History: ' \
            --no-sort --query="$BUFFER")
    if [[ -n "$selected" ]]; then
        BUFFER="$selected"
        CURSOR=${#BUFFER}
    fi
    _force_refresh_ui
}
zle -N __fzf_history_widget
bindkey '^R' __fzf_history_widget

# ==========================================
# CTRL+T: file picker (custom, consistent border)
# ==========================================
__fzf_file_widget() {
    local selected
    if command -v fd &>/dev/null; then
        selected=$(fd --type f --hidden --exclude .git --max-depth 6 2>/dev/null | \
            fzf --height 45% --reverse --border --prompt='Files: ' --multi)
    else
        selected=$(find . -maxdepth 6 -type f 2>/dev/null | sed 's|^\./||' | \
            fzf --height 45% --reverse --border --prompt='Files: ' --multi)
    fi
    if [[ -n "$selected" ]]; then
        BUFFER="$BUFFER$selected"
        CURSOR=${#BUFFER}
    fi
    _force_refresh_ui
}
zle -N __fzf_file_widget
bindkey '^T' __fzf_file_widget
