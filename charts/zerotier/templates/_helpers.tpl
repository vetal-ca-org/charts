{{- define "zerotier.name" -}}
{{- $chartName := .Chart.Name -}}
{{- if .Values.deployment.nameOverride -}}
{{- printf "%s-%s" $chartName .Values.deployment.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $chartName | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "zerotier.fullname" -}}
{{- if .Values.deployment.fullnameOverride -}}
{{- .Values.deployment.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name (include "zerotier.name" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "zerotier.labels" -}}
app.kubernetes.io/name: {{ include "zerotier.name" . }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "zerotier.selectorLabels" -}}
app: {{ include "zerotier.name" . }}
{{- end -}}

{{- define "zerotier.secretName" -}}
{{- include "zerotier.fullname" . -}}
{{- end -}}

{{- define "zerotier.localConfName" -}}
{{- printf "%s-%s" "zt-conf" (include "zerotier.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

