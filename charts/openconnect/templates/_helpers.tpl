{{- define "openconnect.name" -}}
{{- $chartName := .Chart.Name -}}
{{- if .Values.deployment.nameOverride -}}
{{- printf "%s-%s" $chartName .Values.deployment.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $chartName | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "openconnect.fullname" -}}
{{- if .Values.deployment.fullnameOverride -}}
{{- .Values.deployment.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name (include "openconnect.name" .) | trunc 63 | trimSuffix "-" -}}
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
{{- printf "ocserv-conf-%s" (include "openconnect.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "openconnect.secretName" -}}
{{- printf "ocserv-users-%s" (include "openconnect.fullname" .) | trunc 63 | trimSuffix "-" -}}
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

