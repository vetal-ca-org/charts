# OpenConnect (ocserv) Helm Chart

Deploys an [ocserv](https://www.infradead.org/ocserv/) instance that exposes Cisco AnyConnect-compatible VPN access with per-group routing policies. User credentials live in a Kubernetes Secret, while every ocserv configuration file (main config, per-group overrides, and the default group config) is rendered via ConfigMaps—so no init container or filesystem copy step is required.

## Usage

```bash
helm lint charts/openconnect
helm install vpn charts/openconnect \
  --namespace vpn \
  --create-namespace \
  -f users-secrets.yaml   # auth.users map, ideally a sops file
```

By default the chart enables both `split-tunnel` and `full-tunnel` groups and wires them to `config-per-group` the same way you would configure them manually:

- `split-tunnel` pushes only RFC1918 routes and keeps DNS local.
- `full-tunnel` pushes `route = default` plus explicit DNS resolvers.

Toggle them independently through `.Values.groups.<name>.enabled`, edit the route lists, or add `extraDirectives` to inject any additional ocserv option.

`auth.users` becomes `/etc/ocserv/ocpasswd` in the Secret. Prefer the map form, which a helmfile `secrets:` file can supply as-is, with no `sops | yq` step in the helmfile:

```yaml
auth:
  users:
    alice: { group: split-tunnel, password: "$6$..." }   # mkpasswd -m sha-512
    bob:   { group: full-tunnel,  password: "$6$..." }
```

Lines are rendered sorted by name as `name:group:hash`. A missing `group` becomes `*`. A raw `username:group:hash` string still works, for backward compatibility. `ocpasswd` is a `subPath` mount, so the pod never sees Secret updates. A `checksum/users` pod annotation rolls the Deployment whenever the users change.

Optional Istio resources let you co-host ocserv and HTTPS workloads on the same external address via SNI-based passthrough routing. Enable `.Values.istio.enabled` and set `.Values.vpn_address` to your VPN hostname. The chart will automatically create a `Gateway` + `VirtualService` pair in passthrough mode using `vpn_address` for SNI matching. The chart does not create a cert-manager `Certificate`. With `tls.deriveFromVpnAddress: true` and no `tls.secretName`, it mounts `cert-<vpn_address lowercased, other chars → ->` (max 63), for example `cert-opc-vpn-vetals-com`. Point your Certificate's `secretName` at that name.

DTLS (UDP) needs its own Service, because the TCP side usually rides an ingress passthrough. Set `udpService.enabled: true` to get `<fullname>-udp`, a `LoadBalancer` on `udpService.port` targeting `config.udpPort`, using the chart's own selector. Annotations (for example MetalLB `allow-shared-ip`), `externalTrafficPolicy`, `ipFamilyPolicy`, `ipFamilies` and `loadBalancerIP` pass through.

## Configuration highlights

- `config.*` – top-level ocserv settings (ports, run-as user/group, keepalive timers, TLS file paths, etc.).
- `groups.*` – per-group configuration fragments rendered into `/etc/ocserv/config-per-group/<name>`.
- `defaultGroup.*` – baseline policy for accounts without an explicit group.
- `auth.users` – user map (`name: {group, password}`) or a raw ocpasswd string.
- `auth.passwdFile` – mount point for the Secret-backed user list file.
- `vpn_address` – VPN hostname (e.g., `vpn.example.com`). Used for Istio SNI routing and certificate generation.
- `tls.secretName` – optional Secret with `tls.crt`/`tls.key` (mounted at `/etc/ocserv/ssl`). Takes precedence over the derived name.
- `tls.deriveFromVpnAddress` – when `true` and `tls.secretName` is empty, use `cert-<sanitized vpn_address>`.
- `udpService.*` – optional UDP `LoadBalancer` Service for DTLS.
- `service.*` – toggles a ClusterIP Service (automatically enabled when Istio is used).
- `istio.enabled` – when `true` and `vpn_address` is set, creates Istio Gateway/VirtualService resources for SNI-based passthrough routing.
- `hostNetwork` – disable when routing via ClusterIP/Service meshes, leave enabled for direct node networking.
- `warp.*` – public traffic of the VPN clients out through Cloudflare WARP (see below).

## WARP egress

With `warp.enabled`, a sidecar (`warp`) adds a kernel WireGuard interface to the pod and routes
traffic from the client network (`config.ipv4Network`) to WARP. Private ranges
(`warp.directNetworks`, RFC 1918 and CGNAT by default) keep the main table, so per-group `route`s to
internal networks are unchanged; only groups with `route = default` send public traffic at all.

- Needs: the `wireguard` kernel module loaded on the node (a container cannot load it), and
  `warp.privateKey` from a wgcf registration (`wgcf register && wgcf generate`, `PrivateKey`) of its
  own, not shared with another WARP client. Keep `replicaCount: 1`.
- Failure: the sidecar pings `warp.check.host` through the interface every `intervalSeconds`. After
  `failures` misses it removes the routing rule (traffic leaves via the node IP) and changes the
  WireGuard listen port (a new UDP flow); the rule returns once a ping gets through. The sidecar
  never exits on errors, so it cannot take the pod out of its Services.
- Logs: `kubectl logs <pod> -c warp` (`WARP up` / `WARP down` lines).
- Check from a client in a `route = default` group: `curl https://cloudflare.com/cdn-cgi/trace`
  shows `warp=on`.

See `values.yaml` for the exhaustive list of tunables, including scheduling knobs and security contexts.

