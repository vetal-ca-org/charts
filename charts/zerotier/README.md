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

The chart also renders a ConfigMap (`zt-conf-<release>`) that stores `local.conf`. By default it sets `settings.primaryPort` to `9993`, and the init-container copies the file into `/var/lib/zerotier-one/local.conf`. Override `.Values.localConf` to expose more Zerotier settings—for example:

```
localConf:
  settings:
    primaryPort: 9994
    allowTcpFallbackRelay: true
```

## Branch-specific feature builds

Pushes to any `feature/*` branch trigger the CI workflow to lint, build dependencies, and package the chart. The packaged `.tgz` artifact is suffixed with the sanitized branch name and uses a matching Helm `version` / `appVersion` (for example, `0.3.0-feature-improvemets`). You can download the artifact from the branch workflow run, or point a `helmfile` / `helm-git` repository entry directly at the branch:

```
repositories:
  - name: personal
    url: git+https://github.com/vetal-ca-org/charts@charts/zerotier?ref=feature/improvemets
```

This keeps the branch build clearly separated from official releases while still letting you consume it declaratively.

## Configuration

See `values.yaml` for the complete list of tunables. Key options include:

- `image.*` – Zerotier image repository/tag/pull policy
- `network.id` – target Zerotier network to join
- `network.interface` – interface name used inside the pod (defaults to `zt0`)
- `localConf.*` – contents of `/var/lib/zerotier-one/local.conf` (defaults to `settings.primaryPort=9993`)
- `hostNetwork` – toggles host network mode; also controls Recreate vs RollingUpdate strategy
- `identity.public` / `identity.private` – raw contents of the Zerotier identity files (chart encodes them to Secret data)

