# Day-to-day workflow

This is the ordinary loop for a regular change. For the one-time GitHub
setup, see `PUBLISHING.md`. For cutting a version, see `release.sh`.

## 1. Make the change

Edit the file(s). Keep it to one logical change per commit — same rule
that applies to how patches get reviewed during development.

## 2. Run the local checks

    dev/preflight.sh

This is the same thing `lint.yml` runs in CI, just faster — catch it here
before pushing, not after.

## 3. Update CHANGELOG.md

Add one bullet under `## [Unreleased]`, in the right section
(`Added` / `Fixed` / `Changed` / `Removed`). Skip this step only for
changes with zero user-visible effect (comment fixes, internal
refactors, whitespace) — not every commit needs an entry, but every
behavior change does.

## 4. Commit

    git add <files>
    git commit -m "Short, imperative summary"

One line is usually enough — match the style already in CHANGELOG.md
entries (e.g. "Fix root badge rendering as an empty space", not
"fixed stuff" or a wall of text). If the commit needs more explanation
than fits on one line, that's often a sign it should have been two
commits.

## 5. Push

    git push

Straight to `main` — there's no branch-protection/PR flow set up, and
adding one before there are actual contributors would be process for
its own sake. Revisit this if/when someone else starts submitting PRs.

## 6. Check CI went green

GitHub → **Actions** tab, or just watch for the commit status icon next
to the commit on the repo's main page.

## Cutting an actual release

Not every push is a release. Only run `dev/release.sh vX.Y.Z` when you
deliberately want to mark a point in history as "this is version X.Y.Z" —
see `release.sh`'s own comments for what it does.
