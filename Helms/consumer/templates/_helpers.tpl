{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "dsc.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "dsc.fullname" -}}
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
{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "dsc.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "dsc.labels" -}}
app.kubernetes.io/name: {{ include "dsc.name" . }}
helm.sh/chart: {{ include "dsc.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}


{{/*
Return the secret containing the Keycloak admin password
*/}}
{{- define "consumer.keycloak.secretName" -}}
{{- $secretName := .Values.keycloak.auth.existingSecret -}}
{{- if $secretName -}}
    {{- printf "%s" (tpl $secretName $) -}}
{{- else -}}
    {{- printf "%s" (include "common.names.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Return the secret key that contains the Keycloak admin password
*/}}
{{- define "consumer.keycloak.secretKey" -}}
{{- $secretName := .Values.keycloak.auth.existingSecret -}}
{{- if and $secretName .Values.keycloak.auth.passwordSecretKey -}}
    {{- printf "%s" .Values.keycloak.auth.passwordSecretKey -}}
{{- else -}}
    {{- print "admin-password" -}}
{{- end -}}
{{- end -}}
