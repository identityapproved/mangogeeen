#!/usr/bin/env bash
# Default-sink helpers for the eww sound block (PipeWire: wpctl + pactl).
# Usage: eww-audio.sh status|next|mute|set <0-100>
set -euo pipefail

case "${1:-status}" in
  status)
      def=$(pactl get-default-sink)
      desc=$(pactl list sinks | awk -v n="$def" '
          $1=="Name:"{cur=($2==n)} cur&&$1=="Description:"{$1="";sub(/^ /,"");print;exit}')
      read -r _ rawvol state < <(wpctl get-volume @DEFAULT_AUDIO_SINK@)
      vol=$(awk -v v="$rawvol" 'BEGIN{printf "%d", v*100}')
      mut=$([ "${state:-}" = "[MUTED]" ] && echo true || echo false)
      printf '{"name":"%s","vol":%s,"muted":%s}\n' "${desc:-$def}" "$vol" "$mut" ;;
  next)
      mapfile -t s < <(pactl list short sinks | awk '{print $2}')
      def=$(pactl get-default-sink); i=0
      for k in "${!s[@]}"; do [ "${s[$k]}" = "$def" ] && i=$k; done
      nx=${s[$(((i+1)%${#s[@]}))]}
      pactl set-default-sink "$nx"
      # follow existing streams to the new output
      pactl list short sink-inputs | awk '{print $1}' | while read -r in; do
          pactl move-sink-input "$in" "$nx"; done ;;
  set)  wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ "${2}%" ;;
  mute) wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle ;;
  *)    echo "usage: $0 status|next|mute|set <0-100>" >&2; exit 1 ;;
esac
