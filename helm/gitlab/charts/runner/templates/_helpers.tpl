{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{- define "volumesList" -}}
{{- range $index, $element := .Values.executor.volumes -}}
    {{- if $index -}},{{- end -}}
    {{- $element | quote -}}
{{- end -}}
{{- end -}}

{{- define "minio.fullname" -}}
{{- if .Values.cache.serverAddress -}}
{{ .Values.cache.serverAddress }}
{{ else }}
{{- printf "%s-minio" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
