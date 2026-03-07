#!/usr/bin/env sh

selection="$(cliphist list | anyrun --plugins libstdin.so)"

[ -n "$selection" ] || exit 0

printf '%s\n' "$selection" | cliphist decode | wl-copy
