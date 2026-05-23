{{/*
Client secret used all places
*/}}
# templates/_helpers.tpl
{{- define "keycloak.clientSecret" -}}
{{- $secret := lookup "v1" "Secret" .Release.Namespace "keycloak-client-secret" -}}
{{- if $secret -}}
{{- index $secret.data "api-service-secret" | b64dec -}}
{{- else -}}
{{- randAlphaNum 32 -}}
{{- end -}}
{{- end -}}
