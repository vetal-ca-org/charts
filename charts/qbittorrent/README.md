# qbittorrent

[qBittorrent](https://www.qbittorrent.org) (`qbittorrent-nox`) with the
[linuxserver.io image](https://docs.linuxserver.io/images/docker-qbittorrent/).

- `hostNetwork: true` runs the pod in the node's network namespace. qBittorrent then
  binds the node's IPv4 and IPv6 addresses itself: the peer port gets no NAT, the Web UI
  is also on `<node>:<webui.port>`, and UPnP works. The ports must be free on the node.
- Profile (`qBittorrent.conf`, `BT_backup/` resume data, `rss/`, logs) in
  `/config/qBittorrent` on a PVC. The PVC is kept on uninstall
  (`helm.sh/resource-policy: keep`).
- `config.seed.hostPath`: a `.tar.gz` on the node, extracted into `/config/qBittorrent`
  once (when it has no `qBittorrent.conf`). Use it to move an existing install.
- `hostMounts` mount download directories at the paths qBittorrent's save paths use.
- `WEBUI_PORT` and `TORRENTING_PORT` override the ports in `qBittorrent.conf` at start.
- With Istio installed, a DestinationRule closes idle proxy connections after
  `istio.upstreamIdleTimeout` (5s). qBittorrent drops connections idle for 7 s, and a
  proxy reusing one fails the request (Envoy: "upstream connect error ... connection
  termination", typically on torrent uploads).

## Values

| Key | Default | |
|---|---|---|
| `image.tag` | `""` (`appVersion`) | linuxserver tag |
| `permissions.uid` / `.gid` | `1000` | `PUID` / `PGID` |
| `timezone` | `UTC` | `TZ` |
| `hostNetwork` | `false` | Node network namespace (adds `dnsPolicy: ClusterFirstWithHostNet`) |
| `webui.port` | `8080` | Web UI port |
| `torrenting.port` | `6881` | Peer port, TCP and UDP |
| `config.persistence.*` | `enabled, 1Gi` | Profile PVC; emptyDir when disabled |
| `config.seed.hostPath` | `""` | One-time seed tarball on the node |
| `hostMounts` | `[]` | `[{name, hostPath, mountPath}]` |
| `service.*` | `ClusterIP`, `8080` | Web UI Service |
| `probes.*` | readiness/liveness timeout 60s; liveness 5 x 60s | Long, since the Web UI blocks while large torrents are added |
| `istio.upstreamIdleTimeout` | `5s` | DestinationRule idle timeout (Istio only; `""` disables) |
| `peerService.*` | disabled | Peer port Service (`LoadBalancer`, `PreferDualStack`) without hostNetwork |

## Example

```yaml
hostNetwork: true
permissions: { uid: 1000, gid: 1000 }
torrenting:
  port: 16141
hostMounts:
  - { name: torrents, hostPath: /srv/torrents, mountPath: /downloads }
config:
  seed:
    hostPath: /srv/qbittorrent-seed.tar.gz
```
