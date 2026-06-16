#!/usr/bin/env bash
# ProtonVPN/WireGuard status for the eww sidebar. Runs as the user, no root,
# no network: detects the wg interface via `ip`, and reads the endpoint IP from
# the host route wg-quick installs for it (the single /32 route via the LAN gw).
# Usage: eww-vpn.sh        -> JSON {"up":bool,"server":str,"ip":str}
set -euo pipefail

iface=$(ip -o link show type wireguard 2>/dev/null | awk -F': ' 'NR==1{print $2}')

if [ -z "${iface:-}" ]; then
    printf '{"up":false,"server":"off","ip":""}\n'
    exit 0
fi

# server label = interface name without the wg- prefix (e.g. wg-CZ-100 -> CZ-100)
server=${iface#wg-}

# endpoint (VPN server public IP) = the only /32 host route sent via a gateway
endpoint=$(ip route show 2>/dev/null \
    | awk '$1 ~ /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/ && /via/ {print $1; exit}')

printf '{"up":true,"server":"%s","ip":"%s"}\n' "$server" "${endpoint:-}"
