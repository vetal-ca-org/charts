{{- define "openconnect.basename" -}}
{{- $base := default .Chart.Name .Values.deployment.nameOverride -}}
{{- $base | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "openconnect.name" -}}
{{- $chart := .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- $base := include "openconnect.basename" . -}}
{{- if eq $base $chart -}}
{{- $chart -}}
{{- else -}}
{{- printf "%s-%s" $chart $base | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "openconnect.fullname" -}}
{{- if .Values.deployment.fullnameOverride -}}
{{- .Values.deployment.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name (include "openconnect.basename" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "openconnect.labels" -}}
app.kubernetes.io/name: {{ include "openconnect.name" . }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "openconnect.selectorLabels" -}}
app: {{ include "openconnect.name" . }}
{{- end -}}

{{- define "openconnect.configName" -}}
{{- printf "conf-%s" (include "openconnect.name" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "openconnect.secretName" -}}
{{- printf "users-%s" (include "openconnect.name" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "openconnect.groupName" -}}
{{- if .group.name -}}
{{- .group.name -}}
{{- else -}}
{{- .key -}}
{{- end -}}
{{- end -}}

{{- define "openconnect.groupFileKey" -}}
{{- $name := include "openconnect.groupName" . -}}
{{- $sanitized := regexReplaceAll "[^a-zA-Z0-9._-]" (lower $name) "-" -}}
{{- printf "%s" $sanitized -}}
{{- end -}}

{{- define "openconnect.renderGroupConfig" -}}
{{- $group := .group -}}
{{- with $group.routes }}
{{- range . }}
route = {{ . }}
{{- end }}
{{- end }}
{{- with $group.dns }}
{{- range . }}
dns = {{ . }}
{{- end }}
{{- end }}
{{- if hasKey $group "tunnelAllDns" }}
tunnel-all-dns = {{ ternary "true" "false" $group.tunnelAllDns }}
{{- end }}
{{- with $group.extraDirectives }}
{{- range . }}
{{ . }}
{{- end }}
{{- end }}
{{- end -}}

{{- define "openconnect.useIstio" -}}
{{- $result := "" -}}
{{- if and .Values.istio.enabled .Values.vpn_address -}}
{{- $result = "true" -}}
{{- end -}}
{{- trim $result -}}
{{- end -}}

{{- define "openconnect.configChecksum" -}}
{{- $configData := "" }}
{{- $config := .Values.config }}
{{- $configData = printf "%s%s" $configData (printf "ipv4-network=%s ipv4-netmask=%s tcp-port=%s udp-port=%s max-clients=%s max-same-clients=%s keepalive=%s dpd=%s mobile-dpd=%s try-mtu-discovery=%s device=%s run-as-user=%s run-as-group=%s" $config.ipv4Network $config.ipv4Netmask $config.tcpPort $config.udpPort $config.maxClients $config.maxSameClients $config.keepalive $config.dpd $config.mobileDpd $config.tryMtuDiscovery $config.device $config.runAsUser $config.runAsGroup) }}
{{- with $config.extraDirectives }}
{{- $configData = printf "%s%s" $configData (join " " .) }}
{{- end }}
{{- if and .Values.defaultGroup (ne (len .Values.defaultGroup) 0) }}
{{- $configData = printf "%s%s" $configData (include "openconnect.renderGroupConfig" (dict "group" .Values.defaultGroup)) }}
{{- end }}
{{- $groups := .Values.groups | default dict }}
{{- $keys := keys $groups | sortAlpha }}
{{- range $idx, $key := $keys }}
{{- $group := index $groups $key }}
{{- if $group.enabled }}
{{- $configData = printf "%s%s" $configData (include "openconnect.renderGroupConfig" (dict "group" $group)) }}
{{- end }}
{{- end }}
{{- $configData | sha256sum | printf "%.8s" }}
{{- end -}}

