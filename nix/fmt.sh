#!/bin/sh
# Format every *.nix file in this directory with the flake's declared
# formatter (nixfmt, see `formatter` in flake.nix). Run manually — no CI
# hook is wired up on purpose.
set -eu
cd "$(dirname "$0")"

files=$(find . -name '*.nix')
if [ -z "$files" ]; then
  echo "No .nix files found."
  exit 0
fi

# shellcheck disable=SC2086
nix fmt -- $files
