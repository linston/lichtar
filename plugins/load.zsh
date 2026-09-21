# =============================================================================
# lichtar — plugins/load.zsh
# Plugin loader and configuration
# Must be sourced AFTER widgets/guard.zsh
# =============================================================================

# ── Plugin loader ─────────────────────────────────────────────────────────────
_load_plugin() {
    local f="$LICHTAR_HOME/plugins/$1/$2"
    [[ -f "$f" ]] && source "$f" || echo "[lichtar] plugin not found: $f"
}

# ── Autosuggestions config (must be before loading the plugin) ────────────────
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=${CL_SUG}"
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=60
ZSH_AUTOSUGGEST_USE_ASYNC=1

# ── Load plugins ──────────────────────────────────────────────────────────────
# fzf-tab first: its README requires loading before compinit-adjacent widget
# wrapping happens in zsh-autosuggestions below.
_load_plugin fzf-tab                          fzf-tab.plugin.zsh
_load_plugin zsh-autosuggestions              zsh-autosuggestions.zsh
_load_plugin zsh-history-substring-search     zsh-history-substring-search.zsh

# FSH is deferred until the first ZLE activation to keep startup fast.
_lichtar_load_fsh() {
    # Remove the hook first so the loader runs only once.
    add-zle-hook-widget -d zle-line-init _lichtar_load_fsh 2>/dev/null

    _load_plugin fast-syntax-highlighting fast-syntax-highlighting.plugin.zsh

    # ── Apply fsh theme ───────────────────────────────────────────────────────
    if [[ -n "$CL_FSH_THEME_INI" && -f "$CL_FSH_THEME_INI" ]]; then
        local _fsh_hash_file="$LICHTAR_HOME/cache/fsh_theme.md5"
        local _fsh_plugin_dir="$LICHTAR_HOME/plugins/fast-syntax-highlighting"
        zmodload zsh/stat 2>/dev/null
        local _fsh_theme_mtime _fsh_theme_size _fsh_plugin_mtime
        _fsh_theme_mtime=$(zstat +mtime "$CL_FSH_THEME_INI" 2>/dev/null)
        _fsh_theme_size=$(zstat +size "$CL_FSH_THEME_INI" 2>/dev/null)
        _fsh_plugin_mtime=$(zstat +mtime "$_fsh_plugin_dir" 2>/dev/null)

        local _fsh_hash_now="${_fsh_theme_mtime}-${_fsh_theme_size}-${_fsh_plugin_mtime}"
        local _fsh_hash_old=""
        [[ -f "$_fsh_hash_file" ]] && _fsh_hash_old=$(<"$_fsh_hash_file")

        if [[ "$_fsh_hash_now" != "$_fsh_hash_old" ]]; then
            fast-theme "$CL_FSH_THEME_INI" &>/dev/null
            print -r -- "$_fsh_hash_now" >| "$_fsh_hash_file"
        fi

        unset _fsh_hash_file _fsh_plugin_dir _fsh_theme_mtime _fsh_theme_size
        unset _fsh_plugin_mtime _fsh_hash_now _fsh_hash_old
    fi

    unset -f _lichtar_load_fsh
}

autoload -Uz add-zle-hook-widget
add-zle-hook-widget zle-line-init _lichtar_load_fsh

# zsh-autopair calls autopair-init itself at the end of the plugin file.
_load_plugin zsh-autopair                     autopair.zsh
