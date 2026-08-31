#!/bin/bash
# TITLE: El fitxer personalitzat de l'estudiant és accessible
# DESCRIPTION: Comprova que http://localhost/test-file-{N} respon amb codi 200.

if [[ -z "${1:-}" ]]; then
    echo "Falta el número d'estudiant."
    exit 2
fi
student_number="$1"

if ! command -v curl >/dev/null 2>&1; then
    echo "L'ordre curl no està instal·lada."
    exit 2
fi

url="http://localhost/test-file-${student_number}"
status="$(curl -s -o /dev/null -m 5 -w '%{http_code}' "$url" 2>/dev/null || true)"

if [[ "$status" == "200" ]]; then
    echo "$url és accessible."
    exit 0
fi

echo "$url hauria de respondre amb 200, però s'ha obtingut '${status:-cap resposta}'. Publica el fitxer per superar aquesta prova."
exit 1
