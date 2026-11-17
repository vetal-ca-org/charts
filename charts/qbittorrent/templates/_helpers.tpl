{{- define "qbittorrent.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "qbittorrent.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{- define "qbittorrent.labels" -}}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{ include "qbittorrent.selectorLabels" . }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "qbittorrent.selectorLabels" -}}
app.kubernetes.io/name: {{ include "qbittorrent.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/* Settings forced at start: .Values.settings plus webui.address ([WebUI] Address) */}}
{{- define "qbittorrent.settings" -}}
{{- $s := deepCopy (default dict .Values.settings) }}
{{- with .Values.webui.address }}
{{- $w := default dict (get $s "WebUI") }}
{{- $_ := set $w "Address" . }}
{{- $_ := set $s "WebUI" $w }}
{{- end }}
{{- toYaml $s }}
{{- end }}

{{/* Web UI bound to one address on the host network: Service gets a manual EndpointSlice */}}
{{- define "qbittorrent.manualEndpoint" -}}
{{- if and .Values.hostNetwork .Values.webui.address }}true{{ end }}
{{- end }}
