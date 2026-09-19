#!/bin/bash
# TITLE: Existeix la interfície eth2
# DESCRIPTION: Comprova que la màquina té una interfície de xarxa anomenada eth2.

source "$(dirname "$0")/../comu.sh" || { echo "Falta el fitxer comu.sh de l'activitat."; exit 2; }

cal_ordre ip

interficie="eth2"

if ! ip -o link show dev "$interficie" >/dev/null 2>&1; then
    existents="$(ip -o link show 2>/dev/null | awk '{n=$2; sub(/:$/,"",n); sub(/@.*/,"",n); print n}' | en_una_linia)"
    falla "No existeix cap interfície anomenada $interficie. Les interfícies d'aquesta màquina són: ${existents:-cap}."
fi

correcte "La interfície $interficie existeix."
