#!/usr/bin/env sh

WP_FOLDER="${HOME}/wallpaper"
WAIT_TIME=599

while :; do
  FILE="$(find "$WP_FOLDER" -type f \( -name '*.png' -o -name '*.jpg' -o -name '*.jpeg' -o -name '*.webp' \) 2>/dev/null | shuf -n1)"

  if [ -z "$FILE" ]; then
    sleep "$WAIT_TIME"
    continue
  fi

  OLD_PID="$(pgrep -x swaybg | head -n1 || true)"
  swaybg -i "$FILE" -m fill &
  NEW_PID="$!"

  sleep 1

  if [ -n "$OLD_PID" ] && [ "$OLD_PID" != "$NEW_PID" ]; then
    kill "$OLD_PID" 2>/dev/null || true
  fi

  sleep "$WAIT_TIME"
done
