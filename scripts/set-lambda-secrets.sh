#!/usr/bin/env bash
# Carga los secretos de Strapi en la Lambda sin guardarlos en el repo.
# Lee las llaves de Strapi de un .env y pide la contraseña de la base sin mostrarla.
# Uso: scripts/set-lambda-secrets.sh /ruta/a/strapi.env
set -euo pipefail

ENV_FILE=${1:?Uso: $0 /ruta/a/strapi.env}
FN=${FN:-strapi-portfolio}
AWS=${AWS_CLI:-aws}
AWS_ARGS=(--profile "${AWS_PROFILE_NAME:-mfuentesaws}" --region us-west-2)

read -rsp "Contraseña de strapi_app en Supabase: " DB_PASS
echo

CURRENT=$("$AWS" "${AWS_ARGS[@]}" lambda get-function-configuration \
  --function-name "$FN" --query 'Environment.Variables' --output json)

TMP=$(mktemp)
trap 'rm -f "$TMP"' EXIT

DB_PASS="$DB_PASS" CURRENT="$CURRENT" node -e '
const fs = require("fs");
const keys = ["APP_KEYS", "API_TOKEN_SALT", "ADMIN_JWT_SECRET", "TRANSFER_TOKEN_SALT", "JWT_SECRET", "ENCRYPTION_KEY"];
const src = {};
for (const line of fs.readFileSync(process.argv[1], "utf8").split(/\r?\n/)) {
  const m = line.match(/^\s*([A-Z0-9_]+)\s*=\s*(.*)\s*$/);
  if (m) src[m[1]] = m[2].replace(/^(["\x27])(.*)\1$/, "$2");
}
const missing = keys.filter((k) => !src[k]);
if (missing.length) { console.error("Faltan en el .env: " + missing.join(", ")); process.exit(1); }
if (!process.env.DB_PASS) { console.error("La contraseña está vacía"); process.exit(1); }
const vars = JSON.parse(process.env.CURRENT || "{}") || {};
for (const k of keys) vars[k] = src[k];
vars.DATABASE_PASSWORD = process.env.DB_PASS;
process.stdout.write(JSON.stringify({ Variables: vars }));
' "$ENV_FILE" > "$TMP"

# aws.exe en Windows no entiende rutas estilo /tmp de Git Bash
TMP_PATH=$TMP
command -v cygpath >/dev/null && TMP_PATH=$(cygpath -w "$TMP")

"$AWS" "${AWS_ARGS[@]}" lambda update-function-configuration \
  --function-name "$FN" --environment "file://$TMP_PATH" \
  --query '{Function: FunctionName, Status: LastUpdateStatus}' --output table
echo "Listo. Los secretos quedaron en la configuración de $FN."
