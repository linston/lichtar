# Changelog

All notable changes to lichtar are documented here.
Format loosely follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versions correspond to git tags (`lichtar version` reads them directly) —
this file records _what_ changed, tags record _which commit_.

---

## [Unreleased]

## [v0.1.1] - 2026-08-15

### Added

- `Alt+R` — plain, reverse-chronological history search (standard fzf
  behavior, no frequency ranking), alongside the existing `Ctrl+R`
  frequency-ranked search. Not bound to `Ctrl+Shift+R`: that combo isn't
  reliably distinguishable from plain `Ctrl+R` across terminals, and
  Termux's own support for the escape sequences that would disambiguate
  it is undocumented. Alt+R works identically everywhere.
- `lichtar update` now shows what's new in `CHANGELOG.md` right after a
  successful self-update, instead of requiring a separate
  `lichtar changelog` to notice.
- `glow` — new required dependency. Markdown files now render properly
  (headings, bold, lists, code blocks) instead of as plain text.
- `md` function — view any markdown file through `glow`, themed to
  match lichtar's Catppuccin Mocha (falls back to `$PAGER`/`less` if
  `glow` isn't installed).
- `lichtar changelog` now renders through `glow` + the same theme
  instead of plain-text `less`.
- Vendored Catppuccin's official Glamour style
  (`themes/glow/catppuccin-mocha.json`, MIT, from catppuccin/glamour).

### Fixed

- `lichtar help` was out of sync with several already-shipped features:
  `lichtar changelog`/`lichtar version` weren't listed as commands,
  `lichtar update`'s description still said "plugins only" (missing
  self-update/zcompile/changelog-preview), `md`, the ssh-agent pidfile
  reuse, `Alt+R`, install.sh's bytecode-compile step, and `micro` as an
  optional tool were all undocumented.
- `.zsh` files are now compiled to `.zwc` bytecode (`zcompile`) at the
  end of `install.sh` and after every successful self-update — cuts
  parse time on shell start, ~2.4x faster `source` measured on the
  largest file. Stale `.zwc` (source changed since last compile) is
  automatically ignored by zsh, so this is purely additive, no risk of
  running outdated code.
- `lichtar update` now runs a syntax check (`zsh -n`) on lichtar's own
  files after a self-update, and automatically rolls back to the
  previous commit if anything fails to parse — a bad `git pull` used to
  mean the next shell couldn't even open.
- `autopair-init` was being called twice on every shell start — once by
  `zsh-autopair` itself (its own plugin file self-inits on source), once
  again explicitly in `plugins/load.zsh`. Removed the redundant second
  call.
- `ssh-agent` is now reused across terminal sessions via a pidfile
  (`cache/ssh-agent.env`) instead of spawning a new agent process on
  every shell start — previously every new terminal leaked one.
- `fast-theme` (fast-syntax-highlighting) was re-applying itself on
  every single shell start instead of only when the theme actually
  changed. Its cache fingerprint depended on `stat -c %Y` / `stat -f %m`
  — neither of which exist on Termux's `stat` — so the mtime component
  was always empty and the fingerprint never matched. Replaced with
  zsh's builtin `zstat` (already used the same way elsewhere in the
  codebase), which doesn't depend on any external `stat` binary's flag
  dialect.
- `dev/preflight.sh` now syntax-checks `.zsh` files safely even if paths
  contain whitespace, and CI/local preflight now run blocking ShellCheck
  over every `.sh` script instead of only advisory-checking `install.sh`.

---

## [v0.1.0] - 2026-07-26

### Added

- `lichtar doctor` flags `.env` variables that aren't in `.env.example`
  (renamed/removed config flags no longer fail silently).
- `lichtar update` refreshes the system-detection cache after a
  successful self-update.
- `lichtar changelog` — pages this file.
- `dev/release.sh` — turns `[Unreleased]` into a dated version heading,
  commits, tags. Does not push.
- `dev/preflight.sh` — runs the same checks CI runs, locally.
- `dev/PUBLISHING.md`, `dev/WORKFLOW.md` — one-time publish checklist
  and the regular day-to-day commit workflow.
- CI: syntax-check, install smoke test, and prompt-badge glyph check on
  every push/PR.
- README screenshots.
- `LICENSE` (MIT).

### Fixed

- `install.sh` and `lichtar doctor` now agree with README on which tools
  are required vs optional (`yazi` was miscategorized as optional,
  `neovim` as required).
- `less` is now a documented required dependency — `lichtar help` silently
  depended on it.
- `lichtar doctor` no longer defaults the package manager to Termux's
  `pkg` when the system-detection cache hasn't been generated yet.
- `autopair-init` is no longer called unconditionally — guarded by a
  function-existence check.
- Root badge (`EUID -eq 0`) now renders its lock icon instead of an
  empty colored space.
- Removed the proot-specific badge override that hardcoded the Ubuntu
  icon/color regardless of the actually detected distro.
- Removed references to a non-existent `update_all` command from
  `lichtar update`'s help text and comments.
- `install.sh -y` no longer silently overwrites an existing, unrelated
  `~/.zshrc` — that one confirmation is never skipped by `--yes`.
- `yazi` update step relabeled from "plugins" to "packages" — it already
  updated the Catppuccin flavor too via `ya pkg upgrade`, the label just
  undersold it.
- `install.sh`: two minor shellcheck findings (unsafe `&&`/`||` pseudo
  if-else on the font download; missing `disable` comment on an
  intentional unquoted expansion).
- README's optional prerequisites list was missing `neovim`, even though
  `install.sh`, `lichtar doctor`, and `lichtar help install` all
  correctly listed it.

### Removed

- `mc` alias (undocumented, unused dependency).
