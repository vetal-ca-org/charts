{{- define "zerotier.name" -}}
{{- default .Chart.Name .Values.deployment.nameOverride | trunc 63 | trimSuffix "-" -}}
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
{{- if .Values.secret.nameOverride -}}
{{- .Values.secret.nameOverride -}}
{{- else -}}
{{- printf "%s-%s" (include "zerotier.fullname" .) "secret" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

