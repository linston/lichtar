# --- Path Rendering (Robust Cached Expansion) ---
function _build_path() {
    # Ensure path is never empty due to race conditions
    [[ "$PWD" == "$_l_path_pwd" && -n "$_rendered_path" ]] && return 

    local p_raw="${(%):-%~}"
    local -a parts
    parts=(${(s:/:)p_raw})
    parts=(${parts:#}) 
    
    local len=${#parts} res="" lock="" start=1
    [[ ! -w "$PWD" ]] && lock="%F{$CL_LOK}🔒 %f"
    
    if [[ "$p_raw" == "/" || "$p_raw" == "~" ]]; then
        _rendered_path="${lock}%B%F{$CL_CDR}${p_raw}%f%b"
        _l_path_pwd="$PWD"; return
    fi

    if (( len > 3 )); then
        res="%F{$CL_DVD}…%f%F{$CL_DVD}/%f" 
        start=$(( len - 2 ))
    fi
    
    for (( i=start; i<=len; i++ )); do
        if [[ $i -eq $len ]]; then
            res+="%B%F{$CL_CDR}${parts[$i]}%f%b"
        else
            local c_val=$CL_GDR
            (( i == len - 1 )) && c_val=$CL_PDR
            (( i == len - 2 && len > 3 )) && c_val=$CL_GDR
            res+="%F{$c_val}${parts[$i]}%f%F{$CL_DVD}/%f"
        fi
    done
    
    _rendered_path="${lock}${res}"
    _l_path_pwd="$PWD"
}

# --- 2.7 Timer ---
typeset -gi _t_start=0 _t_active=0
function _timer_preexec() { 
    _t_start=$SECONDS; _t_active=1 
    [[ "$1" == git\ * || "$1" == "g "* || "$1" == lazygit* || "$1" == tig* ]] && _g_cache_pwd="" 
}
function _timer_display() {
    _cmd_duration=""
    if (( _t_active )); then
        local d=$(( SECONDS - _t_start ))
        if (( d >= 60 )); then
            _cmd_duration="%F{$CL_DUR}$((d/60))m$((d%60))s %f"
        elif (( d >= 2 )); then
            _cmd_duration="%F{$CL_DUR}${d}s %f"
        fi
    fi
    _t_active=0
}

# --- 2.8 UI Assembler ---
function _assemble_prompt() {
    vcs_info
    _git_status_optimized
    _build_path
    _build_langs_optimized
    _timer_display
    
    local _badge_color_var="CL_DISTRO_${LICHTAR_ICON_COLOR:-DEFAULT}"
    local badge="%B%F{${(P)_badge_color_var}}${LICHTAR_ICON} %b%f"
    [[ -n "$SSH_CONNECTION" ]] && badge="%B%F{$CL_SSH}󰣀 %b%f"
    [[ $EUID -eq 0 ]] && badge="%B%F{$CL_LOK}🔒 %b%f"

    local err="%(?..%F{$CL_ERR}✘ %?%f )"
    local jobs="%(1j.%F{$CL_BJB} .)"
    local arrow=" %(?.%B%F{$CL_SCS}.%B%F{$CL_FLR})❯%b%f"

    PROMPT=$'\n'"${badge}${_rendered_path}${vcs_info_msg_0_}${_git_ahead_behind}${_l_cache_val}"$'\n'"%F{$CL_LNL}└─%f${err}${jobs}${arrow} "
}

# ==========================================
# 3. INTERFACE AND HOOKS
# ==========================================
setopt PROMPT_SUBST

RPROMPT='${_cmd_duration}%F{$CL_TIM} %D{%H:%M}%f'

