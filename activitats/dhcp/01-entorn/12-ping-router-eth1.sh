#!/bin/bash
# TITLE: Es pot fer ping a 10.50.{N}.1
# DESCRIPTION: Comprova que el router de la xarxa d'eth1, 10.50.{N}.1, respon al ping.

source "$(dirname "$0")/../comu.sh" || { echo "Falta el fitxer comu.sh de l'activitat."; exit 2; }

llegeix_numero "${1:-}"
cal_ordre ping

desti="10.50.${N}.1"

if ping -c 2 -W 2 -n "$desti" >/dev/null 2>&1; then
    correcte "$desti respon al ping."
fi

falla "No hi ha resposta de $desti. Comprova l'adreça d'eth1 i que el router de la xarxa 10.50.${N}.0/24 estigui encès."
