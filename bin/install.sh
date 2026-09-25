#!/bin/sh
# =============================================================================
# install.sh — lichtar installer
#
# Always run this from inside its final home:
#   git clone https://github.com/linston/lichtar ~/.lichtar
#   ~/.lichtar/bin/install.sh
#
# Safe to re-run any time — it only fills in what's missing (packages
# check, plugin clones, .env, .zshrc, font, default shell). Existing
# configuration is never overwritten without asking, and nothing is
# deleted from ~/.lichtar.
#
# POSIX sh — no bashisms, must run under Termux's /bin/sh too.
# =============================================================================

set -e

YES=0
for arg in "$@"; do
  case "$arg" in
  -y | --yes) YES=1 ;;
  -h | --help)
    cat <<EOF
Usage: $HOME/.lichtar/bin/install.sh [options]

Options:
  -y, --yes     Don't prompt — assume yes to all package/setup steps
                (the .zshrc overwrite prompt is never skipped by --yes)
  -h, --help    Show this help
EOF
    exit 0
    ;;
  esac
done

# ── Minimal color helpers (no theme available yet — lichtar isn't installed) ─
if [ -t 1 ]; then
  ESC=$(printf '\033')
  C_OK="${ESC}[32m"
  C_WARN="${ESC}[31m"
  C_INFO="${ESC}[36m"
  C_NC="${ESC}[0m"
  C_B="${ESC}[1m"
else
  C_OK=''
  C_WARN=''
  C_INFO=''
  C_NC=''
  C_B=''
fi

ok() { printf "  %s✔%s  %s\n" "$C_OK" "$C_NC" "$1"; }
info() { printf "  %s○%s  %s\n" "$C_INFO" "$C_NC" "$1"; }
warn() { printf "  %s✘%s  %s\n" "$C_WARN" "$C_NC" "$1"; }
section() { printf "\n  %s%s%s\n" "$C_B" "$1" "$C_NC"; }

confirm() {
  # $1 = prompt text. Returns 0 for yes.
  if [ "$YES" -eq 1 ]; then
    return 0
  fi
  printf "  %s?%s  %s [y/N] " "$C_INFO" "$C_NC" "$1"
  read -r reply
  case "$reply" in
  [yY]*) return 0 ;;
  *) return 1 ;;
  esac
}

confirm_always() {
  # Same as confirm(), but never auto-answered by --yes — reserved for the
  # one place where skipping the prompt could silently replace an existing,
  # unrelated ~/.zshrc. Under a non-interactive stdin (e.g. CI) this safely
  # falls through to "no".
  printf "  %s?%s  %s [y/N] " "$C_INFO" "$C_NC" "$1"
  read -r reply
  case "$reply" in
  [yY]*) return 0 ;;
  *) return 1 ;;
  esac
}

# ── Package manager detection (POSIX, pre-bootstrap) ─────────────────────────
# install.sh never installs packages itself — it only detects what's
# missing and prints the correct copy-pasteable command for the
# person's own distro. No sudo/privilege handling needed here at all.
detect_pkg_manager() {
  # Reads bin/data/distro-pkgmanager.txt — single source of truth shared
  # with bin/system_detect.zsh. Can't just source that file directly: it's
  # zsh syntax, and this must run under plain POSIX /bin/sh, sometimes
  # before zsh itself is installed.
  if [ -n "$TERMUX_VERSION" ]; then
    echo "pkg"
    return 0
  fi
  [ -r /etc/os-release ] || return 1
  id_val=$(sed -n 's/^ID=//p' /etc/os-release | tr -d '"')
  like_val=$(sed -n 's/^ID_LIKE=//p' /etc/os-release | tr -d '"')
  data="$LICHTAR_HOME/bin/data/distro-pkgmanager.txt"
  [ -r "$data" ] || return 1

  while IFS= read -r line; do
    case "$line" in
    '' | '#'* | 'LIKE:'*) continue ;;
    esac
    pattern="${line%:*}"
    pm="${line##*:}"
    # shellcheck disable=SC2254 # intentional: $pattern must glob-match (e.g. "opensuse*"), not match literally
    case "$id_val" in
    $pattern)
      echo "$pm"
      return 0
      ;;
    esac
  done <"$data"

  while IFS= read -r line; do
    case "$line" in
    'LIKE:'*) ;;
    *) continue ;;
    esac
    rest="${line#LIKE:}"
    pattern="${rest%:*}"
    pm="${rest##*:}"
    # shellcheck disable=SC2254 # intentional: $pattern must glob-match, not match literally
    case "$like_val" in
    $pattern)
      echo "$pm"
      return 0
      ;;
    esac
  done <"$data"

  return 1
}

# Per-package-manager overrides, for cases where either the repo package
# name or the installed binary (or both) differ on one specific package
# manager — e.g. fd/fd-find/fdfind and bat/bat/batcat on apt, and Arch's
# p7zip package rename. Shared with lichtar_doctor.zsh (identical format).
# Format: "<generic>:<pm>:<pkg_name>:<bin_name>"
# Only add entries you've *verified* — a wrong name in a suggested
# command is worse than no suggestion.
resolve_pkg_name() {
  # $1 = generic package name -> prints the resolved package name for $PM
  generic="$1"
  while IFS= read -r entry; do
    case "$entry" in '' | '#'*) continue ;; esac
    ov_generic=${entry%%:*}
    rest=${entry#*:}
    ov_pm=${rest%%:*}
    rest=${rest#*:}
    ov_name=${rest%%:*}
    if [ "$ov_generic" = "$generic" ] && [ "$ov_pm" = "$PM" ]; then
      echo "$ov_name"
      return 0
    fi
  done <"$LICHTAR_HOME/bin/data/pkg-overrides.txt"
  echo "$generic"
}

resolve_pkg_bin() {
  # $1 = generic package name -> prints the resolved binary name for $PM,
  # or nothing if there's no override for it (caller keeps its own default)
  generic="$1"
  while IFS= read -r entry; do
    case "$entry" in '' | '#'*) continue ;; esac
    ov_generic=${entry%%:*}
    rest=${entry#*:}
    ov_pm=${rest%%:*}
    rest=${rest#*:}
    ov_bin=${rest#*:}
    if [ "$ov_generic" = "$generic" ] && [ "$ov_pm" = "$PM" ]; then
      echo "$ov_bin"
      return 0
    fi
  done <"$LICHTAR_HOME/bin/data/pkg-overrides.txt"
}

pm_install_cmd() {
  # $* = already-resolved package names -> one copy-pasteable command.
  # SUDO_PREFIX is empty on Termux and when already running as root.
  case "$PM" in
  pkg) echo "pkg install$(printf ' %s' "$@")" ;;
  pacman) echo "${SUDO_PREFIX}pacman -S$(printf ' %s' "$@")" ;;
  apt) echo "${SUDO_PREFIX}apt install$(printf ' %s' "$@")" ;;
  dnf) echo "${SUDO_PREFIX}dnf install$(printf ' %s' "$@")" ;;
  zypper) echo "${SUDO_PREFIX}zypper install$(printf ' %s' "$@")" ;;
  apk) echo "${SUDO_PREFIX}apk add$(printf ' %s' "$@")" ;;
  xbps) echo "${SUDO_PREFIX}xbps-install$(printf ' %s' "$@")" ;;
  nix) echo "nix-env -iA$(printf ' nixpkgs.%s' "$@")" ;;
  *) echo "install these using your system's package manager:$(printf ' %s' "$@")" ;;
  esac
}

# ── Locate this checkout ──────────────────────────────────────────────────────
# install.sh always lives at: ~/.lichtar/bin/install.sh — that's the whole
# git checkout. There is no separate "temporary clone" mode anymore: cloning
# straight into ~/.lichtar is what makes `lichtar update`'s self-update work
# (it needs ~/.lichtar/.git to exist).
BIN_DIR=$(cd "$(dirname "$0")" && pwd)
LICHTAR_HOME=$(cd "$BIN_DIR/.." && pwd)
TARGET_LICHTAR="$HOME/.lichtar"

printf "\n"
printf "  %s%s          LICHTAR  INSTALL            %s\n" "$C_INFO" "$C_B" "$C_NC"
printf "  %s%s─────────────────────────────────────%s\n" "$C_INFO" "$C_B" "$C_NC"

# =============================================================================
# 0. Pre-flight checks
# =============================================================================
section "Pre-flight checks"

if [ ! -d "$BIN_DIR" ] || [ "$LICHTAR_HOME" != "$TARGET_LICHTAR" ]; then
  warn "install.sh must be run from inside $HOME/.lichtar/bin/"
  warn "Found it running from: $LICHTAR_HOME"
  info "Fresh install:"
  info "  git clone https://github.com/linston/lichtar $HOME/.lichtar"
  info "  $HOME/.lichtar/bin/install.sh"
  exit 1
fi

ok "Running from $HOME/.lichtar — will only fill in what's missing"

# =============================================================================
# 1. Packages
# =============================================================================
section "Checking packages"

PM=$(detect_pkg_manager) || PM=""
SUDO_PREFIX=""
[ -n "$PM" ] && [ "$PM" != "pkg" ] && [ "$PM" != "nix" ] && [ "$(id -u)" -ne 0 ] && SUDO_PREFIX="sudo "

missing_optional=""
pkgdata="$LICHTAR_HOME/bin/data/packages.txt"
while IFS= read -r line; do
  case "$line" in
  '' | '#'*) continue ;;
  esac
  ptype="${line%% *}"
  pentry="${line#* }"
  pname="${pentry%%:*}"
  pbin="${pentry#*:}"
  [ "$pbin" = "$pentry" ] && pbin="$pname"
  pbin_override=$(resolve_pkg_bin "$pname")
  [ -n "$pbin_override" ] && pbin="$pbin_override"
  if ! command -v "$pbin" >/dev/null 2>&1; then
    case "$ptype" in
    required) missing_required="$missing_required $pname" ;;
    optional) missing_optional="$missing_optional $pname" ;;
    esac
  fi
done <"$pkgdata"

# p7zip: 3-way binary fallback, doesn't fit the name:binary format above —
# stays hardcoded identically in both install.sh and lichtar_doctor.zsh.
if ! command -v p7zip >/dev/null 2>&1 && ! command -v 7z >/dev/null 2>&1 && ! command -v 7za >/dev/null 2>&1; then
  missing_required="$missing_required p7zip"
fi

if [ -z "$missing_required" ]; then
  ok "All required packages already installed"
else
  warn "Missing required:$missing_required"
fi

if [ -z "$missing_optional" ]; then
  ok "All optional packages already installed"
else
  info "Missing optional:$missing_optional"
fi

if [ -n "$missing_required" ] || [ -n "$missing_optional" ]; then
  resolved=""
  for p in $missing_required $missing_optional; do
    resolved="$resolved $(resolve_pkg_name "$p")"
  done
  printf "\n"
  info "lichtar doesn't install packages itself — install these your own way, e.g.:"
  # shellcheck disable=SC2086  # intentional: word-split into multiple args for "$@" below
  printf "\n    %s\n\n" "$(pm_install_cmd $resolved)"
fi

if [ -n "$missing_required" ]; then
  if ! confirm "Some required tools are still missing — continue anyway?"; then
    exit 1
  fi
fi

# =============================================================================
# 2. Zsh plugins
# =============================================================================
section "Zsh plugins"

mkdir -p "$LICHTAR_HOME/plugins"

clone_plugin() {
  # $1 = repo url, $2 = target dir name
  plugin_name="$2"
  plugin_target="$LICHTAR_HOME/plugins/$plugin_name"
  if [ -d "$plugin_target/.git" ]; then
    info "$plugin_name — already present, skipping"
    return 0
  fi
  if git clone --depth=1 -q "$1" "$plugin_target" 2>/dev/null; then
    ok "$plugin_name"
  else
    warn "$plugin_name — clone failed (check network / URL)"
    PLUGIN_ERRORS=1
  fi
}

PLUGIN_ERRORS=0
clone_plugin "https://github.com/zsh-users/zsh-autosuggestions" "zsh-autosuggestions"
clone_plugin "https://github.com/zsh-users/zsh-history-substring-search" "zsh-history-substring-search"
clone_plugin "https://github.com/Aloxaf/fzf-tab" "fzf-tab"
clone_plugin "https://github.com/zdharma-continuum/fast-syntax-highlighting" "fast-syntax-highlighting"
clone_plugin "https://github.com/hlissner/zsh-autopair" "zsh-autopair"

# =============================================================================
# 3. Directory sanity
# =============================================================================
section "Directories"

mkdir -p "$LICHTAR_HOME/cache"
chmod +x "$LICHTAR_HOME/bin/lichtar" 2>/dev/null || true
ok "Verified $HOME/.lichtar/cache"

# =============================================================================
# 4. Local configuration
# =============================================================================
section "Local configuration"

if [ -f "$LICHTAR_HOME/.env" ]; then
  info "$HOME/.lichtar/.env already exists — leaving it as-is"
elif [ -e "$LICHTAR_HOME/.env" ]; then
  warn "$HOME/.lichtar/.env exists but is not a regular file — aborting"
  exit 1
elif [ -f "$LICHTAR_HOME/.env.example" ]; then
  cp "$LICHTAR_HOME/.env.example" "$LICHTAR_HOME/.env"
  ok "Created $HOME/.lichtar/.env from .env.example"
else
  warn "$HOME/.lichtar/.env.example is missing — skipped local configuration"
fi

# =============================================================================
# 5. .zshrc
# =============================================================================
section "Configuring $HOME/.zshrc"

LOADER="export LICHTAR_HOME=\"\$HOME/.lichtar\"
[[ -f \"\$LICHTAR_HOME/init.zsh\" ]] && \
    source \"\$LICHTAR_HOME/init.zsh\"
"

if [ -f "$HOME/.zshrc" ] && grep -q "source \"\$LICHTAR_HOME/init.zsh\"" "$HOME/.zshrc" 2>/dev/null; then
  info "$HOME/.zshrc already references lichtar — leaving it as-is"
elif [ -f "$HOME/.zshrc" ]; then
  backup="$HOME/.zshrc.lichtar-backup-$(date +%Y%m%d%H%M%S)"
  warn "$HOME/.zshrc already exists and does not reference lichtar."
  if confirm_always "Back up existing $HOME/.zshrc to $(basename "$backup") and add lichtar's loader to the end?"; then
    cp "$HOME/.zshrc" "$backup"
    printf '\n%s' "$LOADER" >>"$HOME/.zshrc"
    ok "Backed up to $backup"
    ok "Installed lichtar $HOME/.zshrc"
  else
    warn "Skipped — add manually:"
    warn "  export LICHTAR_HOME=\"\$HOME/.lichtar\""
    warn "  source \"\$LICHTAR_HOME/init.zsh\""
  fi
else
  printf '%s' "$LOADER" >"$HOME/.zshrc"
  ok "Installed $HOME/.zshrc"
fi

# =============================================================================
# 6. Nerd Font
# =============================================================================
section "Nerd Font"

if [ -n "$TERMUX_VERSION" ]; then
  FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"

  if [ -f "$HOME/.termux/font.ttf" ]; then
    info "$HOME/.termux/font.ttf already exists — leaving it as-is"
  elif confirm "Download and install JetBrainsMono Nerd Font?"; then
    mkdir -p "$HOME/.termux"
    if command -v curl >/dev/null 2>&1 && command -v unzip >/dev/null 2>&1; then
      font_tmp=$(mktemp -d "${TMPDIR:-$PREFIX/tmp}/lichtar-font.XXXXXX")
      if curl -fsLo "$font_tmp/JetBrainsMono.zip" "$FONT_URL" &&
        unzip -p "$font_tmp/JetBrainsMono.zip" "JetBrainsMonoNerdFont-Regular.ttf" \
          >"$HOME/.termux/font.ttf" 2>/dev/null &&
        [ -s "$HOME/.termux/font.ttf" ]; then
        ok "Font installed"
      else
        rm -f "$HOME/.termux/font.ttf"
        warn "Font download/extraction failed — install manually:"
        warn "  $FONT_URL"
      fi
      rm -rf "$font_tmp"
    else
      warn "curl and/or unzip not found — install the font manually:"
      warn "  $FONT_URL"
    fi
    command -v termux-reload-settings >/dev/null 2>&1 && termux-reload-settings
  else
    info "Skipped — icons will show as boxes until a Nerd Font is installed"
  fi
else
  info "Not Termux — install a Nerd Font system-wide (e.g. via $PM) and set"
  info "it in your terminal emulator's font settings."
fi

# =============================================================================
# 7. Default shell
# =============================================================================
section "Default shell"

verify_shell_changed() {
  # $1 = expected zsh path -> prints "yes" / "no" / "unknown"
  if [ -n "$TERMUX_VERSION" ]; then
    if [ "$(readlink "$HOME/.termux/shell" 2>/dev/null)" = "$1" ]; then
      echo yes
    else
      echo no
    fi
  elif command -v getent >/dev/null 2>&1; then
    if [ "$(getent passwd "$(id -un)" 2>/dev/null | cut -d: -f7)" = "$1" ]; then
      echo yes
    else
      echo no
    fi
  else
    echo unknown
  fi
}

current_shell=$(basename "${SHELL:-unknown}")
if [ "$current_shell" = "zsh" ]; then
  ok "zsh is already the default shell"
elif ! command -v zsh >/dev/null 2>&1; then
  warn "zsh is not installed yet — install it first (see Packages step above)"
  info "Then run: chsh -s \$(command -v zsh)"
else
  ZSH_PATH=$(command -v zsh)
  warn "Current default shell is: $current_shell"
  if confirm "Switch default shell to zsh now? (chsh -s $ZSH_PATH)"; then
    # Termux's own chsh prepends $PREFIX/bin/ to whatever name you give it,
    # so it needs the bare command name, not a full path — a full path
    # here silently fails: chsh still exits 0, but nothing actually changes.
    if [ -n "$TERMUX_VERSION" ]; then
      # chsh may legitimately fail in CI or restricted environments; the
      # actual result is checked below, and the fallback handles bash hosts.
      chsh -s "$(basename "$ZSH_PATH")" >/dev/null 2>&1 || :
    else
      # chsh may legitimately fail in CI or restricted environments; the
      # actual result is checked below, and the fallback handles bash hosts.
      chsh -s "$ZSH_PATH" >/dev/null 2>&1 || :
    fi
    # Don't trust chsh's own exit code — on Termux it reports success even
    # when it silently did nothing, and the same has been observed on a
    # proot-distro Arch install for reasons that weren't pinned down. Read
    # back whatever actually got set instead of believing the exit status.
    changed=$(verify_shell_changed "$ZSH_PATH")
    if [ "$changed" = yes ]; then
      if [ -n "$TERMUX_VERSION" ]; then
        ok "Default shell changed to zsh — restart Termux to apply"
      else
        ok "Default shell changed to zsh — log out and back in to apply"
      fi
    elif [ "$changed" = no ] && [ "$current_shell" = "bash" ] && [ -f "$HOME/.bashrc" ]; then
      warn "chsh reported success but didn't actually change anything"
      if ! grep -q 'Added by lichtar install.sh: chsh did not take effect on this system' "$HOME/.bashrc" 2>/dev/null; then
        # shellcheck disable=SC2016 # $ZSH_VERSION must remain literal in the generated .bashrc
        printf '\n# Added by lichtar install.sh: chsh did not take effect on this system\nif [ -z "$ZSH_VERSION" ]; then\n  exec "%s"\nfi\n' "$ZSH_PATH" >>"$HOME/.bashrc"
        ok "Added a fallback to ~/.bashrc — zsh will start automatically from your next bash session"
      else
        info "$HOME/.bashrc already execs into zsh — should already be working; check it manually"
      fi
    else
      warn "chsh may not have worked — switch manually: chsh -s $ZSH_PATH"
      info "If that doesn't stick either, add this to the top of your shell's"
      info "startup file: if [ -z \"\$ZSH_VERSION\" ]; then exec $ZSH_PATH; fi"
    fi
  else
    info "Skipped — switch manually later: chsh -s $ZSH_PATH"
  fi
fi

# =============================================================================
# Done
# =============================================================================
printf "\n  %s%s─────────────────────────────────────%s\n" "$C_INFO" "$C_B" "$C_NC"
if [ "$PLUGIN_ERRORS" -ne 0 ]; then
  warn "Installation completed with errors"
  info "Re-run install.sh after fixing the plugin installation problem"
  exit 1
fi

ok "Installation complete"
if [ -n "$TERMUX_VERSION" ]; then
  info "Restart Termux, or run: exec zsh"
else
  info "Log out and back in, or run: exec zsh"
fi
printf "\n"
