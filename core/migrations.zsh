# =============================================================================
# lichtar — post-update migrations
# =============================================================================
#
# Runs only when lichtar update has written cache/update-pending.
# Keep the normal-startup path to a single file check until real migrations
# are needed.
#

_lichtar_migrations() {
    local pending_file="$LICHTAR_HOME/cache/update-pending"
    [[ -f "$pending_file" ]] || return 0

    local after
    after=$(sed -n 's/^after=//p' "$pending_file" | head -n1)

    printf "\n  ✨ Lichtar updated"
    [[ -n "$after" ]] && printf " → %s" "$after"
    printf "\n     New configuration is active in this shell.\n\n"

    # Consume the marker after the notification. Real state migrations can be
    # added here without turning init.zsh into a migration engine.
    rm -f "$pending_file"
}

_lichtar_migrations
