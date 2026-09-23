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

    # Consume the marker after the new shell has loaded. Real state migrations
    # will be added here without turning init.zsh into a migration engine.
    rm -f "$pending_file"
}

_lichtar_migrations
