{{/*
Validation for Rauthy server scheme
*/}}
{{- define "rauthy.validateScheme" -}}
{{- $validSchemes := list "http" "https" -}}
{{- if not (has .Values.service.scheme $validSchemes) -}}
{{- fail (printf "Invalid service scheme '%s'. Must be one of: %s" (default "undefined" .Values.service.scheme) (join ", " $validSchemes)) -}}
{{- end -}}
{{- end -}}

{{/*
Validation for external secret and config generation
*/}}
{{- define "rauthy.validateConfigurationMethod" -}}
{{- if and .Values.config.generate .Values.externalSecret -}}
{{- fail "Cannot use both config.generate and externalSecret at the same time" -}}
{{- end -}}
{{- if not (or .Values.config.generate .Values.externalSecret) -}}
{{- fail "Either config.generate or externalSecret must be set" -}}
{{- end -}}
{{- end -}}

{{/*
Validation for replica count
*/}}
{{- define "rauthy.validateReplicaCount" -}}
{{- if gt (int .Values.replicaCount) 1 -}}
  {{- if eq (int (mod (int .Values.replicaCount) 2)) 0 -}}
    {{- fail "replicaCount must be an odd number when greater than 1 for proper Raft consensus" -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Validation for malloc preset parameter
*/}}
{{- define "rauthy.validateMallocPreset" -}}
{{- $validPresets := list "small" "medium" "big" "open" "custom" -}}
{{- if not (has .Values.malloc.preset $validPresets) -}}
{{- fail (printf "Invalid malloc preset '%s'. Must be one of: %s" (default "undefined" .Values.malloc.preset) (join ", " $validPresets)) -}}
{{- end -}}
{{- end -}}