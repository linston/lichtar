# Changelog

All notable changes to lichtar are documented here.
Format loosely follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versions correspond to git tags (`lichtar version` reads them directly) —
this file records _what_ changed, tags record _which commit_.

## [Unreleased]

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

### Added

- `lichtar doctor` flags `.env` variables that aren't in `.env.example`
  (renamed/removed config flags no longer fail silently).
- `lichtar update` refreshes the system-detection cache after a
  successful self-update.
- `LICENSE` (MIT).
- CI: syntax-check + install smoke test on every push/PR.

### Removed

- `mc` alias (undocumented, unused dependency).

### Fixed (cont.)

- `install.sh -y` no longer silently overwrites an existing, unrelated
  `~/.zshrc` — that one confirmation is never skipped by `--yes`.
- `yazi` update step relabeled from "plugins" to "packages" — it already
  updated the Catppuccin flavor too via `ya pkg upgrade`, the label just
  undersold it.
- `dev/check_badges.py` false-flagged the default (non-root, non-SSH)
  badge line — its glyph is a variable (`$LICHTAR_ICON`), not a literal
  character, and the old regex mis-matched nested braces. Rewritten to
  brace-count instead of guess.
- `install.sh`: two minor shellcheck findings (unsafe `&&`/`||` pseudo
  if-else on the font download; missing `disable` comment on an
  intentional unquoted expansion).
- README's optional prerequisites list was missing `neovim`, even though
  `install.sh`, `lichtar doctor`, and `lichtar help install` all
  correctly listed it.

### Added (cont.)

- `lichtar changelog` — pages this file.
- `dev/release.sh` — turns `[Unreleased]` into a dated version heading,
  commits, tags. Does not push.
- `dev/preflight.sh` — runs the same checks CI runs, locally.
- `dev/PUBLISHING.md`, `dev/WORKFLOW.md` — one-time publish checklist
  and the regular day-to-day commit workflow.
- CI: prompt-badge glyph check, install smoke test (fresh clone →
  `install.sh` → `lichtar doctor`, catches exactly the class of bug
  `autopair-init` was).
- README screenshots.
