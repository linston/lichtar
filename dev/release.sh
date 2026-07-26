#!/bin/sh
# dev/release.sh — turns [Unreleased] in CHANGELOG.md into a dated
# version heading, commits, and tags. Does NOT push — review, then:
#   git push && git push --tags
#
# Usage: dev/release.sh v1.2.0

set -e

VERSION="$1"
[ -n "$VERSION" ] || {
  echo "Usage: $0 vX.Y.Z" >&2
  exit 1
}
case "$VERSION" in
v*) ;;
*)
  echo "Version must start with 'v' (e.g. v1.2.0)" >&2
  exit 1
  ;;
esac

CHANGELOG="CHANGELOG.md"
DATE=$(date +%Y-%m-%d)
grep -q "^## \[Unreleased\]" "$CHANGELOG" || {
  echo "No [Unreleased] section in $CHANGELOG" >&2
  exit 1
}

tmp=$(mktemp)
awk -v version="$VERSION" -v date="$DATE" '
/^## \[Unreleased\]/ && !done {
    print
    print ""
    print "## [" version "] - " date
    done=1
    next
}
{ print }
' "$CHANGELOG" >"$tmp"
mv "$tmp" "$CHANGELOG"

git add "$CHANGELOG"
git commit -m "Release $VERSION"
git tag "$VERSION"

echo "Done. Review: git show HEAD && git tag -n $VERSION"
echo "When ready:  git push && git push --tags"
