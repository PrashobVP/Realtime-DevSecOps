{{/* templates/_helpers.tpl */}}
{{- define "my-chart.fullname" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name -}}
{{- end -}}