# xray-reality

Xray inbound: VLESS, XTLS-Vision (`flow=xtls-rprx-vision`), REALITY.

This is a proxy, not a VPN. OpenConnect in the same namespace is the VPN. A client may still use TUN mode on the device.

The chart ships the Deployment, Service, and the `config.json` Secret. It does not create an Istio Gateway. TLS passthrough for the REALITY server names belongs to the ingress, so Istio does not terminate the client handshake.

## Several clients, several server names

`clients` is the VLESS user list. Each entry needs a UUID (`id`) and an Xray label (`email`). They share one private key and one short-ID list.

`serverNames` is the REALITY SNI list. Each name is the host in a client URL. One client can use every name. The same names have to be on the passthrough Gateway, and the fallback certificate (`reality.dest`) has to contain every name. An unauthenticated handshake is forwarded to `reality.dest`, and that server must present a certificate that matches the SNI.

Client URL shape, one per server name:

```text
vless://<uuid>@<serverName>:443?encryption=none&flow=xtls-rprx-vision&security=reality&sni=<serverName>&fp=chrome&pbk=<public key>&sid=<shortId>&type=tcp#<email>
```

The public key is the X25519 public half of `reality.privateKey` (`xray x25519 -i`). Do not put the private key or the UUIDs in this chart's values in git. Pass them from a sops file.

## Private destinations through the proxy

By default, two layers block RFC1918 behind the server: a routing rule sends `geoip:private` to `block`, and Xray 26.4+ freedom also blackholes private targets for VLESS unless `finalRules` allow them. Set `privateDirect` to the CIDRs clients may reach. The chart adds a routing allow before the private blackhole and a matching freedom `finalRules` allow. Keep the list narrow; opening all private IPs would expose cluster and node networks.

## WARP (1.1.1.1) public egress

Set `warp.enabled: true` and supply WireGuard device material (`secretKey`, `address`, optional `reserved`) from a `wgcf` registration. The chart adds a userspace WireGuard outbound tagged `warp` and routes all remaining TCP/UDP there. `privateDirect` still uses freedom. No sidecar and no `NET_ADMIN`. Keep `replicaCount: 1` for one WARP device identity. Do not commit WARP keys in plaintext.

## Install

```bash
helm template xray-reality charts/xray-reality \
  --namespace vpn \
  --set fullnameOverride=xray \
  --set serverNames[0]=mirror.example.com \
  --set reality.dest=decoy.example.svc.cluster.local:443 \
  --set reality.privateKey=placeholder \
  --set reality.shortIds[0]=0123456789abcdef \
  --set clients[0].email=alice \
  --set clients[0].id=00000000-0000-0000-0000-000000000000
```
