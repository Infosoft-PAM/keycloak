{{/*
Client secret used all places
*/}}
{{- define "keycloak.secret.clientSecret" -}}
{{- if .Values.global.secret.clientSecret -}}
    {{- .Values.global.secret.clientSecret | b64enc -}}
{{- else -}}
    {{- $secret := lookup "v1" "Secret" .Values.global.namespace .Values.global.secret.name -}}
    {{- if $secret -}}
        {{- index $secret.data "client-secret" -}}
    {{- else -}}
        {{- randAlphaNum 32 | b64enc -}}
    {{- end -}}
{{- end -}}
{{- end -}}
