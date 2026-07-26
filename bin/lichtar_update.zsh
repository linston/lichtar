# =============================================================================
# ~/.lichtar/bin/lichtar_update.zsh
# lichtar update — updates lichtar-owned things only:
#   1. lichtar itself        (git pull --ff-only)
#   2. zsh plugins           (~/.lichtar/plugins/*)
#   3. yazi packages         (plugins + flavor, via ya pkg upgrade)
#
# System-wide packages (pkg/npm/pip/nvim) are NOT handled here — update
# those yourself with your system's package manager.
# =============================================================================

_lichtar_update() {
    : "${LICHTAR_HOME:=$HOME/.lichtar}"
    local SECONDS=0

    local VERBOSE=0
    local DRYRUN=0
    local NO_COLOR=0
    local NO_SPINNER=0
    local FORCE_LOG=0
    local MAX_LIST=15

    local LOG_DIR="$LICHTAR_HOME/cache"
    local LOG_FILE="$LOG_DIR/update.log"
    mkdir -p "$LOG_DIR" 2>/dev/null

    # ── Args ─────────────────────────────────────────────────────────────────
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -v|--verbose)   VERBOSE=1 ;;
            -n|--dry-run)   DRYRUN=1 ;;
            -l|--log)       FORCE_LOG=1 ;;
            --no-color)     NO_COLOR=1 ;;
            --no-spinner)   NO_SPINNER=1 ;;
            --max-list)     shift; MAX_LIST="${1:-15}" ;;
            -h|--help)
                cat <<EOF
Usage: lichtar update [options]

Updates lichtar-owned components: self, zsh plugins, yazi packages (plugins + flavor).
System packages (pkg/npm/pip/nvim) are not handled here — update those
yourself with your system's package manager.

Options:
  -v, --verbose       Show full command output
  -n, --dry-run       Simulate only
  -l, --log           Always write full output to log file
  --no-color          Disable ANSI colors
  --no-spinner        Disable spinner
  --max-list N        Max displayed items (default: 15)
  -h, --help          Show help

Log file:
  $LOG_FILE
EOF
                return 0
                ;;
            *)
                echo "Unknown option: $1"
                return 1
                ;;
        esac
        shift
    done

    # ── Theme colors (hex → ANSI truecolor) ─────────────────────────────────
    local B NC HDR ACC WRN KEY TXT TXM LHT ZSHC YZI
    if (( NO_COLOR == 0 )); then
        local _hex2a() {
            local hex="${1#\#}"
            local r=$((16#${hex:0:2})) g=$((16#${hex:2:2})) b=$((16#${hex:4:2}))
            printf "\e[38;2;%d;%d;%dm" $r $g $b
        }
        B=$'\e[1m'; NC=$'\e[0m'
        HDR="$(_hex2a "${CL_MTN_HDR}")"   # header
        ACC="$(_hex2a "${CL_MTN_ACC}")"   # accents
        WRN="$(_hex2a "${CL_MTN_WRN}")"   # warnings
        KEY="$(_hex2a "${CL_MTN_KEY}")"   # key / commands
        TXT="$(_hex2a "${CL_MTN_TXT}")"   # text
        TXM="$(_hex2a "${CL_MTN_TXM}")"   # text muted
        LHT="$(_hex2a "${CL_MTN_LHT}")"   # lichtar
        ZSHC="$(_hex2a "${CL_MTN_ZSH}")"  # zsh plugins
        YZI="$(_hex2a "${CL_MTN_YZI}")"   # yazi plugins
    else
        B="" NC="" HDR="" ACC="" WRN="" KEY="" TXT="" TXM="" LHT="" ZSHC="" YZI=""
    fi

    has()     { command -v "$1" >/dev/null 2>&1; }
    section() { printf "\n  ${B}${TXT}%s${NC}\n" "$1"; }
    ok()      { printf "  ${KEY}${B}✔${NC}  ${TXT}%s${NC}\n" "$1"; }
    skip()    { printf "  ${TXM}◦${NC}  ${TXM}%s${NC}\n" "$1"; }
    warn()    { printf "  ${WRN}✘${NC}  ${TXT}%s${NC}\n" "$1"; }
    detail()  { printf "     ${TXM}↳ %s${NC}\n" "$1"; }

    log_line() { printf "[%s] %s\n" "$(date '+%F %T')" "$1" >> "$LOG_FILE"; }

    print_limited_list() {
        local title="$1" list="$2"
        [[ -z "$list" ]] && return 0
        ok "$title"
        local count=0
        while read -r line; do
            [[ -z "$line" ]] && continue
            count=$((count + 1))
            (( count <= MAX_LIST )) && detail "$line"
        done <<< "$list"
        local total; total=$(echo "$list" | grep -c .)
        (( total > MAX_LIST )) && detail "...and $(( total - MAX_LIST )) more"
    }

    # ── Spinner ──────────────────────────────────────────────────────────────
    local _FRAMES=("⣷⣾" "⣯⣽" "⣟⣻" "⡿⢿" "⢿⡿" "⣻⣟" "⣽⣯" "⣾⣷")
    local _SPIN_PID=""
    spinner_start() {
        (( NO_SPINNER == 1 )) && return 0
        [[ ! -t 1 ]] && return 0
        local msg="$1"
        ( local i=1
          while true; do
              printf "\r  ${ACC}%s${NC}  ${TXM}%s${NC}" "${_FRAMES[$i]}" "$msg"
              (( i = i % ${#_FRAMES[@]} + 1 ))
              sleep 0.08
          done
        ) &
        _SPIN_PID=$!
        disown $_SPIN_PID 2>/dev/null
    }
    spinner_stop() {
        (( NO_SPINNER == 1 )) && return 0
        [[ ! -t 1 ]] && return 0
        if [[ -n "$_SPIN_PID" ]]; then
            kill "$_SPIN_PID" 2>/dev/null
            wait "$_SPIN_PID" 2>/dev/null
            _SPIN_PID=""
        fi
        printf "\r\033[K"
    }

    local _cleanup() {
        spinner_stop
        # `local funcname() {}` does NOT actually scope a function in zsh —
        # every helper below leaks into the global namespace. Clean them up
        # here so `lichtar update` doesn't permanently pollute the shell.
        unfunction has section ok skip warn detail log_line print_limited_list \
            spinner_start spinner_stop run _hex2a _cleanup 2>/dev/null
    }
    trap _cleanup EXIT INT TERM

    # ── Runner ───────────────────────────────────────────────────────────────
    local RUN_OUT="" RUN_RC=0
    run() {
        local msg="$1"; shift
        if (( DRYRUN == 1 )); then
            skip "[dry-run] $msg"
            detail "$*"
            RUN_OUT=""; RUN_RC=0
            return 0
        fi
        local tmp; tmp=$(mktemp 2>/dev/null || echo "/tmp/lichtar_update.$$.$RANDOM")
        : > "$tmp"
        spinner_start "$msg"
        "$@" >"$tmp" 2>&1
        local rc=$?
        spinner_stop
        RUN_OUT=$(<"$tmp"); RUN_RC=$rc
        rm -f "$tmp"
        if (( FORCE_LOG == 1 || rc != 0 )); then
            log_line "COMMAND: $*"
            printf "%s\n\n" "$RUN_OUT" >> "$LOG_FILE"
        fi
        (( VERBOSE == 1 )) && printf "%s\n" "$RUN_OUT"
        return $rc
    }

    local -a FAILED

    printf "\n"
    printf "  ${HDR}${B}          LICHTAR  UPDATE            ${NC}\n"
    printf "  ${ACC}${B}─────────────────────────────────────${NC}\n"

    (( FORCE_LOG == 1 )) && detail "Logging enabled: $LOG_FILE"
    (( DRYRUN == 1 ))    && detail "Dry-run mode — no changes will be made"

    # =========================================================================
    # 1. Self-update (lichtar itself)
    # =========================================================================
    section "${LHT}${B}󰏓${NC}  Lichtar (self)"

if [[ -d "$LICHTAR_HOME/.git" ]]; then
        local before after
        before=$(git -C "$LICHTAR_HOME" rev-parse --short HEAD 2>/dev/null)
        if run "Pulling lichtar updates…" git -C "$LICHTAR_HOME" pull --ff-only; then
            after=$(git -C "$LICHTAR_HOME" rev-parse --short HEAD 2>/dev/null)
            if [[ "$before" == "$after" ]]; then
                skip "Already up to date"
            else
                ok "Updated: ${before} → ${after}"
                source "$LICHTAR_HOME/bin/system_detect.zsh"
                detect_system
                detail "System detection cache refreshed — restart your shell to apply"
            fi
        else
            warn "lichtar self-update failed (local changes or diverged history?)"
            FAILED+=("lichtar (self)")
        fi
    else
        skip "Not a git checkout — skipping self-update"
        detail "Only works if ~/.lichtar was cloned directly (see: lichtar help install)"
    fi

    # =========================================================================
    # 2. Zsh plugins
    # =========================================================================
    section "${ZSHC}${B}󰊢${NC}  Zsh Plugins"

    local plugins_dir="$LICHTAR_HOME/plugins"
    local updated_count=0
    local updated_plugins_list=""

    if [[ -d "$plugins_dir" ]]; then
        local d name old_head new_head
        for d in "$plugins_dir"/*/; do
            [[ -d "$d/.git" ]] || continue
            name="${d:t}"
            old_head=$(git -C "$d" rev-parse --short HEAD 2>/dev/null)

            if (( DRYRUN == 1 )); then
                skip "[dry-run] Pulling ${name}…"
                continue
            fi

            if run "Pulling ${name}…" git -C "$d" pull --ff-only --quiet; then
                new_head=$(git -C "$d" rev-parse --short HEAD 2>/dev/null)
                if [[ "$old_head" != "$new_head" ]]; then
                    (( updated_count++ ))
                    updated_plugins_list+="${name}  ${old_head} → ${new_head}"$'\n'
                fi
            else
                warn "Failed: ${name}"
                FAILED+=("Zsh plugin: $name")
            fi
        done
    else
        skip "Plugins dir not found ($plugins_dir)"
    fi

    if (( DRYRUN == 0 )); then
        updated_plugins_list=$(printf "%s" "$updated_plugins_list" | sed '/^$/d' | sort)
        if (( updated_count > 0 )); then
            print_limited_list "Updated ${updated_count} plugin(s):" "$updated_plugins_list"
        elif [[ -d "$plugins_dir" ]]; then
            local zsh_failed_count
            zsh_failed_count=$(printf '%s\n' "${FAILED[@]}" | grep -c '^Zsh plugin:')
            (( zsh_failed_count == 0 )) && ok "All plugins up to date"
        fi
    fi

    # =========================================================================
    # 3. Yazi plugins
    # =========================================================================
    section "${YZI}${B}󰇥${NC}  Yazi Packages"

    if has ya; then
        if run "Upgrading yazi plugins…" ya pkg upgrade; then
            if echo "$RUN_OUT" | grep -qi "Deploying\|Upgraded\|up-to-date\|up to date"; then
                ok "Yazi plugins updated"
            else
                skip "Nothing to update"
            fi
        else
            warn "Yazi plugin upgrade failed"
            if echo "$RUN_OUT" | grep -qi "modified"; then
                detail "Some plugins were modified manually — reinstall:"
                detail "ya pkg install"
            fi
            FAILED+=("Yazi plugins")
        fi
    else
        skip "yazi (ya) not found"
    fi

    # =========================================================================
    # Footer
    # =========================================================================
    local elapsed=$SECONDS
    printf "\n  ${ACC}${B}─────────────────────────────────────${NC}\n"

    if (( ${#FAILED[@]} > 0 )); then
        warn "Completed with errors:"
        local fl
        for fl in "${FAILED[@]}"; do detail "$fl"; done
        if (( FORCE_LOG == 1 )); then
            detail "Log: $LOG_FILE"
        else
            detail "Tip: run with --log to capture full command output"
        fi
    else
        ok "All lichtar components up to date"
    fi

    printf "  ${KEY}${B}✨ Done${NC}  ${TXM}· %ss${NC}\n\n" "$elapsed"

    (( ${#FAILED[@]} > 0 )) && return 1
    return 0
}
