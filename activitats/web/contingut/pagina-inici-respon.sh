#!/bin/bash
# TITLE: La pàgina d'inici respon correctament
# DESCRIPTION: Comprova que una petició HTTP a http://localhost/ retorna codi 200.

if ! command -v curl >/dev/null 2>&1; then
    echo "L'ordre curl no està instal·lada."
    exit 2
fi

status="$(curl -s -o /dev/null -m 5 -w '%{http_code}' http://localhost/ 2>/dev/null || true)"

if [[ "$status" == "200" ]]; then
    echo "http://localhost/ respon amb el codi 200."
    exit 0
fi

echo "http://localhost/ hauria de respondre amb 200, però s'ha obtingut '${status:-cap resposta}'."
exit 1
