{{/*
Expand the name of the chart.
*/}}
{{- define "rauthy.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "rauthy.fullname" -}}
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

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "rauthy.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "rauthy.labels" -}}
helm.sh/chart: {{ include "rauthy.chart" . }}
{{ include "rauthy.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "rauthy.selectorLabels" -}}
app.kubernetes.io/name: {{ include "rauthy.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "rauthy.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "rauthy.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Generate service ports for the Rauthy service
*/}}
{{- define "rauthy.servicePorts" -}}
- name: hiqlite-raft
  protocol: TCP
  port: {{ .Values.ports.hiqliteRaft }}
  targetPort: hiqlite-raft
- name: hiqlite-api
  protocol: TCP
  port: {{ .Values.ports.hiqliteApi }}
  targetPort: hiqlite-api
- name: http
  port: {{ .Values.ports.http }}
  targetPort: http
  protocol: TCP
{{- if .Values.ports.https }}
- name: https
  port: {{ .Values.ports.https }}
  targetPort: https
  protocol: TCP
{{- end }}
{{- if or .Values.ports.metrics .Values.serviceMonitor.enabled }}
- name: metrics
  port: {{ .Values.ports.metrics | default 9090 }}
  targetPort: metrics
  protocol: TCP
{{- end }}
{{- end }}

{{/*
Generate container ports for the Rauthy container
*/}}
{{- define "rauthy.containerPorts" -}}
- name: hiqlite-raft
  containerPort: {{ .Values.ports.hiqliteRaft }}
  protocol: TCP
- name: hiqlite-api
  containerPort: {{ .Values.ports.hiqliteApi }}
  protocol: TCP
- name: http
  containerPort: {{ .Values.ports.http }}
  protocol: TCP
{{- if .Values.ports.https }}
- name: https
  containerPort: {{ .Values.ports.https }}
  protocol: TCP
{{- end }}
{{- if or .Values.ports.metrics .Values.serviceMonitor.enabled }}
- name: metrics
  containerPort: {{ .Values.ports.metrics | default 9090 }}
  protocol: TCP
{{- end }}
{{- end }}

{{/*
Get the main service port (HTTP by default, HTTPS if HTTP is disabled)
*/}}
{{- define "rauthy.servicePort" -}}
{{- if .Values.ports.https }}
{{- .Values.ports.https }}
{{- else }}
{{- .Values.ports.http }}
{{- end }}
{{- end }}

{{/*
Generate probe configuration with automatic scheme/port detection
*/}}
{{- define "rauthy.probeHttpGet" -}}
{{- if .Values.ports.https }}
scheme: HTTPS
port: https
{{- else }}
scheme: HTTP
port: http
{{- end }}
{{- end }}

{{/*
Validate port configuration and provide helpful error messages
*/}}
{{- define "rauthy.validatePorts" -}}
{{- if not .Values.ports.http }}
{{- fail "ports.http is required and cannot be empty" }}
{{- end }}
{{- if not .Values.ports.hiqliteRaft }}
{{- fail "ports.hiqliteRaft is required and cannot be empty" }}
{{- end }}
{{- if not .Values.ports.hiqliteApi }}
{{- fail "ports.hiqliteApi is required and cannot be empty" }}
{{- end }}
{{- end }}

{{/*
Create a ConfigMap for port configuration that can be used by other components
*/}}
{{- define "rauthy.portConfig" -}}
HTTP_PORT: {{ .Values.ports.http | quote }}
{{- if .Values.ports.https }}
HTTPS_PORT: {{ .Values.ports.https | quote }}
{{- end }}
HIQLITE_RAFT_PORT: {{ .Values.ports.hiqliteRaft | quote }}
HIQLITE_API_PORT: {{ .Values.ports.hiqliteApi | quote }}
{{- end }}

{{/*
Generate standard HTTP health check probe configuration
Uses automatic scheme and port detection based on ports configuration
*/}}
{{- define "rauthy.Probe" -}}
httpGet:
  {{- include "rauthy.probeHttpGet" . | nindent 2 }}
  path: /auth/v1/health
{{- end }}
