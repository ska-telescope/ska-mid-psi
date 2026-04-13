{{/* Expand the name of the chart. */}}
{{- define "ska-mid-psi-archiver.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}
