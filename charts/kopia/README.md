# kopia

[Kopia](https://kopia.io) repository server for a filesystem repository on a node
host path.

- Kopia terminates TLS (`tls.secretName`, or a cert-manager Certificate the chart
  creates). Kopia's gRPC API needs HTTP/2, which Kopia does not serve without TLS, so
  expose it through a TLS passthrough route or a LoadBalancer, not a TLS-terminating proxy.
- The container exits when the mounted certificate changes (`tls.reloadCheckSeconds`);
  the kubelet restarts it with the new one.
- On start: connect to the repository (or create it with `repository.create`), make
  `identity.username@identity.hostname` the maintenance owner, create or update
  `server.users` (optionally prune others), then `kopia server start`.

## Values

| Key | Default | |
|---|---|---|
| `repository.hostPath` | `""` | Required. Repository directory on the node |
| `repository.create` | `false` | Create a repository when the directory holds none |
| `repository.password` | `""` | Repository password |
| `permissions.uid` / `.gid` | `1000` | Pod user; owner of new repository files |
| `identity.*` | `kopia@kopia-server` | Server identity; `takeMaintenanceOwnership` |
| `server.uiUsername` / `uiPassword` | `admin` / `""` | Web UI basic auth |
| `server.users` | `[]` | `[{name: user@host, password}]` snapshot clients |
| `server.pruneUsers` | `false` | Delete repository users not in `server.users` |
| `server.extraArgs` | `[]` | Extra `kopia server start` flags |
| `existingSecret` | `""` | Keys `repository-password`, `ui-password`, `users` (`user@host:password` lines) |
| `tls.certificate.dnsNames` | `[]` | Certificate hosts (when `tls.secretName` is empty) |
| `tls.certificate.issuerRef` | `ClusterIssuer prod` | |
| `cache.persistence.*` | `enabled, 10Gi` | Cache PVC; emptyDir when disabled |

## Example

```yaml
repository:
  hostPath: /mnt/archive/kopia
  password: repo-secret
server:
  uiPassword: ui-secret
  users:
    - { name: vetal@desktop, password: client-secret }
tls:
  certificate:
    dnsNames: [backup.example.com]
```

```bash
kopia repository connect server --url=https://backup.example.com:443 --override-username=vetal --override-hostname=desktop
```
