#!/bin/bash
# TITLE: Hi ha connectivitat amb Internet
# DESCRIPTION: Comprova que l'adreça 1.1.1.1 respon al ping, sense dependre de la resolució de noms.

source "$(dirname "$0")/../comu.sh" || { echo "Falta el fitxer comu.sh de l'activitat."; exit 2; }

cal_ordre ping

desti="1.1.1.1"

if ping -c 2 -W 2 -n "$desti" >/dev/null 2>&1; then
    correcte "$desti respon al ping."
fi

falla "No hi ha resposta de $desti. Comprova la ruta per defecte i la sortida a Internet de la màquina."
