# OpenConnect (ocserv) Helm Chart

Deploys an [ocserv](https://www.infradead.org/ocserv/) instance that exposes Cisco AnyConnect-compatible VPN access with per-group routing policies. User credentials live in a Kubernetes Secret, while every ocserv configuration file (main config, per-group overrides, and the default group config) is rendered via ConfigMaps—so no init container or filesystem copy step is required.

## Usage

```bash
helm lint charts/openconnect
helm install vpn charts/openconnect \
  --namespace vpn \
  --create-namespace \
  --set auth.users="$(cat ocpasswd)"
```

By default the chart enables both `split-tunnel` and `full-tunnel` groups and wires them to `config-per-group` the same way you would configure them manually:

- `split-tunnel` pushes only RFC1918 routes and keeps DNS local.
- `full-tunnel` pushes `route = default` plus explicit DNS resolvers.

Toggle them independently through `.Values.groups.<name>.enabled`, edit the route lists, or add `extraDirectives` to inject any additional ocserv option.

`auth.users` is templated directly into the Secret as the contents of `/etc/ocserv/ocpasswd`. Populate it with `username:group:hashedPassword` lines (use `mkpasswd -m sha-512 <password>` to generate hashes). Rolling the Secret triggers a Deployment restart thanks to the mounted volume.

Optional Istio resources let you co-host ocserv and HTTPS workloads on the same external address via SNI-based passthrough routing. Enable `.Values.istio.enabled`, provide the desired `hosts`, and the chart will render a `Gateway` + `VirtualService` pair in passthrough mode. Advanced overrides such as `istio.namespaceOverride`, `istio.gatewayName`, `istio.selector`, `istio.port`, or `istio.sniHosts` can still be supplied as extra values when needed.

## Configuration highlights

- `config.*` – top-level ocserv settings (ports, run-as user/group, keepalive timers, TLS file paths, etc.).
- `groups.*` – per-group configuration fragments rendered into `/etc/ocserv/config-per-group/<name>`.
- `defaultGroup.*` – baseline policy for accounts without an explicit group.
- `auth.passwdFile` – mount point for the Secret-backed user list file.
- `tls.secretName` – optional Secret containing `server-cert.pem`/`server-key.pem` (mounted at `/etc/ocserv/ssl`).
- `service.*` – toggles a ClusterIP Service (enable when fronting the pod with Istio or another proxy).
- `istio.*` – minimally `enabled` + `hosts` to drive passthrough Gateway/VirtualService resources; optional overrides (`namespaceOverride`, `selector`, `gatewayName`, `port`, `sniHosts`) accept advanced ingress layouts.
- `hostNetwork` – disable when routing via ClusterIP/Service meshes, leave enabled for direct node networking.

See `values.yaml` for the exhaustive list of tunables, including scheduling knobs and security contexts.

