# =============================================================================
# ~/.lichtar/help/lichtar_help.zsh
# Interactive reference manual — Lichtar Native Engine
#
# Usage:
#   lichtar help              — full overview (paginated)
#   lichtar help <topic>      — specific section
#   lichtar help -l           — list all available topics
#
# Topics: nav prompt langs git files completion history input
#         python config man ssh maintenance install
# =============================================================================

_lichtar_help_render() {
    # ── ANSI helpers ──────────────────────────────────────────────────────────
    _hex_to_ansi() {
        local hex="${1#\#}"
        local r=$((16#${hex:0:2}))
        local g=$((16#${hex:2:2}))
        local b=$((16#${hex:4:2}))
        printf "\e[38;2;%d;%d;%dm" $r $g $b
    }
    local BOLD=$'\e[1m'
    local RESET=$'\e[0m'

    # ── Help UI palette (exported from theme) ─────────────────────────────────
    local YEL="$(_hex_to_ansi "$CL_HLP_HDR")"   # headers
    local GRN="$(_hex_to_ansi "$CL_HLP_KEY")"   # keys / commands
    local ORG="$(_hex_to_ansi "$CL_HLP_SEC")"   # section titles
    local BLU="$(_hex_to_ansi "$CL_HLP_EXM")"   # example commands
    local GRY="$(_hex_to_ansi "$CL_HLP_SEP")"   # separators / notes
    local LGR="$(_hex_to_ansi "$CL_HLP_TXT")"   # body text
    local RED="$(_hex_to_ansi "$CL_HLP_WRN")"   # warnings
    local CYN="$(_hex_to_ansi "$CL_HLP_ACC")"   # accents
    local WHT="$(_hex_to_ansi "$CL_HLP_VAL")"   # values

    # ── Prompt / theme colors (exported from theme) ───────────────────────────
    local T_SYS="$(_hex_to_ansi "$CL_DISTRO_ANDROID")"   # example badge (Android shown)
    local T_UBU="$(_hex_to_ansi "$CL_DISTRO_UBUNTU")"    # proot-distro override badge
    local T_SSH="$(_hex_to_ansi "$CL_SSH")"   # SSH badge
    local T_LOK="$(_hex_to_ansi "$CL_LOK")"   # root / locked
    local T_CDR="$(_hex_to_ansi "$CL_CDR")"   # current dir
    local T_PDR="$(_hex_to_ansi "$CL_PDR")"   # parent dir
    local T_DVD="$(_hex_to_ansi "$CL_DVD")"   # dividers
    local T_LNL="$(_hex_to_ansi "$CL_LNL")"   # └─ line
    local T_SCS="$(_hex_to_ansi "$CL_SCS")"   # success arrow
    local T_FLR="$(_hex_to_ansi "$CL_FLR")"   # failure arrow / error
    local T_ERR="$(_hex_to_ansi "$CL_ERR")"   # error code
    local T_BJB="$(_hex_to_ansi "$CL_BJB")"   # bg jobs
    local T_TIM="$(_hex_to_ansi "$CL_TIM")"   # clock
    local T_DUR="$(_hex_to_ansi "$CL_DUR")"   # duration
    local T_GIF="$(_hex_to_ansi "$CL_GIF")"   # git icon
    local T_GBR="$(_hex_to_ansi "$CL_GBR")"   # branch
    local T_GUC="$(_hex_to_ansi "$CL_GUC")"   # unstaged
    local T_GSC="$(_hex_to_ansi "$CL_GSC")"   # staged
    local T_GAB="$(_hex_to_ansi "$CL_GAB")"   # stash
    local T_GAH="$(_hex_to_ansi "$CL_GAH")"   # ahead
    local T_GBH="$(_hex_to_ansi "$CL_GBH")"   # behind
    local T_PYT="$(_hex_to_ansi "$CL_PYT")"   # Python
    local T_NOD="$(_hex_to_ansi "$CL_NOD")"   # Node.js
    local T_RST="$(_hex_to_ansi "$CL_RST")"   # Rust
    local T_GOL="$(_hex_to_ansi "$CL_GOL")"   # Go
    local T_PHP="$(_hex_to_ansi "$CL_PHP")"   # PHP
    local T_RBL="$(_hex_to_ansi "$CL_RBL")"   # Ruby
    local T_JAV="$(_hex_to_ansi "$CL_JAV")"   # Java
    local T_LUA="$(_hex_to_ansi "$CL_LUA")"   # Lua
    local T_CPP="$(_hex_to_ansi "$CL_CPP")"   # C/C++
    local T_ZIG="$(_hex_to_ansi "$CL_ZIG")"   # Zig
    local T_DEN="$(_hex_to_ansi "$CL_DEN")"   # Deno
    local T_BUN="$(_hex_to_ansi "$CL_BUN")"   # Bun
    local T_SUG="$(_hex_to_ansi "$CL_SUG")"   # autosuggestion

    # ── Layout helpers ────────────────────────────────────────────────────────
    _H() {
        printf "\n"
        printf "  ${BOLD}${YEL}  Zsh Config Reference Manual${RESET}  ${GRY}· Lichtar Native Engine${RESET}\n"
        printf "\n${GRY}  ══════════════════════════════════════════════════════════════${RESET}\n"
    }
    _S()  {
        printf "\n  ${BOLD}${ORG}  $1${RESET}\n"
        printf "${GRY}  ──────────────────────────────────────────────────────────────${RESET}\n"
    }
    _SS() { printf "\n  ${BOLD}${CYN}  $1${RESET}\n"; }
    # _R  — standard row: green key | white value
    _R()  { printf "  ${GRN}  %-26s${RESET}${GRY}│${RESET}  ${WHT}%s${RESET}\n" "$1" "$2"; }
    # _RC — colored row: pre-colored first arg | white value
    _RC() { printf "  %-36s${GRY}│${RESET}  ${WHT}%s${RESET}\n" "$1" "$2"; }
    _N()  { printf "  ${GRY}     ↳ %s${RESET}\n" "$1"; }
    _B()  { printf "  ${LGR}    %s${RESET}\n" "$1"; }
    _X()  { printf "  ${BLU}    \$ %s${RESET}\n" "$1"; }
    _W()  { printf "  ${RED}    ⚠  %s${RESET}\n" "$1"; }
    _DIV(){ printf "${GRY}  ──────────────────────────────────────────────────────────────${RESET}\n"; }
    _BR() { printf "\n"; }

    # =========================================================================
    case "${1:-all}" in

    # ── TOPIC LIST ────────────────────────────────────────────────────────────
    -l|--list|list)
        _H
        _S "Available Topics"
        _B "Run  lichtar help <topic>  to open a specific section."
        _BR
        _R "nav"         "Navigation — cd, fzf, zoxide, yazi, up, mkcd"
        _R "prompt"      "Prompt anatomy — every icon and indicator explained"
        _R "langs"       "Language detection — Python, Node, Rust, Go and more"
        _R "git"         "Git aliases and prompt git indicators"
        _R "files"       "File listing (eza), archives (extract)"
        _R "completion"  "Tab completion with fzf-tab and file previews"
        _R "history"     "History search, settings, non-ASCII guard"
        _R "input"       "Autosuggestions, autopair, syntax highlighting"
        _R "python"      "Python alias, virtualenv display"
        _R "config"      "zrc, exec zsh, plugin management, .env flags"
        _R "man"         "Colored man pages"
        _R "ssh"         "SSH agent auto-start"
        _R "maintenance" "Updating plugins, clearing caches, troubleshooting"
        _R "install"     "Install / uninstall — self-contained in one folder"
        _BR
        ;;

    # ── NAVIGATION ────────────────────────────────────────────────────────────
    nav|navigation)
        _H
        _S "Navigation & Directory Jumping"
        _B "This config replaces plain 'cd' with several smarter tools."
        _B "Each tool solves a different problem — learn them gradually."
        _BR

        _SS "Fuzzy Directory Jump — Ctrl+F  (fzf)"
        _B "Opens an interactive list of subdirectories up to 4 levels deep."
        _B "Uses fd if available, falls back to find."
        _R "Ctrl+F"         "open directory browser"
        _R "Type to filter" "narrows the list in real time"
        _R "Enter"          "jump to selected directory"
        _R "Esc"            "cancel without moving"
        _X "Ctrl+F → type 'src' → select ~/devflow/src/core → Enter"
        _BR

        _SS "Smart Frecency Jump — Ctrl+G  (zoxide)"
        _B "zoxide tracks how often and how recently you visit directories."
        _B "After a few visits it learns your habits — jump with a fragment."
        _R "Ctrl+G"   "open zoxide history in fzf"
        _R "z <name>" "direct jump by frecency (command line)"
        _N "First use: visit directories normally — zoxide builds its database."
        _X "Ctrl+G → type 'flow' → jumps to ~/projects/devflow"
        _X "z dev           ← jumps to your most-visited 'dev*' directory"
        _BR

        _SS "File Picker — Ctrl+T"
        _B "Opens fzf to find any file recursively. Selected path is"
        _B "inserted into the command line — not executed."
        _R "Ctrl+T" "pick a file and insert its path"
        _X "micro Ctrl+T → select config.py → line becomes: micro ./src/config.py"
        _BR

        _SS "History Search — Ctrl+R"
        _B "Searches past commands, ranked by how often you use them"
        _B "(ties broken by most-recent-use). Not just chronological."
        _R "Ctrl+R"        "open frequency-ranked history search"
        _R "Type fragment" "filter by any part of the command"
        _R "Enter"         "re-run selected command"
        _X "Ctrl+R → type 'pip install' → your most-used pip install line, first"
        _N "See:  lichtar help history  for how the ranking works."
        _BR

        _SS "AUTO_CD — type a directory name without 'cd'"
        _R "<dirname>" "enter directory — no 'cd' needed"
        _R ".."        "go up one level"
        _X "devflow             ← same as:  cd ~/projects/devflow"
        _BR

        _SS "Other Navigation"
        _R "up [N]"     "go up N directory levels  (default: 1)"
        _X "up          →  cd .."
        _X "up 3        →  cd ../../.."
        _BR
        _R "mkcd <name>" "create directory and enter it immediately"
        _X "mkcd my-project     →  mkdir -p my-project && cd my-project"
        _BR
        _R "y" "open Yazi — full TUI file manager"
        _N "Navigate with arrow keys. Shell follows to wherever you quit."
        _N "Supports preview, bulk rename, archive inspection and more."
        _BR

        _SS "Clear Screen — Ctrl+L"
        _B "Clears visible terminal output but preserves the scrollback buffer."
        _B "Unlike 'clear', you can still scroll up to see previous output."
        ;;

    # ── PROMPT ────────────────────────────────────────────────────────────────
    prompt)
        _H
        _S "Prompt Anatomy"
        _B "The prompt spans two lines and is rebuilt after every command."
        _B "Every element is contextual — it only appears when relevant."
        _BR

        _SS "Visual Structure"
        printf "  ${GRY}    ┌─ line 1 ──────────────────────────────────────────────────┐${RESET}\n"
        printf "  ${GRY}    │${RESET}  ${T_SYS}${BOLD} ${RESET} ${T_PDR}~/${RESET}${T_PDR}devflow/${RESET}${T_CDR}src${RESET}  ${T_GIF} ${RESET}${T_GBR}main${RESET}${T_GUC}●${RESET}${T_GAH}⇡2${RESET}${T_GAB}⚑${RESET}  ${T_DVD}·${RESET} ${T_PYT} 3.13.2${RESET}\n"
        printf "  ${GRY}    │  badge  path               branch  indicators  language${RESET}\n"
        printf "  ${GRY}    ├─ line 2 ──────────────────────────────────────────────────┤${RESET}\n"
        printf "  ${GRY}    │${RESET}  ${T_LNL}└─${RESET} ${T_ERR}✘1${RESET} ${T_BJB} ${RESET} ${T_SCS}${BOLD}❯${RESET}              ${GRY}│${RESET}  ${T_DUR}3s ${T_TIM}13:45${RESET}\n"
        printf "  ${GRY}    │  line   error jobs arrow           timer  time (right)${RESET}\n"
        printf "  ${GRY}    └───────────────────────────────────────────────────────────┘${RESET}\n"
        _BR

        _SS "Badge — system icon (leftmost icon)"
        _RC "  ${T_SYS} ${RESET}" "auto-detected platform + distro icon & color"
        _N "Example above shows Android/Termux — yours depends on your system."
        _N "Full info + manual refresh:  lichtar system  /  lichtar system --force"
        _RC "  ${T_UBU} ${RESET}" "inside a proot Linux distro (Termux only)"
        _RC "  ${T_SSH}󰣀 ${RESET}" "connected via SSH to a remote server"
        _RC "  ${T_LOK} ${RESET}" "running as root — elevated privileges"
        _BR

        _SS "Path display"
        _RC "  ${T_PDR}~/${RESET}${T_PDR}projects/${RESET}${T_CDR}src${RESET}" "tilde + parent dirs + current dir"
        _RC "  ${T_DVD}…/${RESET}${T_PDR}two/${RESET}${T_CDR}last${RESET}"     "path truncated — only last 3 segments shown"
        _RC "  ${T_LOK}🔒${RESET} path" "read-only directory — cannot write files here"
        _N "Full path always accessible via:  echo \$PWD"
        _BR

        _SS "Git indicators  (only inside a git repository)"
        _RC "  ${T_GIF} ${RESET}${T_GBR}main${RESET}" "git icon + current branch name"
        _RC "  ${T_GUC}●${RESET}" "unstaged changes  (modified, not yet 'git add')"
        _RC "  ${T_GSC}●${RESET}" "staged changes  ('git add' done, not yet committed)"
        _RC "  ${T_GAH}⇡N${RESET}" "N commits ahead of remote  (push needed)"
        _RC "  ${T_GBH}⇣N${RESET}" "N commits behind remote  (pull needed)"
        _RC "  ${T_GAB}⚑${RESET}" "stash exists  ('git stash' was used)"
        _N "Ahead/behind cached per-directory for 30 seconds."
        _N "Cache invalidates after any git / lazygit / tig command."
        _BR

        _SS "Language version  (right of line 1)"
        _RC "  ${T_DVD}·${RESET} ${T_PYT} 3.13.2${RESET}" "runtime detected in current project directory"
        _N "See:  lichtar help langs  for full list and trigger conditions."
        _BR

        _SS "Line 2 — status and input"
        _RC "  ${T_LNL}└─${RESET} ${T_SCS}❯${RESET}" "last command succeeded  (exit code 0)"
        _RC "  ${T_LNL}└─${RESET} ${T_ERR}✘N${RESET} ${T_FLR}❯${RESET}" "last command failed  (N = exit code)"
        _RC "  ${T_BJB} ${RESET}" "background jobs running  (e.g. suspended with Ctrl+Z)"
        _BR

        _SS "Right prompt  (RPROMPT)"
        _RC "  ${T_DUR}3s${RESET}" "last command took 3 seconds  (shown only for 2s+)"
        _RC "  ${T_DUR}1m32s${RESET}" "last command took 1 minute 32 seconds"
        _RC "  ${T_TIM}13:45${RESET}" "current time — updates on every prompt"
        _N "Execution time measured from Enter to next prompt appearance."
        ;;

    # ── LANGUAGES ─────────────────────────────────────────────────────────────
    langs|languages)
        _H
        _S "Language Version Detection"
        _B "When you enter a project directory, the prompt scans for known"
        _B "marker files and source files to detect which runtime is in use."
        _B "The version is shown inline — no configuration needed."
        _BR

        _SS "How detection works"
        _B "1. Checks for marker files (e.g. Cargo.toml, package.json)"
        _B "2. Falls back to glob scan for source files (e.g. *.py, *.rs)"
        _B "3. Calls the runtime binary once to get the version"
        _B "4. Caches result — binary is not called again for this session"
        _N "Storage / cache / download directories are excluded from scanning."
        _BR

        _SS "Detected languages"
        _RC "  ${T_PYT} Python${RESET}"  "requirements.txt · pyproject.toml · .python-version · *.py"
        _N "Shows virtualenv name when active:  (myenv) 3.11.2"
        _N "Version resets automatically on venv activate/deactivate."
        _BR
        _RC "  ${T_NOD} Node.js${RESET}" "package.json · node_modules/ · *.js · *.ts"
        _N "Shows nvm-selected version when nvm is active."
        _BR
        _RC "  ${T_RST} Rust${RESET}"    "Cargo.toml · *.rs"
        _BR
        _RC "  ${T_GOL} Go${RESET}"      "go.mod · *.go"
        _BR
        _RC "  ${T_PHP} PHP${RESET}"     "composer.json · *.php"
        _BR
        _RC "  ${T_RBL} Ruby${RESET}"    "Gemfile · *.rb"
        _BR
        _RC "  ${T_JAV} Java${RESET}"    "pom.xml · build.gradle · *.java"
        _BR
        _RC "  ${T_LUA} Lua${RESET}"     "init.lua · stylua.toml · .lua-version · *.lua"
        _BR
        _RC "  ${T_CPP} C/C++${RESET}"   "CMakeLists.txt · Makefile · *.cpp · *.c · *.h"
        _BR
        _RC "  ${T_ZIG} Zig${RESET}"     "build.zig · *.zig"
        _BR
        _RC "  ${T_DEN}󰲋 Deno${RESET}"   "deno.json · *.ts · *.js"
        _BR
        _RC "  ${T_BUN} Bun${RESET}"     "bun.lockb · *.ts · *.js"
        _BR

        _SS "Cache management"
        _R "exec zsh"  "full restart — clears all cached versions"
        _R "cd <dir>"  "moving directories triggers re-detection"
        _N "Version binaries are called lazily — only when the language is detected."
        _N "Multiple languages can appear simultaneously in polyglot projects."
        ;;

    # ── GIT ───────────────────────────────────────────────────────────────────
    git)
        _H
        _S "Git Integration"
        _BR

        _SS "Aliases"
        _R "gst"  "git status -sb  (compact, shows branch + changed files)"
        _R "glog" "git log --oneline --graph --decorate  (last 20 commits)"
        _BR

        _SS "Prompt indicators — full reference"
        _RC "  ${T_GIF} ${RESET}${T_GBR}main${RESET}" "git icon + branch name"
        _RC "  ${T_GUC}●${RESET}" "unstaged changes — modified files not yet staged"
        _RC "  ${T_GSC}●${RESET}" "staged changes — ready to commit"
        _RC "  ${T_GAH}⇡N${RESET}" "N commits ahead of upstream  (push needed)"
        _RC "  ${T_GBH}⇣N${RESET}" "N commits behind upstream  (pull needed)"
        _RC "  ${T_GAB}⚑${RESET}" "stash is not empty"
        _BR

        _SS "Cache behavior"
        _B "Ahead/behind counts are cached per directory for 30 seconds."
        _R "Auto-invalidated after" "git · lazygit · tig commands"
        _R "Manual invalidation"    "cd away and back, or: exec zsh"
        _BR

        _SS "Daily use"
        _X "gst                  ← quick overview before committing"
        _X "glog                 ← visual branch/merge history"
        _X "git stash            ← saves work-in-progress  (⚑ appears)"
        _X "git stash pop        ← restores it  (⚑ disappears)"
        ;;

    # ── FILES ─────────────────────────────────────────────────────────────────
    files)
        _H
        _S "File Operations"
        _BR

        _SS "File listing  (eza — modern ls replacement)"
        _B "'ls' is replaced with eza: icons, colors, directories first."
        _BR
        _R "ls" "simple listing with icons"
        _R "ll" "long format: permissions · owner · size · date · hidden"
        _R "la" "all files including hidden"
        _R "lt" "tree view — 2 levels deep"
        _N "Deeper tree:  eza --tree --icons --level=4"
        _X "ll                  ← detailed view"
        _X "lt                  ← project structure overview"
        _BR

        _SS "Editor"
        _R "v <file>" "open file in Neovim  (alias for nvim)"
        _X "v ~/.zshrc"
        _BR

        _SS "Archive extraction  (extract — universal unpacker)"
        _B "Detects archive format automatically — no need to remember flags."
        _BR
        _R "extract <file>" "detect format and unpack"
        _BR
        _R ".tar.gz  .tgz" "tar + gzip  (most common on Linux)"
        _R ".tar.bz2"      "tar + bzip2"
        _R ".tar.xz"       "tar + xz  (high compression)"
        _R ".tar.zst"      "tar + zstd  (fast — used by Termux pkg)"
        _R ".zip"          "zip archive"
        _R ".7z"           "7-zip  (requires p7zip)"
        _R ".rar"          "RAR  (requires unrar)"
        _R ".gz"           "single gzip file"
        _R ".zst"          "single zstd file"
        _BR
        _X "extract archive.tar.gz"
        _X "extract backup.zip"
        _X "extract data.tar.zst"
        ;;

    # ── COMPLETION ────────────────────────────────────────────────────────────
    completion)
        _H
        _S "Tab Completion  (fzf-tab)"
        _B "Tab completion upgraded to an interactive fzf menu with"
        _B "real-time filtering and file previews."
        _BR

        _SS "Basic usage"
        _R "Tab"           "open completion menu"
        _R "Type to filter" "narrows candidates in real time"
        _R "↑ / ↓"        "navigate the list"
        _R "Enter"         "confirm and insert"
        _R "Esc"           "cancel"
        _BR

        _SS "File and directory previews"
        _R "Directory" "shows tree view  (eza --tree, 1 level)"
        _R "Text file"  "shows first 200 lines"
        _R "Binary"     "shows file type information"
        _BR

        _SS "Matching  (case-insensitive, partial)"
        _X "cd doc<Tab>          →  matches Documents, .docker, doc_notes"
        _X "git ch<Tab>          →  matches checkout, cherry-pick, check-ignore"
        _BR

        _SS "Completion cache"
        _B "zcompdump is rebuilt at most once every 20 hours."
        _R "Force rebuild" "rm ~/.lichtar/cache/zcompdump* && exec zsh"
        ;;

    # ── HISTORY ───────────────────────────────────────────────────────────────
    history)
        _H
        _S "History"
        _BR

        _SS "Search — ranked by frequency, not just chronology"
        _R "Ctrl+R" "fuzzy search, sorted by usage count (ties: most recent wins)"
        _N "Type any fragment — matches anywhere in the command."
        _X "Ctrl+R → type 'install flask' → your most-used matching line, first"
        _BR
        _R "↑ arrow" "go back through commands matching current prefix"
        _R "↓ arrow" "go forward through matches"
        _X "Type: git  then press ↑  →  cycles only through git commands"
        _BR

        _SS "How the ranking works"
        _B "Two separate logs feed different features — this is intentional:"
        _R "~/.lichtar/cache/history"      "standard zsh HISTFILE — dedup'd, feeds ↑/↓"
        _R "~/.lichtar/cache/history_freq" "append-only log, every run — feeds Ctrl+R"
        _N "Every command execution appends a line — duplicates ARE kept here,"
        _N "on purpose, so repeated use raises a command's Ctrl+R rank over time."
        _N "Counted with awk, sorted by (count desc, last-used desc)."
        _N "Auto-trimmed to the last 20,000 lines once it passes 40,000."
        _BR

        _SS "Settings"
        _R "In memory"        "50,000 entries"
        _R "On disk"          "50,000 entries  (~/.lichtar/cache/history)"
        _R "SHARE_HISTORY"    "shared across all open terminal sessions"
        _R "EXTENDED_HISTORY" "each entry includes timestamp"
        _R "No duplicates"    "HISTFILE only — the frequency log keeps every run"
        _BR

        _SS "Excluding commands from history"
        _B "Prefix any command with a space — it will not be saved:"
        _X " export TOKEN=abc123        ← not recorded"
        _B "Commands starting with non-ASCII are also excluded automatically."
        _BR

        _SS "Non-ASCII / Wrong keyboard layout guard"
        _B "If Cyrillic or other non-ASCII characters appear at the start"
        _B "of a command, the shell intercepts Enter and warns you."
        _BR
        _R "First Enter"  "shows warning — command NOT executed"
        _R "Second Enter" "executes anyway  (if you intended it)"
        _R "Backspace"    "clears warning when first word becomes clean ASCII"
        _N "Guard checks the entire first word — catches mixed strings like 'qüкt'."
        _N "Commands with non-ASCII first word are excluded from history."
        ;;

    # ── INPUT ─────────────────────────────────────────────────────────────────
    input)
        _H
        _S "Input Assistance"
        _BR

        _SS "Autosuggestions  (zsh-autosuggestions)"
        _B "As you type, a grey ghost suggestion appears based on history."
        printf "  ${LGR}    Example:  ${RESET}git commit -m \"fix prompt\"${T_SUG} --no-verify${RESET}\n"
        _BR
        _R "→  right arrow" "accept the full suggestion"
        _R "Ctrl+→"         "accept one word of the suggestion"
        _R "Keep typing"    "ignore suggestion and continue"
        _R "Esc"            "dismiss suggestion"
        _N "Suggestions come from history first, then from completion."
        _N "Async mode is enabled — suggestions never block input."
        _BR

        _SS "Physical Keyboard Bindings"
        _R "Ctrl+← / Ctrl+→" "jump backward / forward one word"
        _R "Home / End"       "jump to beginning / end of line"
        _R "Delete"           "delete character under cursor (forward)"
        _R "Ctrl+Backspace"   "delete entire word backward"
        _R "Ctrl+Delete"      "delete entire word forward"
        _R "Alt+Backspace"    "delete word backward (alternative)"
        _BR

        _SS "Auto-pairs  (zsh-autopair)"
        _B "Opening brackets and quotes are auto-closed. Cursor inside."
        _R "(  typed"  "inserts ()  — cursor inside"
        _R "[  typed"  "inserts []  — cursor inside"
        _R "{  typed"  "inserts {}  — cursor inside"
        _R "'  typed"  "inserts ''  — cursor inside"
        _R "\"  typed" "inserts \"\"  — cursor inside"
        _R "Backspace" "between pair  →  removes both characters"
        _BR

        _SS "Syntax highlighting  (fast-syntax-highlighting)"
        _B "Commands are colored in real time as you type:"
        _R "Green command" "found in PATH — valid"
        _R "Red command"   "not found in PATH — likely a typo"
        _R "Yellow string" "quoted string"
        _R "Blue path"     "valid file or directory path"
        _R "Grey comment"  "# comment"
        _BR

        _SS "Key bindings quick reference"
        _R "Ctrl+F" "fzf directory browser"
        _R "Ctrl+G" "zoxide smart jump"
        _R "Ctrl+T" "fzf file picker"
        _R "Ctrl+R" "frequency-ranked history search"
        _R "Ctrl+L" "clear screen  (preserves scrollback)"
        _R "↑ / ↓"  "history substring search"
        _R "→"      "accept autosuggestion"
        ;;

    # ── PYTHON ────────────────────────────────────────────────────────────────
    python|py)
        _H
        _S "Python"
        _BR

        _SS "Alias"
        _B "If ptpython is installed it is used; otherwise falls back to python3."
        _R "py" "python3  (or ptpython if available)"
        _X "py script.py"
        _X "py -c 'print(2**32)'"
        _BR

        _SS "Virtualenv display in prompt"
        _B "When a virtualenv is active, its name appears inline:"
        printf "  ${LGR}    Example:  ${RESET}${T_PYT} (myenv) 3.11.2${RESET}\n"
        _BR
        _B "The version cache resets automatically on:"
        _R "source venv/bin/activate" "activating a venv"
        _R "deactivate"               "deactivating a venv"
        ;;

    # ── CONFIG ────────────────────────────────────────────────────────────────
    config)
        _H
        _S "Config Management"
        _BR

        _SS "Editing and reloading"
        _R "zrc"      "open ~/.zshrc in \$EDITOR, then safely reload"
        _N "Deregisters prompt hooks before reload — no hook accumulation."
        _N "If the file has errors, they are shown immediately after reload."
        _BR
        _R "exec zsh" "full shell restart — clears ALL caches and state"
        _N "Use this after installing new plugins or major config changes."
        _BR

        _SS "File structure  (~/.lichtar/)"
        _R "~/.zshrc"             "main config  (zsh loads this automatically)"
        _R "~/.lichtar/.env"      "user flags — theme, features, editor"
        _R "~/.lichtar/core/"     "path, options, completion, functions, misc"
        _R "~/.lichtar/ui/"       "prompt, git, language detection"
        _R "~/.lichtar/widgets/"  "fzf, zoxide, yazi, guard, keys, magic screen"
        _R "~/.lichtar/themes/"   "catppuccin-mocha and tool-specific configs"
        _R "~/.lichtar/plugins/"  "all plugins  (git clones)"
        _R "~/.lichtar/help/"     "this help system"
        _R "~/.lichtar/bin/"      "lichtar CLI  (in PATH)"
        _R "~/.lichtar/cache/"    "zcompdump, fsh theme hash, system.env, history(+freq)"
        _BR

        _SS "User flags  (~/.lichtar/.env)"
        _R "LICHTAR_THEME"       "active theme name  (default: catppuccin-mocha)"
        _R "LICHTAR_EDITOR"      "default editor for \$EDITOR  (default: micro)"
        _R "LICHTAR_YAZI"        "1 = enable yazi integration"
        _R "LICHTAR_GIT_AHEAD"   "1 = show ahead/behind in prompt"
        _R "LICHTAR_LANG_DETECT" "1 = enable language version detection"
        _R "LICHTAR_DEBUG"       "1 = verbose module loading"
        _R "LICHTAR_PROFILE"     "1 = show startup timing per module"
        _N "'v' always opens Neovim regardless of \$EDITOR — it's a separate alias."
        _BR

        _SS "Theming"
        _B "One theme file defines everything: zsh prompt colors AND the matching"
        _B "config for bat, eza, fzf and fast-syntax-highlighting — switching"
        _B "LICHTAR_THEME re-themes the whole environment, not just the prompt."
        _BR
        _R "Currently shipped"    "catppuccin-mocha  (only one, for now)"
        _R "~/.lichtar/themes/<name>.zsh" "zsh color variables (CL_*) — the source of truth"
        _R "~/.lichtar/themes/bat/"       "bat .tmTheme, via \$BAT_CONFIG_DIR"
        _R "~/.lichtar/themes/eza/"       "eza theme.yml, via \$EZA_CONFIG_DIR"
        _R "~/.lichtar/themes/fzf/"       "fzf color script, sourced directly"
        _R "~/.lichtar/themes/fast-syntax-highlighting/" "fsh .ini, applied via fast-theme"
        _N "fsh theme re-applies automatically after a fresh plugin clone or .ini"
        _N "change — fingerprinted by hash + plugin dir mtime, cached after that."
        _BR
        _B "To add a new theme: copy catppuccin-mocha.zsh, redefine every CL_*"
        _B "variable, and add matching bat/eza/fzf/fsh config files in the same"
        _B "layout. Set LICHTAR_THEME=<name> in .env to switch."
        _BR

        _SS "Loaded plugins"
        _R "zsh-autosuggestions"          "grey history-based suggestions"
        _R "zsh-history-substring-search" "↑/↓ filtered history navigation"
        _R "fzf-tab"                      "fzf-powered tab completion with previews"
        _R "fast-syntax-highlighting"     "real-time command coloring"
        _R "zsh-autopair"                 "auto-close brackets and quotes"
        _BR

        _SS "Updating plugins"
        _X "lichtar update"
        _N "Manual equivalent, if you need it:"
        _X "for d in ~/.lichtar/plugins/*/; do"
        _X "    echo \"Updating \${d:t}...\""
        _X "    git -C \"\$d\" pull --ff-only"
        _X "done"
        ;;

    # ── MAN PAGES ─────────────────────────────────────────────────────────────
    man)
        _H
        _S "Colored Man Pages"
        _B "Man pages are rendered with color via LESS_TERMCAP variables."
        _B "No extra tools needed — uses the built-in less pager."
        _BR
        _R "Bold text"  "green — section headings, command names"
        _R "Underlined" "red italic — arguments, placeholders"
        _R "Standout"   "yellow — search result highlights"
        _BR
        _X "man git"
        _X "man zsh"
        _X "man 5 crontab"
        _BR
        _B "Navigation inside man (less keybindings):"
        _R "↑ / ↓  or  j / k" "scroll line by line"
        _R "Space / b"         "scroll page forward / backward"
        _R "/pattern"          "search forward"
        _R "n / N"             "next / previous search result"
        _R "q"                 "quit"
        ;;

    # ── SSH ───────────────────────────────────────────────────────────────────
    ssh)
        _H
        _S "SSH Agent"
        _B "An SSH agent starts automatically when the shell starts,"
        _B "if no agent is already running."
        _BR

        _SS "Typical workflow"
        _X "ssh-keygen -t ed25519 -C 'termux'    ← generate key (once ever)"
        _X "ssh-copy-id user@server               ← install public key on server"
        _X "ssh-add ~/.ssh/id_ed25519             ← load key into agent (once per session)"
        _X "ssh user@server                       ← no passphrase prompt"
        _BR

        _SS "Prompt indicator"
        _RC "  ${T_SSH}󰣀${RESET}" "SSH session active"
        _BR

        _SS "Notes for Termux"
        _W "Android may kill background processes including the agent."
        _N "If SSH stops working after sleep, re-run: ssh-add"
        _N "Consider Termux:Boot to restart the agent after device reboot."
        ;;

    # ── INSTALLATION ──────────────────────────────────────────────────────────
    install|installation|setup)
        _H
        _S "Installation & Setup"
        _B "Termux/Android and Linux (Arch confirmed; other distros are"
        _B "detected and supported architecturally but not yet verified)."
        _B "Everything lives in one self-contained folder: ~/.lichtar. No system"
        _B "files, nothing outside it but one loader block in ~/.zshrc — trivial"
        _B "to back up, move between machines, or remove completely."
        _BR

        _SS "Install"
        _X "git clone https://github.com/linston/lichtar ~/.lichtar"
        _X "~/.lichtar/bin/install.sh"
        _N "Add -y to skip prompts (the .zshrc overwrite prompt is never skipped)."
        _N "Cloning straight into ~/.lichtar is what makes it a real git checkout —"
        _N "that's required for 'lichtar update' to update lichtar itself, too."
        _BR

        _SS "Safe to re-run any time"
        _B "install.sh only fills in what's missing. It never copies over, deletes,"
        _B "or silently overwrites anything already in ~/.lichtar."
        _X "~/.lichtar/bin/install.sh"
        _BR

        _SS "What it does — in order"
        _R "1. Packages"      "checks what's missing, prints the exact install command for"
        _N "your package manager (pacman/apt/dnf/zypper/apk/xbps) — it never installs"
        _N "anything itself or calls sudo. You run the printed command yourself."
        _R "2. Zsh plugins"   "git-clones the 5 plugins into ~/.lichtar/plugins/"
        _R "3. Directories"   "verifies ~/.lichtar/cache exists"
        _R "4. .zshrc"        "installs it, or backs up + replaces an existing one"
        _R "5. Nerd Font"     "downloads JetBrainsMono NF on Termux; on Linux it points"
        _N "you to install one system-wide and set it in your terminal emulator"
        _R "6. Default shell" "offers to chsh -s to zsh if it isn't already"
        _BR

        _SS "Uninstalling"
        _B "Everything lives in ~/.lichtar + one block in ~/.zshrc — nothing else"
        _B "on the system is ever touched."
        _R "1. Replace ~/.zshrc" "restore your backup, or write your own config"
        _N "install.sh saves one at ~/.zshrc.lichtar-backup-<timestamp> whenever"
        _N "it replaces an existing ~/.zshrc — check there first."
        _R "2. rm -rf ~/.lichtar" "removes everything else"
        _BR

        _SS "Required tools"
        _R "zsh"     "the shell itself"
        _R "git"     "required for plugin installation and lichtar update"
        _R "curl"    "used by install.sh itself  (Nerd Font download on Termux)"
        _R "fzf"     "fuzzy finder — powers Ctrl+F, Ctrl+R, Ctrl+T, zoxide picker"
        _R "zoxide"  "smart directory jumper — powers Ctrl+G"
        _R "eza"     "modern ls replacement — ls/ll/la/lt, fzf-tab previews"
        _R "fd"      "fast file finder — Ctrl+F / Ctrl+T  (falls back to find)"
        _R "bat"     "syntax-highlighted preview — used by yazi, themed to match"
        _R "unzip"   "extract — .zip"
        _R "p7zip"   "extract — .7z  (provides the 7z/7za binary)"
        _R "yazi"    "TUI file manager  (y command)"
        _R "less"    "pager used by lichtar help"
        _BR

        _SS "Optional tools"
        _R "unrar"    "extract — .rar"
        _R "zstd"     "extract — .zst / .tar.zst"
        _R "neovim"  "'v' alias always opens this — independent of \$EDITOR"
        _R "ptpython" "used by 'py' alias if present, else falls back to python3"
        _R "openssh"  "ssh-agent/ssh-keygen/ssh-copy-id — see: lichtar help ssh"
        _N "Not installed by default on Termux — pkg install openssh"
        _BR

        _SS "Verification"
        _X "echo \$SHELL                  ← should show: .../bin/zsh"
        _X "lichtar doctor                ← full environment check"
        _X "lichtar system                ← confirm platform/distro/icon detection"
        _X "lichtar help                  ← this help should open"
        _X "ls ~/.lichtar/plugins/        ← all 5 plugins should be present"
        _BR

        _SS "Troubleshooting"
        _R "Anything missing/broken" "lichtar doctor  — checks everything, suggests fixes"
        _R "Wrong distro/icon detected" "lichtar system --force  — re-run detection"
        _R "Plugin errors"          "re-run install.sh — it skips what's already cloned"
        _R "Completion broken"     "rm ~/.lichtar/cache/zcompdump* && exec zsh"
        _BR
        ;;

# ── MAINTENANCE ───────────────────────────────────────────────────────────
    maintenance)
        _H
        _S "Maintenance & Troubleshooting"
        _BR

        _SS "lichtar CLI commands"
        _R "lichtar doctor"          "full environment check — deps, versions, font, suggests fixes"
        _R "lichtar update"          "pulls latest changes for all installed plugins"
        _R "lichtar system"          "shows cached platform/distro/package-manager/icon info"
        _R "lichtar system --force"  "re-runs detection and overwrites the cache"
        _R "lichtar help <topic>"    "this help system"
        _BR

        _SS "Updating plugins"
        _X "lichtar update"
        _N "Manual equivalent:  for d in ~/.lichtar/plugins/*/; do git -C \"\$d\" pull --ff-only; done"
        _BR

        _SS "Clearing caches"
        _R "Completion cache"       "rm ~/.lichtar/cache/zcompdump* && exec zsh"
        _R "fsh theme cache"        "rm ~/.lichtar/cache/fsh_theme.md5 && exec zsh"
        _R "Language version cache" "exec zsh  (cleared on full restart)"
        _R "Git ahead/behind cache" "cd away and back  (30s TTL anyway)"
        _R "System detection cache" "lichtar system --force"
        _BR

        _SS "Checking what's loaded"
        _X "functions | grep '_assemble\|_build\|_git'   ← prompt functions"
        _X "zle -l | grep accept-line                    ← ZLE widget chain"
        _X "ls -la ~/.lichtar/cache/zcompdump            ← completion cache age"
        _X "echo \$HISTFILE                               ← history location"
        _X "echo \$EDITOR                                 ← current editor"
        _BR

        _SS "Startup time"
        _B "Enable profiler in .env:  LICHTAR_PROFILE=1"
        _B "Then restart — per-module timings appear at shell start."
        _X "time zsh -i -c exit    ← total startup time"
        _BR

        _SS "Common issues"
        _R "Icons missing"      "lichtar doctor  — checks font, gives platform-correct steps"
        _R "Wrong system icon"  "lichtar system --force  — re-run detection"
        _R "Plugin not found"   "check: ls ~/.lichtar/plugins/  then: lichtar update"
        _R "Completion broken"  "rm ~/.lichtar/cache/zcompdump* && exec zsh"
        _R "History not saving" "check: echo \$HISTFILE and permissions"
        _R "Lang version stale" "exec zsh to clear version cache"
        _R "fsh colors wrong"   "rm ~/.lichtar/cache/fsh_theme.md5 && exec zsh"
        _BR

        _SS "Termux/Android-specific notes"
        _W "Termux has no standard 'locale' — [:ascii:] class unsupported in regex."
        _N "Non-ASCII detection uses LC_ALL=C + tr instead of =~ [:ascii:]."
        _W "Android memory killer may terminate background processes (ssh-agent)."
        _N "Use Termux:Boot app to persist services across reboots."
        ;;

    # ── FULL OVERVIEW ─────────────────────────────────────────────────────────
    all|*)
        _H

        _S "Quick Reference"
        _B "Run  lichtar help <topic>  for detailed explanations with examples."
        _BR

        _SS "Navigation"
        _R "Ctrl+F"     "fzf fuzzy cd — browse subdirectories"
        _R "Ctrl+G"     "zoxide jump — frecency-based smart cd"
        _R "Ctrl+T"     "fzf file picker — insert path into command"
        _R "Ctrl+R"     "fzf history search"
        _R "Ctrl+L"     "clear screen  (scrollback preserved)"
        _R "<dirname>"  "AUTO_CD — enter directory without 'cd'"
        _R "up [N]"     "go up N levels  (default 1)"
        _R "mkcd <dir>" "mkdir + cd combined"
        _R "y"          "Yazi TUI file manager"

        _SS "Files & Archives"
        _R "ls / ll / la / lt" "eza listings  (long / all / tree)"
        _R "v <file>"          "open in Neovim"
        _R "extract <file>"    "universal unpacker — gz bz2 xz zst zip 7z rar"

        _SS "Tab Completion"
        _R "Tab"           "fzf interactive menu with file previews"
        _R "Type to filter" "narrows in real time, case-insensitive"

        _SS "Input Assistance"
        _R "→  right arrow" "accept grey autosuggestion"
        _R "↑ / ↓"         "history substring search  (type prefix first)"
        _R "( [ { ' \""    "auto-closed by autopair"
        _R "Syntax colors"  "green = valid, red = not found"

        _SS "Git"
        _RC "  ${T_GIF} ${RESET}${T_GBR}branch${RESET}  ${T_GUC}●${RESET}unstaged  ${T_GSC}●${RESET}staged  ${T_GAH}⇡${RESET}ahead  ${T_GBH}⇣${RESET}behind  ${T_GAB}⚑${RESET}stash" ""
        _R "gst"  "git status -sb"
        _R "glog" "git log graph  (last 20 commits)"

        _SS "Python"
        _R "py" "python3  (or ptpython if available)"

        _SS "History"
        _R "Ctrl+R"         "fzf search"
        _R "Space prefix"   "command excluded from history"
        _R "Non-ASCII guard" "warns on wrong keyboard layout  (Enter twice to force)"

        _SS "Config & Maintenance"
        _R "zrc"                  "edit + safe reload ~/.zshrc"
        _R "exec zsh"             "full restart — clears all caches"
        _R "lichtar doctor"       "environment check — deps, versions, font"
        _R "lichtar update"       "pull latest changes for all plugins"
        _R "lichtar system"       "show platform/distro/package-manager info"
        _R "lichtar help <topic>" "detailed help"
        _R "lichtar help list"    "all available topics"

        _BR
        _DIV
        printf "  ${GRY}  Topics: ${YEL}nav  prompt  langs  git  files  completion${RESET}\n"
        printf "  ${GRY}          ${YEL}history  input  python  config  man  ssh${RESET}\n"
        printf "  ${GRY}          ${YEL}maintenance  install${RESET}\n"
        _BR
        ;;
    esac
}

# =============================================================================
# Entry point
# =============================================================================
_lichtar_help() {
    if [[ "${1:-}" == "-l" || "${1:-}" == "--list" || "${1:-}" == "list" ]]; then
        _lichtar_help_render list | less -R \
            --prompt="  lichtar help topics — press q to quit " \
            -j4
        return
    fi

    _lichtar_help_render "${@:-all}" | less -R \
        --prompt="  lichtar help${1:+ $1} — / search  n/N next/prev  q quit " \
        -j4
}
