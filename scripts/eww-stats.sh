#!/usr/bin/env bash
# Portable system stats for the eww sidebar (no lm_sensors / Arch deps).
# Usage: eww-stats.sh cpu|mem|disk   -> prints an integer percentage.
set -euo pipefail

case "${1:-}" in
    cpu)
        read -r _ a b c idle1 rest < /proc/stat
        total1=$((a + b + c + idle1))
        sleep 0.3
        read -r _ a b c idle2 rest < /proc/stat
        total2=$((a + b + c + idle2))
        dt=$((total2 - total1))
        di=$((idle2 - idle1))
        if [ "$dt" -le 0 ]; then echo 0; else echo $(((100 * (dt - di)) / dt)); fi
        ;;
    mem)
        awk '/^MemTotal:/{t=$2} /^MemAvailable:/{a=$2} END{printf "%d", (t-a)/t*100}' /proc/meminfo
        ;;
    disk)
        df --output=pcent / | tail -1 | tr -dc '0-9'
        ;;
    *)
        echo "usage: $0 cpu|mem|disk" >&2; exit 1
        ;;
esac
