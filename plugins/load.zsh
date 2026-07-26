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
_load_plugin zsh-autosuggestions              zsh-autosuggestions.zsh
_load_plugin zsh-history-substring-search     zsh-history-substring-search.zsh
_load_plugin fzf-tab                          fzf-tab.plugin.zsh
_load_plugin fast-syntax-highlighting         fast-syntax-highlighting.plugin.zsh
_load_plugin zsh-autopair                     autopair.zsh
(( $+functions[autopair-init] )) && autopair-init

# ── Apply fsh theme (must run AFTER the plugin above is loaded) ──────────────
if [[ -n "$CL_FSH_THEME_INI" && -f "$CL_FSH_THEME_INI" ]]; then
    local _fsh_hash_file="$LICHTAR_HOME/cache/fsh_theme.md5"
    local _fsh_plugin_dir="$LICHTAR_HOME/plugins/fast-syntax-highlighting"
    local _fsh_plugin_mtime
    _fsh_plugin_mtime=$(stat -c %Y "$_fsh_plugin_dir" 2>/dev/null || stat -f %m "$_fsh_plugin_dir" 2>/dev/null)
    # Fingerprint = ini file hash + plugin dir mtime, so a fresh git clone
    # (new device, reinstall) forces a re-apply even if the .ini is unchanged
    local _fsh_hash_now="$(md5sum "$CL_FSH_THEME_INI" 2>/dev/null | cut -d' ' -f1)-${_fsh_plugin_mtime}"
    local _fsh_hash_old=""
    [[ -f "$_fsh_hash_file" ]] && _fsh_hash_old=$(<"$_fsh_hash_file")
    if [[ "$_fsh_hash_now" != "$_fsh_hash_old" ]]; then
        fast-theme "$CL_FSH_THEME_INI" &>/dev/null
        echo "$_fsh_hash_now" >| "$_fsh_hash_file"
    fi
    unset _fsh_hash_file _fsh_plugin_dir _fsh_plugin_mtime _fsh_hash_now _fsh_hash_old
fi
