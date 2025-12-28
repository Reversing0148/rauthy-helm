{{/*
Expand the name of the chart.
*/}}
{{- define "rauthy-helm.name" -}}
{{- default .Release.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "rauthy-helm.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Release.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "rauthy-helm.chart" -}}
{{- printf "%s-%s" .Release.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "rauthy-helm.labels" -}}
helm.sh/chart: {{ include "rauthy-helm.chart" . }}
{{ include "rauthy-helm.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "rauthy-helm.selectorLabels" -}}
app.kubernetes.io/name: {{ include "rauthy-helm.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}


{{/*
Get a domain name by checking ingress hosts first, then httpRoute hosts, falling back to rauthy-helm.local
*/}}
{{- define "rauthy-helm.domainName" -}}
{{- if and .Values.ingress.enabled .Values.ingress.hosts }}
{{- (index .Values.ingress.hosts 0).host }}
{{- else if and .Values.httpRoute.enabled .Values.httpRoute.hostnames }}
{{- index .Values.httpRoute.hostnames 0 }}
{{- else -}}
rauthy-helm.local
{{- end }}
{{- end }}

{{/*
Assume the external scheme based on service, ingress and httproute configurations
Since there is no way of telling the tls configuration of the gateway, this assumes httpRoute is behind tls
*/}}
{{- define "rauthy-helm.externalScheme" -}}
{{- if or (and .Values.ingress.enabled (gt (len .Values.ingress.tls) 0)) (.Values.httpRoute.enabled) (and (not (eq .Values.service.type "ClusterIP")) (eq .Values.service.scheme "https")) -}}
https
{{- else -}}
http
{{- end -}}
{{- end }}

{{/*
Assume the external port based on service, ingress and httproute configurations
*/}}
{{- define "rauthy-helm.externalPort" -}}
{{- if or (and .Values.ingress.enabled (gt (len .Values.ingress.tls) 0)) (.Values.httpRoute.enabled)  -}}
443
{{- else -}}
{{ .Values.service.port}}
{{- end -}}
{{- end }}

{{/*
Generate the public URL based on the external scheme and domain name
*/}}
{{- define "rauthy-helm.pubUrl" -}}
{{- printf "%s://%s" (include "rauthy-helm.externalScheme" .) (include "rauthy-helm.domainName" .) -}}
{{- end }}

{{/*
Generate rp_origin configuration based on the pubUrl and external port 
*/}}
{{- define "rauthy-helm.rpOrigin" -}}
{{- printf "%s:%s" (include "rauthy-helm.pubUrl" .) (include "rauthy-helm.externalPort" .) -}}
{{- end }}

{{/*
Generate jemalloc configuration based on the malloc settings
*/}}
{{- define "rauthy-helm.mallocConf" -}}
{{- $presets := dict "medium" "abort_conf:true,narenas:8,tcache_max:4096,dirty_decay_ms:5000,muzzy_decay_ms:5000" "small" "abort_conf:true,narenas:1,tcache_max:1024,dirty_decay_ms:1000,muzzy_decay_ms:1000" "big" "abort_conf:true,narenas:16,tcache_max:16384,dirty_decay_ms:10000,muzzy_decay_ms:10000" "open" "abort_conf:true,narenas:64,tcache_max:32768,dirty_decay_ms:30000,muzzy_decay_ms:30000" -}}
{{- if eq .Values.size "custom" -}}
{{- .Values.resources.custom | default "" -}}
{{- else -}}
{{- get $presets (default "small" .Values.size) | default (get $presets "small") -}}
{{- end -}}
{{- end -}}