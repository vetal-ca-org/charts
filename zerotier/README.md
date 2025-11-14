# Zerotier Helm Chart

Deploys a privileged Zerotier member pod that joins a specified network and persists identity material via Kubernetes secrets.

## Usage

```bash
helm lint zerotier
helm install homenet zerotier \
  --namespace gm-relay \
  --create-namespace \
  --set network.id=<network-id> \
  --set network.interface=zt0 \
  --set-file secret.data.identity\\.secret=path/to/identity.secret \
  --set-file secret.data.identity\\.public=path/to/identity.public
```

If `secret.data.devicemap` is omitted, the chart derives `<network.id>=<network.interface>` automatically and base64-encodes it in the rendered Secret.

## Configuration

See `values.yaml` for the complete list of tunables. Key options include:

- `image.*` – Zerotier image repository/tag/pull policy
- `network.id` – target Zerotier network to join
- `network.interface` – interface name used inside the pod (defaults to `zt0`)
- `secret.*` – control creation and contents of the identity secret
- `initContainer.*` – busybox image and command used to stage identity files

