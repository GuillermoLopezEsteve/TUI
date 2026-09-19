#!/bin/bash
# TITLE: L'ordre jq està instal·lada
# DESCRIPTION: Comprova que jq és disponible, ja que les comprovacions de Kea consulten l'API amb curl i llegeixen la resposta amb jq.

source "$(dirname "$0")/../comu.sh" || { echo "Falta el fitxer comu.sh de l'activitat."; exit 2; }

if command -v jq >/dev/null 2>&1; then
    correcte "L'ordre jq està instal·lada a $(command -v jq)."
fi

falla "L'ordre jq no està instal·lada."
