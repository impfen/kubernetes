{{/*
Expand the name of the chart.
*/}}
{{- define "kiebitz.name" -}}
"kiebitz"
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "kiebitz.fullname" -}}
{{- printf "%s-%s" .Release.Name "kiebitz" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "kiebitz.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "kiebitz.labels" -}}
helm.sh/chart: {{ include "kiebitz.chart" . }}
{{ include "kiebitz.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "kiebitz.selectorLabels" -}}
app.kubernetes.io/name: {{ include "kiebitz.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "kiebitz.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "kiebitz.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}


#
# static web server
#

{{- define "static.name" -}}
"static"
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "static.fullname" -}}
{{- printf "%s-%s" .Release.Name "static" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "static.labels" -}}
helm.sh/chart: {{ include "kiebitz.chart" . }}
{{ include "static.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "static.selectorLabels" -}}
app.kubernetes.io/name: {{ include "static.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

###
### beacon-server
###

{{/*
Expand the name of the chart.
*/}}
{{- define "beacon.name" -}}
"beacon"
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "beacon.fullname" -}}
{{- printf "%s-%s" .Release.Name "beacon" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}

{{- define "beacon.labels" -}}
helm.sh/chart: {{ include "kiebitz.chart" . }}
{{ include "beacon.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "beacon.selectorLabels" -}}
app.kubernetes.io/name: {{ include "beacon.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "beacon.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "beacon.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}


