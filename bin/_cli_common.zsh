# =============================================================================
# lichtar — bin/_cli_common.zsh
# Shared helpers for lichtar's bin/ scripts (doctor, update, system).
#
# Sourced from within bin/lichtar's own process — never run standalone.
# Colors referenced below (B, NC, TXT, TXM, KEY, WRN) must already be set by
# the caller before these are used; each script sets its own, since exactly
# which tokens it needs (and their NO_COLOR fallback) differs per script.
# =============================================================================

has()     { command -v "$1" >/dev/null 2>&1; }
section() { printf "\n  ${B}${TXT}%s${NC}\n" "$1"; }
ok()      { printf "  ${KEY}${B}✔${NC}  ${TXT}%s${NC}\n" "$1"; }
skip()    { printf "  ${TXM}◦${NC}  ${TXM}%s${NC}\n" "$1"; }
warn()    { printf "  ${WRN}✘${NC}  ${TXT}%s${NC}\n" "$1"; }
detail()  { printf "     ${TXM}↳ %s${NC}\n" "$1"; }

_hex2a() {
    local hex="${1#\#}"
    local r=$((16#${hex:0:2})) g=$((16#${hex:2:2})) b=$((16#${hex:4:2}))
    printf "\e[38;2;%d;%d;%dm" $r $g $b
}

# `local funcname() {}` does not scope a function in zsh — every helper above
# leaks into the caller's namespace. In practice this is low-stakes (these
# scripts only ever run sourced inside bin/lichtar's own short-lived process,
# which discards everything on exit regardless), but callers should still
# clean up explicitly on every exit path, both for direct-source safety and
# so a stray leftover function is never mistaken for a real one mid-session.
#
# Usage: pass any additional, caller-specific leaked function names (include
# the caller's own cleanup function name too, since it leaks the same way):
#   trap 'my_cleanup' EXIT INT TERM
#   my_cleanup() { _lichtar_cli_cleanup my_extra_fn another_fn my_cleanup; }
_lichtar_cli_cleanup() {
    unfunction has section ok skip warn detail _hex2a _lichtar_cli_cleanup \
        "$@" 2>/dev/null
}
