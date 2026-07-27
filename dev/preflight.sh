#!/bin/sh
# dev/preflight.sh — runs the same checks lint.yml runs, locally, before
# you push. The badge check itself lives in dev/check_badges.py, shared
# with CI so the two can't drift apart.
#
# Usage: dev/preflight.sh

cd "$(dirname "$0")/.." || exit 1
status=0

echo "== zsh syntax =="
if ! command -v zsh >/dev/null 2>&1; then
  echo "zsh not found — can't run this check locally" >&2
  status=1
else
  find . -name '*.zsh' -exec sh -c '
    status=0
    for f do
      out=$(zsh -n "$f" 2>&1) || {
        echo "$f: $out"
        status=1
      }
    done
    exit "$status"
  ' sh {} + || status=1
fi

echo "== install.sh (POSIX sh) =="
sh -n bin/install.sh || status=1

echo "== shellcheck =="
if command -v shellcheck >/dev/null 2>&1; then
  find . -name '*.sh' -exec shellcheck -s sh {} + || status=1
else
  echo "shellcheck not installed locally — CI will still run it"
fi

echo "== prompt badge glyphs =="
python3 dev/check_badges.py || status=1

if [ "$status" -eq 0 ]; then
  echo ""
  echo "All checks passed."
else
  echo ""
  echo "Some checks failed — see above." >&2
fi

exit "$status"
