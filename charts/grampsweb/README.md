---
title: "grampsweb"

description: "A Helm chart for gramps web"

---

# grampsweb

Fork of the WrenIX chart ([codeberg.org/wrenix/helm-charts](https://codeberg.org/wrenix/helm-charts/src/branch/main/grampsweb),
upstream 0.2.58, commit 2c3fc00). All credit to WrenIX; the upstream repo names no license.
Changes: `gramps.extraEnv` (any other `GRAMPSWEB_*` setting, into the Secret). Version
`<upstream>-vetal.<n>`. To update: copy the upstream directory over this one, then re-apply
the `extraEnv` block in `templates/secret.yaml` and `values.yaml`.

![Version: 0.2.58](https://img.shields.io/badge/Version-0.2.58-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 26.11.2](https://img.shields.io/badge/AppVersion-26.11.2-informational?style=flat-square)

A Helm chart for gramps web

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| WrenIX |  | <https://wrenix.eu> |

## Usage

Helm must be installed and setup to your kubernetes cluster to use the charts.
Refer to Helm's [documentation](https://helm.sh/docs) to get started.
Once Helm has been set up correctly, fetch the charts as follows:

```bash
helm pull oci://codeberg.org/wrenix/helm-charts/grampsweb
```

You can install a chart release using the following command:

```bash
helm install grampsweb-release oci://codeberg.org/wrenix/helm-charts/grampsweb --values values.yaml
```

To uninstall a chart release use `helm`'s delete command:

```bash
helm uninstall grampsweb-release
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| autoscaling.enabled | bool | `false` |  |
| autoscaling.maxReplicas | int | `100` |  |
| autoscaling.minReplicas | int | `1` |  |
| autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| fullnameOverride | string | `""` |  |
| global.image.pullPolicy | string | `nil` | if set it will overwrite all pullPolicy |
| global.image.registry | string | `nil` | if set it will overwrite all registry entries |
| gramps.baseURL | string | `"https://gramps.example.org"` | Base URL where the API can be reached (e.g. https://mygramps.mydomain.com/). This is necessary e.g. to build correct password reset links |
| gramps.disableTelemetry | bool | `true` | disable telemetry (overwrite default False to True) |
| gramps.mail.from | string | `nil` | "From" address for automated e-mails |
| gramps.mail.host | string | `nil` | SMTP server host (e.g. for sending password reset e-mails) |
| gramps.mail.password | string | `nil` | SMTP server password |
| gramps.mail.port | int | `465` | SMTP server port. |
| gramps.mail.useTLS | bool | `true` | Boolean, whether to use TLS for sending e-mails. Defaults to true. When using STARTTLS, set this to false and use a port different from 25. |
| gramps.mail.username | string | `nil` | SMTP server username |
| gramps.mediaPrefixTree | bool | `false` | whether or not to use a separate subfolder for the media files of each tree. Defaults to False, but strongly recommend to use True in a multi-tree setup |
| gramps.registrationDisabled | bool | `true` | disable registration (overwrite default False to True) |
| gramps.tree | string | `"Gramps Web"` | To enable multi-tree support, the TREE config option must be set to a single asterisk `*` |
| image.pullPolicy | string | `"IfNotPresent"` | This sets the pull policy for images. (could be overwritten by global.image.pullPolicy) |
| image.registry | string | `"ghcr.io"` | image registry (could be overwritten by global.image.registry) |
| image.repository | string | `"gramps-project/grampsweb"` | image repository |
| gramps.extraEnv | object | `{}` | (fork) more environment variables in the Secret |
| image.tag | string | `""` | image tag - Overrides the image tag whose default is the chart appVersion. |
| imagePullSecrets | list | `[]` |  |
| ingress.annotations | object | `{}` |  |
| ingress.className | string | `""` |  |
| ingress.enabled | bool | `false` |  |
| ingress.hosts[0].host | string | `"chart-example.local"` |  |
| ingress.hosts[0].paths[0].path | string | `"/"` |  |
| ingress.hosts[0].paths[0].pathType | string | `"ImplementationSpecific"` |  |
| ingress.tls | list | `[]` |  |
| nameOverride | string | `""` |  |
| networkPolicy.egress.enabled | bool | `true` | activate egress no networkpolicy |
| networkPolicy.egress.extra | list | `[]` | egress rules |
| networkPolicy.enabled | bool | `false` |  |
| networkPolicy.ingress.http | list | `[]` | ingress for http port (e.g. ingress-controller) |
| nodeSelector | object | `{}` |  |
| persistence.accessMode | string | `"ReadWriteOnce"` |  |
| persistence.annotations | object | `{}` |  |
| persistence.enabled | bool | `true` |  |
| persistence.existingClaim | string | `nil` | A manually managed Persistent Volume and Claim Requires persistence.enabled: true If defined, PVC must be created manually before volume will be bound |
| persistence.hostPath | string | `nil` | Do not create an PVC, direct use hostPath in Pod |
| persistence.size | string | `"5Gi"` |  |
| persistence.storageClass | string | `nil` | Persistent Volume Storage Class If defined, storageClassName: <storageClass> If set to "-", storageClassName: "", which disables dynamic provisioning If undefined (the default) or set to null, no storageClassName spec is   set, choosing the default provisioner.  (gp2 on AWS, standard on   GKE, AWS & OpenStack)  |
| podAnnotations | object | `{}` |  |
| podLabels | object | `{}` |  |
| podSecurityContext | object | `{}` |  |
| replicaCount | int | `1` | replicas |
| resources | object | `{}` |  |
| securityContext | object | `{}` |  |
| service.port | int | `5000` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.automount | bool | `true` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `""` |  |
| tolerations | list | `[]` |  |
| volumeMounts | list | `[]` |  |
| volumes | list | `[]` |  |

Autogenerated from chart metadata using [helm-docs](https://github.com/norwoodj/helm-docs)
