{{/*
WARP sidecar script. Public traffic of the VPN clients leaves through Cloudflare
WARP (kernel WireGuard, interface "warp"); private ranges keep the main table.
While WARP does not answer, the rule is removed and traffic leaves via the node.
*/}}
{{- define "openconnect.warpScript" -}}
#!/bin/sh
set -u
IF=warp
TABLE=51820
PREF=100
SRC="${WARP_NETWORK}/$(ipcalc -p "${WARP_NETWORK}" "${WARP_NETMASK}" | cut -d= -f2)"

log() { echo "$(date -u +%FT%TZ) $*"; }

setup() {
  ip link del "$IF" 2>/dev/null
  ip link add "$IF" type wireguard || return 1
  # Key through a pipe: under the runtime's default AppArmor profile wg cannot fopen() the
  # mounted file (a redirect to /dev/stdin reopens that same file)
  cat /etc/warp/private-key | wg set "$IF" private-key /dev/stdin peer "$WARP_PEER_PUBLIC_KEY" \
    endpoint "$WARP_ENDPOINT" allowed-ips 0.0.0.0/0 persistent-keepalive 25 || return 1
  ip addr add "$WARP_ADDRESS" dev "$IF" || return 1
  ip link set "$IF" mtu "$WARP_MTU" up || return 1
  ip route replace default dev "$IF" table "$TABLE" || return 1
  for net in $WARP_DIRECT_NETWORKS; do
    ip route replace throw "$net" table "$TABLE" || return 1
  done
  # WARP's MTU is below the clients': clamp TCP MSS on the way out
  iptables -t mangle -C FORWARD -o "$IF" -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu 2>/dev/null \
    || iptables -t mangle -A FORWARD -o "$IF" -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
}

rule_on() {
  ip rule show pref "$PREF" | grep -q . && return
  ip rule add pref "$PREF" from "$SRC" lookup "$TABLE" && log "WARP up: $SRC public traffic via WARP"
}

rule_off() {
  ip rule show pref "$PREF" | grep -q . || return
  ip rule del pref "$PREF" && log "WARP down: $SRC public traffic via the node"
}

trap 'rule_off; ip link del "$IF" 2>/dev/null; exit 0' TERM INT

# Left over from a previous container of this pod
rule_off

# Never exit: a crashing sidecar would take the VPN pod out of its Services
until setup; do
  log "setup failed (wireguard module loaded on the node?), retry in ${WARP_CHECK_INTERVAL}s"
  sleep "$WARP_CHECK_INTERVAL" & wait $!
done
log "interface $IF up, endpoint $WARP_ENDPOINT, direct: $WARP_DIRECT_NETWORKS"

fails=0
while :; do
  if ping -I "$IF" -c 1 -W 3 "$WARP_CHECK_HOST" >/dev/null 2>&1; then
    fails=0
    rule_on
  else
    fails=$((fails + 1))
    if [ "$fails" -ge "$WARP_CHECK_FAILURES" ]; then
      rule_off
      # A new source port is a new UDP flow, in case the old one died on the way
      wg set "$IF" listen-port $((20000 + RANDOM % 40000))
      log "no answer through WARP for $fails checks, new listen port"
      fails=0
    fi
  fi
  sleep "$WARP_CHECK_INTERVAL" & wait $!
done
{{- end -}}
