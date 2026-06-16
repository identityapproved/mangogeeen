#!/bin/sh
# Random wallpaper picker/cycler for awww.
#   randomize.sh [dir]              -> set ONE random wallpaper, then exit (buttons/keybinds)
#   randomize.sh loop [dir] [secs]  -> cycle forever; singleton, re-launch is a no-op (autostart)
DEFAULT_DIR="$HOME/pics/wallpapers"

export AWWW_TRANSITION_FPS="${AWWW_TRANSITION_FPS:-60}"
export AWWW_TRANSITION_STEP="${AWWW_TRANSITION_STEP:-2}"

set_random() {
  dir=$1
  [ -d "$dir" ] || { echo "awww randomize: dir not found: $dir" >&2; exit 1; }
  img=$(find -L "$dir" -type f | shuf -n1)
  [ -n "$img" ] && awww img --resize=crop --fill-color 1a1b26 "$img"
}

if [ "$1" = "loop" ]; then
  dir="${2:-$DEFAULT_DIR}"
  interval="${3:-300}"
  # singleton lock: a second loop just exits, so autostart/clicks can never stack
  lock="${XDG_RUNTIME_DIR:-/tmp}/awww-randomize.lock"
  if command -v flock >/dev/null 2>&1; then
    exec 9>"$lock"
    flock -n 9 || { echo "awww randomize: cycler already running" >&2; exit 0; }
  fi
  while true; do
    set_random "$dir"
    sleep "$interval"
  done
else
  set_random "${1:-$DEFAULT_DIR}"
fi
