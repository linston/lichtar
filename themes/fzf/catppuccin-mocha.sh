# Catppuccin Mocha — fzf theme
# Aligned with yazi flavor.toml color logic
#
# Palette:
#   base       #1e1e2e   surface0   #313244   surface1   #45475a   surface2   #585b70
#   overlay0   #6c7086   overlay1   #7f849c   overlay2   #9399b2   subtext0   #a6adc8
#   text       #cdd6f4   blue       #89b4fa   teal       #94e2d5   green      #a6e3a1
#   yellow     #f9e2af   peach      #fab387   red        #f38ba8   mauve      #cba6f7
#   pink       #f5c2e7   sky        #89dceb   mantle     #181825   crust      #11111b

# Built as an array, not a single quoted string: FZF_DEFAULT_OPTS as a plain
# string cannot contain inline "# comment" text (fzf re-parses the whole
# value itself and has no concept of a comment there — it just sees "#" as
# an invalid option and refuses to start, on every fzf version tested).
# Here the comments are real shell comments, stripped before the array is
# ever built, so they never reach fzf at all.
#
# Every "key:value" part is single-quoted (not just the hex color): with
# extendedglob on (lichtar sets it globally), an unquoted "#" or "+" in a
# word is a glob operator, not a literal character, and this whole array
# is unquoted word context — "bg+:#313244" without quotes fails with
# "no matches found" before fzf ever sees it. Quoting only the "#0a0a0f"
# part isn't enough, since "bg+" alone (no "#" at all) fails the same way.
local -a _fzf_opts
_fzf_opts=(
    --color=dark
    --color='bg:#0a0a0f'            # main background — near black
    --color='gutter:#0a0a0f'        # left gutter — blends with background
    --color='preview-bg:#0a0a0f'    # preview window background
    --color='fg:#cdd6f4'            # main text
    --color='fg+:#cdd6f4'           # current line text
    --color='preview-fg:#cdd6f4'    # preview window text
    --color='query:#cdd6f4'         # query text in input line
    --color='disabled:#585b70'      # query text when search is disabled
    --color='hl:#f38ba8'            # matched characters in list
    --color='hl+:#f38ba8'           # matched characters in current line
    --color='prompt:#89b4fa'        # prompt symbol ('>') before query
    --color='pointer:#94e2d5'       # pointer to current line
    --color='marker:#f5c2e7'        # multi-select marker (Tab)
    --color='spinner:#94e2d5'       # loading spinner
    --color='info:#9399b2'          # info line (match count)
    --color='separator:#313244'     # horizontal separator of info line
    --color='scrollbar:#45475a'     # scrollbar
    --color='border:#708880'        # border around the whole window
    --color='label:#89b4fa'         # border label (--border-label)
    --color='preview-border:#6c7086'      # preview window border
    --color='preview-scrollbar:#45475a'   # preview window scrollbar
    --color='preview-label:#94e2d5'       # preview window border label
    --color='header:#a6e3a1'        # header line (--header)
)

# These ten all fail outright on older fzf (confirmed on 0.44.1 — the
# version currently shipped by Debian/Ubuntu stable — with either "unknown
# option" or "invalid color specification", which makes fzf refuse to
# start at all). Confirmed all ten work from fzf 0.68 on (tested the full
# option set against 0.44.1, 0.55.0, 0.62.0, 0.68.0 and 0.74.4), so they're
# only added once we can see the installed fzf is new enough.
if command -v fzf &>/dev/null; then
    local _fzf_cache="$LICHTAR_HOME/cache/fzf_version"
    local _fzf_minor

    if [[ -f "$_fzf_cache" && ! "$(command -v fzf)" -nt "$_fzf_cache" ]]; then
        _fzf_minor=$(<"$_fzf_cache")
    else
        _fzf_minor="${$(fzf --version 2>/dev/null)#0.}"
        _fzf_minor="${${_fzf_minor%%.*}%% *}"
        print -r -- "$_fzf_minor" >| "$_fzf_cache"
    fi

    if (( ${_fzf_minor:-0} >= 68 )); then
        _fzf_opts+=(
            --highlight-line
            --color='alt-bg:#111119'       # alternating row background — between bg and bg+
            --color='input-bg:#0a0a0f'     # input line background
            --color='selected-fg:#cdd6f4'  # selected items text
            --color='ghost:#585b70'        # placeholder text (hint)
            --color='selected-hl:#f38ba8'  # matched characters in selected lines
            --color='selected-bg:#1e1e2e'  # selected (multi-select) lines background
            --color='list-border:#6c7086'  # border around the list
            --color='input-border:#6c7086' # border around the input line
            --color='footer:#9399b2'       # footer line (--footer)
        )
    fi
fi

export FZF_DEFAULT_OPTS="${(j: :)_fzf_opts}"
