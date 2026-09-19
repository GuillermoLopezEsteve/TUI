#!/bin/bash
# TITLE: L'ordre curl està instal·lada
# DESCRIPTION: Comprova que curl és disponible, ja que les comprovacions de Kea consulten l'API amb curl i llegeixen la resposta amb jq.

source "$(dirname "$0")/../comu.sh" || { echo "Falta el fitxer comu.sh de l'activitat."; exit 2; }

if command -v curl >/dev/null 2>&1; then
    correcte "L'ordre curl està instal·lada a $(command -v curl)."
fi

falla "L'ordre curl no està instal·lada."
