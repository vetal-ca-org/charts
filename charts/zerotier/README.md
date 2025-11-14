# Zerotier Helm Chart

Deploys a privileged Zerotier member pod that joins a specified network and persists identity material via Kubernetes secrets.

## Usage

```bash
helm lint charts/zerotier
helm install homenet charts/zerotier \
  --namespace gm-relay \
  --create-namespace \
  --set network.id=<network-id> \
  --set network.interface=zt0 \
  --set identity\\.private="${zerotier_private}" \
  --set identity\\.public="${zerotier_public}"
```

The chart always renders the Secret with three keys: `devicemap`, `identity.public`, and `identity.secret`. `devicemap` is derived automatically as `<network.id>=<network.interface>` and is base64-encoded in the manifest.

## Configuration

See `values.yaml` for the complete list of tunables. Key options include:

- `image.*` – Zerotier image repository/tag/pull policy
- `network.id` – target Zerotier network to join
- `network.interface` – interface name used inside the pod (defaults to `zt0`)
- `hostNetwork` – toggles host network mode; also controls Recreate vs RollingUpdate strategy
- `identity.public` / `identity.private` – raw contents of the Zerotier identity files (chart encodes them to Secret data)

