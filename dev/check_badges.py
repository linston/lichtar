#!/usr/bin/env python3
"""Check that every badge="..." assignment in ui/prompt.zsh has a visible
glyph, not just a bare colored space. Shared by CI (lint.yml) and
dev/preflight.sh so the two never drift apart — this exact bug (an empty
root badge) already slipped through once because the check didn't exist."""

import sys

PATH = "ui/prompt.zsh"


def glyph_area(line):
    """Text between the matching close of the first %F{...} color spec and
    the final %b%f. Brace-counted (not regex-guessed) because the color
    spec itself can contain nested braces, e.g. %F{${(P)var}} — a naive
    "first } to %b%f" regex grabs the wrong span on exactly that line."""
    start = line.find("%F{")
    if start == -1:
        return None
    i = start + len("%F{")
    depth = 1
    while i < len(line) and depth > 0:
        if line[i] == "{":
            depth += 1
        elif line[i] == "}":
            depth -= 1
        i += 1
    end = line.find("%b%f", i)
    if end == -1:
        return None
    return line[i:end]


def main():
    bad = []
    with open(PATH, encoding="utf-8") as f:
        for lineno, line in enumerate(f, 1):
            if 'badge="' not in line:
                continue
            area = glyph_area(line)
            if area is None:
                continue
            if area.strip() == "":
                bad.append((lineno, line.strip()))

    if bad:
        for lineno, line in bad:
            print(
                f"::error file={PATH},line={lineno}::badge has no visible glyph: {line}"
            )
        return 1

    print("all badge assignments have a glyph")
    return 0


if __name__ == "__main__":
    sys.exit(main())
