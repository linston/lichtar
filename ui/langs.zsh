# --- 2.1 Language Registry (ID: Icon ; Color ; Markers ; Extensions) ---
typeset -gA L_DEFS
typeset -ga L_ORDER
L_ORDER=(py node rust go php rb java lua cpp zig deno bun)

L_DEFS=(
    py    ";${CL_PYT};requirements.txt|pyproject.toml|.python-version|manage.py;*.py"
    node  ";${CL_NOD};package.json|node_modules;*.js|*.ts"
    rust  ";${CL_RST};Cargo.toml;*.rs"
    go    ";${CL_GOL};go.mod;*.go"
    php   ";${CL_PHP};composer.json;*.php"
    rb    ";${CL_RBL};Gemfile;*.rb"
    java  ";${CL_JAV};pom.xml|build.gradle;*.java"
    lua   ";${CL_LUA};init.lua|stylua.toml|.lua-version;*.lua"
    cpp   ";${CL_CPP};CMakeLists.txt|Makefile;*.cpp|*.c|*.h"
    zig   ";${CL_ZIG};build.zig;*.zig"
    deno  "󰲋;${CL_DEN};deno.json;*.ts|*.js"
    bun   ";${CL_BUN};bun.lockb;*.ts|*.js"
)

typeset -gA L_CACHE_VER
typeset -g _cmd_duration="" _rendered_path="" _l_cache_val="" _git_ahead_behind=""
_l_cache_pwd="" _l_path_pwd="" _last_venv="" _last_nvm=""
_g_cache_pwd="" _g_cache_ab=""
typeset -gi _g_cache_time=0

# --- 2.2 Version Engine (Lazy Init) ---
_get_ver_fast() {
    local id=$1 v=""
    case $id in
        py)   v=$(python3 -V 2>/dev/null || python -V 2>/dev/null); v=${v#* } ;;
        node) v=$(node -v 2>/dev/null); v=${v#v} ;;
        rust) command -v rustc >/dev/null && v=$(rustc --version 2>/dev/null | awk '{print $2}') ;;
        go)   command -v go >/dev/null && { v=$(go version 2>/dev/null | awk '{print $3}'); v=${v#go}; } ;;
        php)  command -v php >/dev/null && v=$(php -v 2>/dev/null | head -n1 | awk '{print $2}') ;;
        rb)   command -v ruby >/dev/null && { v=$(ruby -v 2>/dev/null | awk '{print $2}' | cut -dp -f1); } ;;
        java) command -v java >/dev/null && v=$(java -version 2>&1 | head -n1 | awk -F '"' '{print $2}') ;;
        lua)  command -v lua >/dev/null && v=$(lua -v 2>&1 | awk '{print $2}') ;;
        cpp)  command -v g++ >/dev/null && v=$(g++ --version 2>/dev/null | head -n1 | awk '{print $NF}') ;;
        zig)  command -v zig >/dev/null && v=$(zig version 2>/dev/null) ;;
        deno) command -v deno >/dev/null && v=$(deno --version 2>/dev/null | head -n1 | awk '{print $2}') ;;
        bun)  command -v bun >/dev/null && v=$(bun --version 2>/dev/null) ;;
    esac
    L_CACHE_VER[$id]=$v
}

# Surgical cache sync
_sync_env() {
    if [[ "$VIRTUAL_ENV" != "$_last_venv" ]]; then
        L_CACHE_VER[py]=""; _last_venv="$VIRTUAL_ENV"; _l_cache_pwd=""
    fi
    if [[ "$NVM_BIN" != "$_last_nvm" ]]; then
        L_CACHE_VER[node]=""; _last_nvm="$NVM_BIN"; _l_cache_pwd=""
    fi
}

# --- 2.3 Optimized Project Detection ---
_check_path_fast() {
    local -a marks exts
    marks=(${(s:|:)1})
    exts=(${(s:|:)2})
    local m e
    for m in $marks; do [[ -e "$m" ]] && return 0; done
    
    # POINT-fix Explicitly use noise ($3) and is_home ($4) to skip globs
    (( ${3:-0} || ${4:-0} )) && return 1
    
    for e in $exts; do 
        local -a f
        f=( ${~e}(N[1]) )
        (( $#f )) && return 0
    done
    return 1
}

# --- 2.4 Language Rendering (Perfect Caching) ---
function _build_langs_optimized() {
    if (( ! LICHTAR_LANG_DETECT )); then
        _l_cache_val=""
        return
    fi
    _sync_env
    [[ "$PWD" == "$_l_cache_pwd" && -n "$_l_cache_val" ]] && return
    
    local found=() is_noise=0 id conf_str icon col marks exts
    
    case "$PWD" in
      "$HOME"/.cache*|"$HOME"/.cargo*|"$HOME"/.rustup*|"$HOME"/.git*|"$HOME"/.local/share*|\
      "$HOME"/storage/shared*|"$HOME"/storage/downloads*|"$HOME"/storage/dcim*|\
      "$HOME"/Downloads*|"$HOME"/DCIM*|"$HOME"/Android/data*)
        is_noise=1 ;;
    esac
    
    if (( is_noise )); then
      _l_cache_val=""
      _l_cache_pwd="$PWD"
      return
    fi

    local is_home=0; [[ "${(%):-%~}" == "~" ]] && is_home=1

    for id in "${L_ORDER[@]}"; do
        conf_str="${L_DEFS[$id]}"
        local -a conf; conf=(${(s:;:)conf_str})
        icon=$conf[1] col=$conf[2] marks=$conf[3] exts=$conf[4]
        
        local trigger=0
        if [[ $id == "py" && -n "$VIRTUAL_ENV" ]]; then trigger=1
        elif [[ $id == "node" && -n "$NVM_BIN" ]]; then trigger=1
        else
            _check_path_fast "$marks" "$exts" "$is_noise" "$is_home" && trigger=1
        fi

        if (( trigger )); then
            local cv="${L_CACHE_VER[$id]}"
            [[ -z "$cv" ]] && { _get_ver_fast $id; cv="${L_CACHE_VER[$id]}"; }
            if [[ -n "$cv" ]]; then
                local lbl=""; [[ $id == "py" && -n "$VIRTUAL_ENV" ]] && lbl="(${VIRTUAL_ENV:t}) "
                found+=("%F{$col}${icon} ${lbl}${cv}%f")
            fi
        fi
    done

    _l_cache_val=""
    if (( $#found )); then
        local result="" sep=""
        for f in $found; do
            result+="${sep}${f}"
            sep="%F{$CL_DVD} · %f"
        done
        _l_cache_val=" %F{$CL_DVD}· %f${result}"
    fi
    _l_cache_pwd="$PWD"
}
