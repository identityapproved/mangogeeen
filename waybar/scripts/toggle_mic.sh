#!/usr/bin/env bash
# HyperX SoloCast mic control for mango/waybar.
# Uses pactl + the stable PipeWire device name (not the volatile node id), so it
# keeps working across reboots. mango's spawn binds don't run a shell, hence the
# logic lives here instead of being chained with && in the keybind.
set -euo pipefail

SRC="alsa_input.usb-Kingston_HyperX_SoloCast-00.analog-stereo"

refresh() { pkill -RTMIN+8 waybar 2>/dev/null || true; }
is_muted() { pactl get-source-mute "$SRC" 2>/dev/null | grep -q yes; }

case "${1:-toggle}" in
toggle)
  pactl set-source-mute "$SRC" toggle
  if is_muted; then
    notify-send "⏸ Mic muted ✗"
  else
    notify-send "▶︎ • Mic unmuted ၊၊||၊။|||"
  fi
  refresh
  ;;
mute)
  pactl set-source-mute "$SRC" 1
  refresh
  ;;
unmute)
  pactl set-source-mute "$SRC" 0
  refresh
  ;;
status)
  is_muted && echo muted || echo unmuted
  ;;
waybar)
  # JSON for the waybar custom/mic module (MDI glyphs render in M+ Nerd Font).
  if is_muted; then
    echo '{"text":"󰍭","class":"muted"}'
  else
    echo '{"text":"󰍬","class":"unmuted"}'
  fi
  ;;
*)
  echo "usage: $0 [toggle|mute|unmute|status|waybar]" >&2
  exit 2
  ;;
esac
