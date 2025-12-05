{{- define "letsencrypt-issuer.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "letsencrypt-issuer.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "letsencrypt-issuer.labels" -}}
helm.sh/chart: {{ include "letsencrypt-issuer.name" . }}-{{ .Chart.Version | replace "+" "_" }}
{{ include "letsencrypt-issuer.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "letsencrypt-issuer.selectorLabels" -}}
app.kubernetes.io/name: {{ include "letsencrypt-issuer.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "letsencrypt-issuer.cloudflareSecretName" -}}
{{- printf "cloudflare-creds-%s" .Values.issuer.name -}}
{{- end -}}

{{- define "letsencrypt-issuer.acmeKeySecretName" -}}
{{- printf "letsencrypt-%s-acme-key" .Values.issuer.name -}}
{{- end -}}

{{- define "letsencrypt-issuer.acmeServer" -}}
{{- if .Values.issuer.server -}}
{{- .Values.issuer.server -}}
{{- else -}}
{{- if eq .Values.issuer.environment "production" -}}
https://acme-v02.api.letsencrypt.org/directory
{{- else -}}
https://acme-staging-v02.api.letsencrypt.org/directory
{{- end -}}
{{- end -}}
{{- end -}}

