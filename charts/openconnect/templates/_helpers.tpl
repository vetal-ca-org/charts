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

{{- define "openconnect.useCertbot" -}}
{{- $result := "" -}}
{{- if and .Values.certificate.enabled .Values.vpn_address -}}
{{- $result = "true" -}}
{{- end -}}
{{- trim $result -}}
{{- end -}}

{{- define "openconnect.useCertSecret" -}}
{{- $certbotResult := include "openconnect.useCertbot" . -}}
{{- $result := "" -}}
{{- if eq (trim $certbotResult) "true" -}}
{{- $result = "true" -}}
{{- end -}}
{{- trim $result -}}
{{- end -}}

{{- define "openconnect.certSecretName" -}}
{{- $sanitized := regexReplaceAll "[^a-zA-Z0-9-]" (lower .Values.vpn_address) "-" -}}
{{- printf "cert-%s" $sanitized | trunc 63 | trimSuffix "-" -}}
{{- end -}}

