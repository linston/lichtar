# First publish to GitHub

One-time checklist. Not automated on purpose — this runs exactly once.

## 1. Initialize git

This starts as a plain local folder, not a git repository yet.

    cd ~/.lichtar
    git init -b main
    git config user.name    # empty? set it (see below)
    git config user.email   # empty? set it

    git config user.name "Your Name"
    git config user.email "you@example.com"

    git add -A
    git commit -m "Initial commit"

## 2. Local sanity check

    dev/preflight.sh

Fix anything red before continuing.

## 3. Verify what actually got committed

    git status
    cat .gitignore

Make sure nothing personal leaked into the initial commit:

- `.env` (personal config) — should be ignored, `.env.example` should not
- `cache/` (system.env, history) — should be ignored
- `plugins/*/` (cloned third-party plugins) — should be ignored
- `dev/__pycache__/` — should be ignored

## 4. Confirm the executable bits are actually tracked correctly

    git ls-files -s bin/install.sh dev/release.sh dev/preflight.sh dev/check_badges.py

Each line should start with `100755`, not `100644`. If any show `100644`:

    git update-index --chmod=+x bin/install.sh dev/release.sh dev/preflight.sh
    git commit -m "Fix executable bits"

## 5. Double check LICENSE and README

- `LICENSE` — correct name/year
- `README.md` — clone URL matches the repo name you're about to create

## 6. Create the GitHub repo

    gh repo create linston/lichtar --public --source=. --remote=origin

(No `gh` CLI? Create it empty on github.com first, then:)

    git remote add origin https://github.com/linston/lichtar.git

## 7. Tag the first release

    dev/release.sh v0.1.0
    git show HEAD          # sanity check the CHANGELOG diff
    git tag -n v0.1.0       # sanity check the tag message

## 8. Push

    git push -u origin main
    git push --tags

## 9. Verify CI actually ran

Open the repo's **Actions** tab on github.com — `lint` should show a green
check against the pushed commit. If it's red, fix it, don't just re-push
and hope.

## 10. Smoke test from a clean clone

On a different machine (or `rm -rf ~/.lichtar` on a throwaway VM/container):

    git clone https://github.com/linston/lichtar ~/.lichtar
    ~/.lichtar/bin/install.sh
    exec zsh
    lichtar doctor

This is the one step no CI job replaces — an actual human clicking through
the real onboarding path once, end to end.
