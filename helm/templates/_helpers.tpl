{{- define "concept.name" -}}
{{- .Chart.Name }}
{{- end }}

{{- define "concept.fullname" -}}
{{- .Chart.Name }}
{{- end }}

{{- define "concept.labels" -}}
app.kubernetes.io/name: {{ include "concept.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Values.image.tag | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "concept.selectorLabels" -}}
app.kubernetes.io/name: {{ include "concept.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
