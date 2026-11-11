{{- define "xray-reality.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "xray-reality.labels" -}}
app.kubernetes.io/name: {{ include "xray-reality.fullname" . }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "xray-reality.selectorLabels" -}}
app: {{ include "xray-reality.fullname" . }}
{{- end -}}

{{- define "xray-reality.configSecret" -}}
{{- printf "%s-config" (include "xray-reality.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "xray-reality.configJson" -}}
{{- if not .Values.clients }}
{{- fail "clients must list at least one VLESS client (id, email)" }}
{{- end }}
{{- if not .Values.serverNames }}
{{- fail "serverNames must list at least one REALITY server name" }}
{{- end }}
{{- if not .Values.reality.dest }}
{{- fail "reality.dest must be the fallback host:port" }}
{{- end }}
{{- if not .Values.reality.privateKey }}
{{- fail "reality.privateKey must be set" }}
{{- end }}
{{- if not .Values.reality.shortIds }}
{{- fail "reality.shortIds must list at least one short ID" }}
{{- end }}
{{- if .Values.warp.enabled }}
{{- if not .Values.warp.secretKey }}
{{- fail "warp.secretKey must be set when warp.enabled" }}
{{- end }}
{{- if not .Values.warp.address }}
{{- fail "warp.address must list at least one address when warp.enabled" }}
{{- end }}
{{- if not .Values.warp.peerPublicKey }}
{{- fail "warp.peerPublicKey must be set when warp.enabled" }}
{{- end }}
{{- if not .Values.warp.endpoint }}
{{- fail "warp.endpoint must be set when warp.enabled" }}
{{- end }}
{{- end }}
{{- $clients := list -}}
{{- range .Values.clients }}
{{- $clients = append $clients (dict "id" (required "client.id is required" .id) "flow" (default $.Values.flow .flow) "email" (required "client.email is required" .email)) -}}
{{- end }}
{{- $inbound := dict
  "listen" $.Values.listen
  "port" ($.Values.port | int)
  "protocol" "vless"
  "settings" (dict "clients" $clients "decryption" "none")
  "streamSettings" (dict
    "network" "tcp"
    "security" "reality"
    "realitySettings" (dict
      "dest" $.Values.reality.dest
      "serverNames" $.Values.serverNames
      "privateKey" $.Values.reality.privateKey
      "shortIds" $.Values.reality.shortIds
    )
  )
  "sniffing" (dict "enabled" true "destOverride" (list "http" "tls" "quic") "routeOnly" true)
-}}
{{- $rules := list -}}
{{- with $.Values.privateDirect }}
{{- $rules = append $rules (dict "type" "field" "ip" . "outboundTag" "direct") -}}
{{- end }}
{{- $rules = append $rules (dict "type" "field" "ip" (list "geoip:private") "outboundTag" "block") -}}
{{- $rules = append $rules (dict "type" "field" "protocol" (list "bittorrent") "outboundTag" "block") -}}
{{- /* Xray 26.4+ freedom blocks private IPs for VLESS by default (finalRules).
       Routing to "direct" alone still blackholes; allow the same CIDRs here. */ -}}
{{- $freedom := dict "protocol" "freedom" "tag" "direct" -}}
{{- with $.Values.privateDirect }}
{{- $_ := set $freedom "settings" (dict "finalRules" (list (dict "action" "allow" "ip" .))) -}}
{{- end }}
{{- $outbounds := list -}}
{{- if $.Values.warp.enabled }}
{{- $peer := dict
  "publicKey" $.Values.warp.peerPublicKey
  "endpoint" $.Values.warp.endpoint
  "allowedIPs" (list "0.0.0.0/0" "::/0")
-}}
{{- $wg := dict
  "secretKey" $.Values.warp.secretKey
  "address" $.Values.warp.address
  "peers" (list $peer)
  "mtu" ($.Values.warp.mtu | int)
-}}
{{- with $.Values.warp.reserved }}
{{- $_ := set $wg "reserved" . -}}
{{- end }}
{{- $outbounds = append $outbounds (dict "protocol" "wireguard" "tag" "warp" "settings" $wg) -}}
{{- $rules = append $rules (dict "type" "field" "network" "tcp,udp" "outboundTag" "warp") -}}
{{- end }}
{{- $outbounds = append $outbounds $freedom -}}
{{- $outbounds = append $outbounds (dict "protocol" "blackhole" "tag" "block") -}}
{{- $routing := dict "rules" $rules -}}
{{- if $.Values.warp.enabled }}
{{- $_ := set $routing "domainStrategy" "IPIfNonMatch" -}}
{{- end }}
{{- $config := dict
  "log" (dict "loglevel" $.Values.logLevel)
  "inbounds" (list $inbound)
  "outbounds" $outbounds
  "routing" $routing
-}}
{{- $config | toJson -}}
{{- end -}}
