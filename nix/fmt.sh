#!/bin/sh
# Format every *.nix file in this directory with the flake's declared
# formatter (nixfmt, see `formatter` in flake.nix). Pass --check to verify
# formatting without changing files.
set -eu
cd "$(dirname "$0")"

case "${1:-}" in
  "" | --check) ;;
  *)
    echo "usage: $0 [--check]" >&2
    exit 2
    ;;
esac

find . -type f -name '*.nix' -print0 | xargs -0 -r nix fmt -- "$@"
