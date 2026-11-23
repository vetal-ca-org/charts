# crashplan

[CrashPlan](https://www.crashplan.com) with the
[jlesage/crashplan-pro image](https://github.com/jlesage/docker-crashplan-pro): the
CrashPlan engine plus its desktop app, shown in the browser (noVNC) on port 5800.

- VNC is off (`VNC_LISTENING_PORT=-1`). The GUI is only the web page.
- The web page has no authentication here. Put it behind a gateway that adds it.
- `/config` (engine settings, device identity in `conf/` and `machine-id`, cache, logs)
  is on a PVC, kept on uninstall (`helm.sh/resource-policy: keep`).
- `config.seed.hostPath`: a `.tar.gz` on the node with an existing `/config` at its root,
  extracted once (when `/config` has no `conf/`). Use it to move an existing install, and
  set `hostname` to the old one. Never run the old install at the same time.
- `hostMounts` are read-only unless `readOnly: false`. CrashPlan sees them at
  `mountPath`; its backup selection uses those paths.
- The image pins the CrashPlan version and disables self-update. Upgrade by changing
  `appVersion` or `image.tag`. The image updates `/config` on the first start of a new
  version.

## Values

| Key | Default | |
|---|---|---|
| `image.tag` | `""` (`v` + `appVersion`) | jlesage tag |
| `permissions.uid` / `.gid` | `1000` | `USER_ID` / `GROUP_ID` |
| `timezone` | `UTC` | `TZ` |
| `maxMemory` | `1G` | `CRASHPLAN_SRV_MAX_MEM`, about 1G per TB selected |
| `hostname` | `""` | Pod hostname, shown by CrashPlan |
| `extraEnv` | `{}` | More image settings |
| `config.persistence.*` | `enabled, 10Gi` | `/config` PVC; emptyDir when disabled |
| `config.seed.hostPath` | `""` | One-time seed tarball on the node |
| `hostMounts` | `[]` | `[{name, hostPath, mountPath, readOnly}]` |
| `service.*` | `ClusterIP`, `5800` | Web GUI Service |

## Example

```yaml
permissions: { uid: 1000, gid: 1000 }
maxMemory: 3G
hostname: my-server
hostMounts:
  - { name: storage, hostPath: /srv/backup, mountPath: /storage }
config:
  seed:
    hostPath: /srv/crashplan-seed.tar.gz
```
